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
      @nodes_count = 0
    end

    def run
      @matrix.calculate_cost
      @cost_limit = @matrix.cost
      
      nodes_to_visit = [@matrix]

      while !nodes_to_visit.empty?
        current_node = nodes_to_visit.shift
        if current_node.solved?
          print "SOLVED"
          return true
        end               
        neighbors = current_node.neighbors         
        neighbors.each do |n|
          if n.solved?
            print "SOLVED"
            return true
          end  
          if n.cost <= @cost_limit
            nodes_to_visit.unshift(n)
          end
        end
        if nodes_to_visit.empty?
           @cost_limit += 1 #neighbors.min_by{|e| e.cost}.cost
           nodes_to_visit = [@matrix]
        end
      end

    end

  end





  # Класс игровой матрицы для пятнашек
  class GameMatrix  
    FREE_CELL = 0
    CORRECT_ANSWER = Matrix[[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,0]]
    
    # CORRECT_ANSWER = Matrix[[1,2,3], [4,5,6], [7,8,9], [10,11,0]]

    def initialize( matrix, depth = 0 )
      raise ArgumentError if matrix.row_size != 4 ||  matrix.column_size != 4
      @matrix = matrix
      @depth = depth  
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

      sum = 0

      etalon_hash.keys.each do |e|
        sum += (matrix_hash[e] - etalon_hash[e]).collect{|e| e.abs}.inject{|sum,x| sum + x }
      end
      return sum
    end


    def get_g
      @depth
    end


    def get_h
      get_uncorrect_positions_count
    end


    def calculate_cost
      g = get_g      
      h = get_h
      p ["deb", g, h]
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
      swapped_matrix = GameMatrix.new( swapped_matrix, @depth+1 )            
      swapped_matrix.calculate_cost    

      return swapped_matrix

    end

    
    def neighbors( open_list=[], closed_list=[] )
      i,j = free_cell      
      up = moved_matrix(i, j, i-1, j, open_list, closed_list)
      down = moved_matrix(i, j, i+1, j, open_list, closed_list)
      left = moved_matrix(i, j, i, j-1, open_list, closed_list)
      right = moved_matrix(i, j, i, j+1, open_list, closed_list)

      moved = []
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

