#coding: utf-8
require 'matrix'
require 'set'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end


module FiftinPuzzle


  class AStarAlgorithm
    def initialize( game_matrix )
      @matrix = game_matrix
    end


    def go_around_cheapest cheapest_list, rec_list=[]
      cheapest_list.each do |cheapest|
        @closed_list << cheapest.matrix_hash
        states = cheapest.neighbors(@open_list, @closed_list)
        most_cheapest = find_cheapest( states )
        rec_list << most_cheapest
      end
      min_cheapest = rec_list.min_by{|e| e.cost}
      cheapest_list = rec_list.find_all{|e| e==min_cheapest}     
      if cheapest_list.count > 1
        cheapest = go_around_cheapest cheapest_list
      else
        return cheapest_list.first
      end
    end


    def find_cheapest( states )
      min_cheapest = states.min_by{|e| e.cost}
      # return min_cheapest
      cheapest_list = states.find_all{|e| e.cost==min_cheapest.cost} 
      return cheapest_list.last
      # # p ["deb", cheapest_list.count, states.count]
      # # gets
      # if cheapest_list.count == 1
      #   @open_list << min_cheapest
      #   return min_cheapest 
      # end

      # mins = [].to_set
      # cheapest_list.each do |node|
      #   # p ["deb", node.matrix]
      #   # gets
      #   @closed_list << node
      #   neighbors = node.neighbors(@open_list, @closed_list)
      #   @open_list += neighbors
      #   @open_list.delete( node )
      #   min_val = neighbors.min_by{|e| e.cost}
      #   mins += neighbors.find_all{ |e| e.cost==min_val.cost }
      # end

      # if mins.count == 1
      #   return mins.first
      # else
      #   find_cheapest(mins)
      # end
    end   



    def run
      @closed_list = [].to_set
      @open_list = [@matrix].to_set
      while !@open_list.empty?
        p @matrix.matrix

        return true if @matrix.solved?
        @closed_list << @matrix.matrix_hash    
        @open_list.delete(@matrix)                
        states = @matrix.neighbors(@open_list, @closed_list)   
        if !states.empty? 
          @open_list += states
          @matrix = find_cheapest(states)                
          # @open_list += states     
        else
          @matrix = @open_list.min_by{|e| e.cost}
        end

        if @open_list.count > 1000        
          @open_list = @open_list.sort_by{|e| e.cost}
          p @open_list.collect{|e| e.cost}  
          @open_list = @open_list[0..500].to_set

        end
      end
      return false
    end


  end


  # Класс игровой матрицы для пятнашек
  class GameMatrix  
    FREE_CELL = 0
    CORRECT_ANSWER = Matrix[[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,0]]
    
    # CORRECT_ANSWER = Matrix[[1,2,3], [4,5,6], [7,8,9], [10,11,0]]

    def initialize( matrix, parent = nil )
      raise ArgumentError if matrix.row_size != 4 ||  matrix.column_size != 4
      @matrix = matrix
      @parent = parent  
      @cost = 0   
    end


    def ==(other)            
      # return false if other.nil?
      @matrix == other.matrix
    end


    def solved?
      @matrix == CORRECT_ANSWER
    end


    # Возвращает текущую матрицу 
    def matrix
      @matrix
    end

    def matrix_hash
      @matrix.hash
    end



    # Возвращает текущую позицию свободной ячейки в матрице
    def free_cell
      @matrix.find_index{ |elem| elem == FREE_CELL}
    end


    def index_exist?(i, j)
      return false if i < 0 || j < 0
      not @matrix[i, j].nil?
    end


    def parent
      return @parent
    end


    def parent=(val)
      @parent = val
    end


    def cost
      @cost
    end


    def top_parent
      par = parent
      while !par.nil?  
        return par if par.parent.nil?
        par = par.parent
      end
      return par 
    end


    def parents_count
      count = 0
    
      par = parent
      while !par.nil?
        count += 1        
        par = par.parent
      end
      return count
    end


    def get_uncorrect_positions_count
      # (@matrix - CORRECT_ANSWER).find_all{ |e| e != 0 }.count 
      matrix_hash = {}
      @matrix.each_with_index do |e, i, j|
        matrix_hash[e] = Vector[i, j]
      end

      etalon_hash = {}
      CORRECT_ANSWER.each_with_index do |e, i, j|
        etalon_hash[e] = Vector[i, j]
      end

      summ = 0

      etalon_hash.keys.each do |e|
        summ += (matrix_hash[e] - etalon_hash[e]).collect{|e| e.abs}.inject{|sum,x| sum + x }
      end
      return summ
    end


    def get_g
      parents_count
    end


    def get_h
      get_uncorrect_positions_count
    end


    def calculate_cost
      g = get_g      
      h = get_h
      # p ["cost", g, h]
      @cost = g + h
    end


    def swap(i, j, new_i, new_j)
      swapped_matrix = @matrix.clone
      val = swapped_matrix[i,j]
      swapped_matrix[i, j] = swapped_matrix[new_i, new_j]
      swapped_matrix[new_i, new_j] = val
      return swapped_matrix
    end


    def moved_matrix( i, j, new_i, new_j, open_list, closed_list )
      return nil if !index_exist?( new_i, new_j )      

      swapped_matrix = swap( i, j, new_i, new_j )    
      swapped_matrix = GameMatrix.new( swapped_matrix, self )            
      return nil if closed_list.include?( swapped_matrix )
      swapped_matrix.calculate_cost    


      open_list_matrix = open_list.find{ |e| e == swapped_matrix }      
      if open_list_matrix && open_list_matrix.cost < swapped_matrix.cost
        return open_list_matrix
      elsif open_list_matrix
        open_list_matrix.parent = self
        return open_list_matrix        
      else
        return swapped_matrix
      end
    end

    
    def neighbors( open_list, closed_list )
      i,j = free_cell      
      up = moved_matrix(i, j, i-1, j, open_list, closed_list)
      down = moved_matrix(i, j, i+1, j, open_list, closed_list)
      left = moved_matrix(i, j, i, j-1, open_list, closed_list)
      right = moved_matrix(i, j, i, j+1, open_list, closed_list)

      moved = [].to_set
      moved << up if !up.nil? 
      moved << down if !down.nil? 
      moved << left if !left.nil? 
      moved << right if !right.nil? 

      return moved
    end
  end


end


include FiftinPuzzle
def test
  matrix = Matrix[[ 15, 11, 4, 8],
                  [ 5, 12, 3, 7],
                  [ 9, 1, 10, 2],
                  [ GameMatrix::FREE_CELL, 6, 14, 13]]

  matrix2 = Matrix[[ 1, 2, 3, 4],
                  [ 5, 6, 7, 8],
                  [ 9, 10, 11, 12],
                  [ GameMatrix::FREE_CELL, 13, 14, 15]]

  matrix3 = Matrix[[1, 2, 3, 4], [11, 6, 0, 14], [15, 7, 9, 10], [5, 8, 12, 13]]

  matrix4 = Matrix[[2, 0, 3, 4], [7, 10, 9, 8], [1, 14, 6, 11], [5, 13, 15, 12]]

  matrix5 = Matrix[[ 1, 2, 3, 4],
                  [ 5, 6, 7, 8],
                  [ 9, 10, 0, 12],
                  [ 13, 14, 11, 15]]

  game_matrix = GameMatrix.new( matrix5 )
  algorithm = AStarAlgorithm.new( game_matrix )
  algorithm.run
end

# test

