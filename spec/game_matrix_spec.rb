require 'rspec'
require_relative '../game_matrix'

describe GameMatrix do

	it "should == to another game matrix" do
    matrix = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, GameMatrix::FREE_CELL, 7],
                  [15, 5, 2, 10]]

    matrix2 = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, GameMatrix::FREE_CELL, 7],
                  [15, 5, 2, 10]]
    matrix.should == matrix2              
  end

  it "should show next moves" do
    matrix = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, 0, 7],
                  [15, 5, 2, 10]]
    matrix_up = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 0, 12],
                  [ 3, 6, 8, 7],
                  [15, 5, 2, 10]], matrix
    matrix_down = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, 2, 7],
                  [15, 5, 0, 10]], matrix                  

    matrix_left = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 0, 6, 7],
                  [15, 5, 2, 10]], matrix
    matrix_right = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, 7, 0],
                  [15, 5, 2, 10]], matrix   


    matrix.parents_count.should == 0
    matrix_up.parents_count.should == 1
    matrix.get_h.should == 15
    matrix.next_states.should == [matrix_up, matrix_down, matrix_left, matrix_right]
  end

  it "should return swapped matrix" do
      matrix = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, 7, 0],
                  [15, 5, 2, 10]], matrix   
      matrix.moved_matrix(2,3,3,3,[]).should == GameMatrix.new(Matrix[[ 1, 4, 14, 13],
                        [ 11, 9, 8, 12],
                        [ 3, 6, 7, 10],
                        [15, 5, 2, 0]], matrix    )         
  end


  
end