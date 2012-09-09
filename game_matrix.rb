#coding: utf-8
require 'matrix'


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


    def first_step      
      @closed_list = [@matrix.matrix_hash]      
      @open_list = @matrix.next_states           
      @matrix = find_cheapest( @open_list )
      @open_list.delete(@matrix)
    end


    def find_cheapest( states )
      cheapest = states.min_by{|e| e.coast}
      

      p "Cant find SOLVE" if cheapest.nil?
      # print_debug
      return cheapest
    end   


    def next_steps                
      @closed_list << @matrix.matrix_hash      
      next_states = @matrix.next_states(@open_list, @closed_list)
      # if next_states.empty?        
      #   @matrix = @matrix.parent        
      #   next_states = @matrix.next_states(@open_list, @closed_list)
      # end      
      @open_list += next_states
      @matrix = find_cheapest(next_states)
      @open_list.delete(@matrix)

    end


    def run
      # @closed_list = []
      # @open_list = [@matrix]
      # while !@open_list.empty?
      #   states = @matrix.next_states(@open_list, @closed_list)
      #   @closed_list << @matrix.matrix_hash
      #   @open_list.delete(@matrix)
      #   @matrix = find_cheapest(states)
      #   @open_list += states




      return @matrix if @matrix.solved?
      first_step
      return @matrix if @matrix.solved?      
      while !@matrix.solved?
        p [@open_list.count, @closed_list.count]        
        next_steps
        p @matrix.matrix
      end      
      return @matrix
    end


    def print_debug
      mapped_open = @open_list.map{|e| e.matrix}
      mapped_close = @closed_list.map{ |e| e.matrix }
      # p [{ :matrix => @matrix.matrix, :open_list => mapped_open, :closed_list => mapped_close } ]
    end
  end


  # Класс игровой матрицы для пятнашек
  class GameMatrix  
    FREE_CELL = 0
    CORRECT_ANSWER = Matrix[[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,0]]


    def initialize( matrix, parent = nil )
      raise ArgumentError if matrix.row_size != 4 ||  matrix.column_size != 4
      @matrix = matrix
      @parent = parent  
      @coast = 0   
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


    def coast
      @coast
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
      (@matrix - CORRECT_ANSWER).find_all{ |e| e != 0 }.count 
    end


    def get_g
      parents_count
    end


    def get_h
      get_uncorrect_positions_count
    end


    def calculate_coast
      g = get_g      
      h = get_h
      @coast = g + h
    end


    def swap(i, j, new_i, new_j)
      swapped_matrix = @matrix.clone
      val = swapped_matrix[i,j]
      swapped_matrix[i, j] = swapped_matrix[new_i, new_j]
      swapped_matrix[new_i, new_j] = val
      return swapped_matrix
    end


    def moved_matrix( i, j, new_i, new_j, open_list )
      return nil if !index_exist?( new_i, new_j )      

      swapped_matrix = swap( i, j, new_i, new_j )    
      swapped_matrix = GameMatrix.new( swapped_matrix, self )            
      swapped_matrix.calculate_coast    

      open_list_matrix = open_list.find{ |e| e == swapped_matrix }      
      if open_list_matrix && open_list_matrix.coast < swapped_matrix.coast
        return open_list_matrix
      else
        return swapped_matrix
      end
    end

    
    def moved_matrixes( i, j, open_list, closed_list )
      up = moved_matrix(i, j, i-1, j, open_list)
      down = moved_matrix(i, j, i+1, j, open_list)
      left = moved_matrix(i, j, i, j-1, open_list)
      right = moved_matrix(i, j, i, j+1, open_list)

      moved = []
      moved << up if !up.nil? && !closed_list.include?( up.matrix_hash )
      moved << down if !down.nil? && !closed_list.include?( down.matrix_hash )
      moved << left if !left.nil? && !closed_list.include?( left.matrix_hash )
      moved << right if !right.nil? && !closed_list.include?( right.matrix_hash )

      return moved
    end


    # Возвращает состояния, возникающие при перемещении цифр на своболную ячейку
    def next_states( open_list = [], closed_list = [])
      i,j = free_cell            
      return moved_matrixes(i, j, open_list, closed_list)      
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
  
  game_matrix = GameMatrix.new( matrix4 )
  algorithm = AStarAlgorithm.new( game_matrix )
  algorithm.run
end

test

