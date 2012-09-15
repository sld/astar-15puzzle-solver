#coding: utf-8
require 'matrix'
require 'set'
require "fifteen_puzzle/version"


class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end


module FifteenPuzzle


  class AStarAlgorithm
    attr_reader :solution
    # For Beam search
    MAX_OPEN_LIST = 1000


    def initialize( game_matrix )
      @matrix = game_matrix
      @nodes_count = 0
    end


    def find_cheapest( states )
      min_cheapest = states.min_by{|e| e.cost}  
      cheapest_list = states.find_all{|e| e.cost==min_cheapest.cost} 
      return cheapest_list.last
    end


    def run
      @closed_list = [].to_set
      @open_list = [@matrix].to_set
      while !@open_list.empty?        

        if @matrix.solved?
          @solution = @matrix
          return true 
        end

        @closed_list << @matrix.matrix_hash    
        @open_list.delete(@matrix)                
        states = @matrix.neighbors(@open_list, @closed_list)   
        if !states.empty? 
          @open_list += states
          @matrix = find_cheapest(states)                    
        else
          @matrix = @open_list.min_by{|e| e.cost}
        end

        # Beam search euristic
        if @open_list.count > MAX_OPEN_LIST        
          @open_list = @open_list.sort_by{|e| e.cost}[0..MAX_OPEN_LIST/2].to_set
        end
      end

    end


  end



  class GameMatrix  
    FREE_CELL = 0
    ROW_SIZE = 4
    COLUMN_SIZE = 4 
    CORRECT_ANSWER = Matrix[[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,0]]
    

    def initialize( matrix, parent=nil, depth_val=0 )
      raise ArgumentError if matrix.row_size != ROW_SIZE ||  matrix.column_size != COLUMN_SIZE

      @matrix = matrix
      @parent = parent  
      @cost = 0   
      @depth = depth_val
    end


    def ==(other)            
      @matrix == other.matrix
    end


    def solved?
      @matrix == CORRECT_ANSWER
    end


    def matrix
      @matrix
    end

    # Get matrix_hash to save it on closed list
    def matrix_hash
      @matrix.hash
    end


    # Get current position of free cell
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


    def parents_count
      count = 0
    
      par = parent
      while !par.nil?
        count += 1        
        par = par.parent
      end
      return count
    end


    def depth 
      @depth
    end


    def depth=(val)
      @depth = val
    end


    def cost
      @cost
    end


    def manhattan_distance
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
        sum += (matrix_hash[e] - etalon_hash[e]).collect{|e| e.abs}.inject{|ind_sum,x| ind_sum + x }
      end

      return sum
    end


    def get_g
      @depth
    end


    def get_h
      manhattan_distance 
    end


    def calculate_cost
      g = get_g      
      h = get_h
      @cost = g + h
    end


    def swap(i, j, new_i, new_j)
      swapped_matrix = @matrix.clone
      val = swapped_matrix[i,j]
      swapped_matrix[i, j] = swapped_matrix[new_i, new_j]
      swapped_matrix[new_i, new_j] = val
      return swapped_matrix
    end


    # Get swapped matrix, check him in closed and open list
    def moved_matrix( i, j, new_i, new_j, open_list, closed_list )
      return nil if !index_exist?( new_i, new_j )      

      swapped_matrix = swap( i, j, new_i, new_j )    

      new_depth = @depth + 1
      swapped_matrix = GameMatrix.new( swapped_matrix, self, new_depth )            
      return nil if closed_list.include?( swapped_matrix )
      swapped_matrix.calculate_cost    

      open_list_matrix = open_list.find{ |e| e == swapped_matrix }      
      if open_list_matrix && open_list_matrix.cost < swapped_matrix.cost
        return open_list_matrix
      elsif open_list_matrix
        open_list_matrix.parent = self
        open_list_matrix.depth = new_depth
        return open_list_matrix        
      else
        return swapped_matrix
      end
    end

    
    # Get all possible movement matrixes
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


