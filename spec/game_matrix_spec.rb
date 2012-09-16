require 'rspec'
require 'fifteen_puzzle'

include FifteenPuzzle

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
                  [15, 5, 2, 10]], matrix,1
    matrix_down = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, 2, 7],
                  [15, 5, 0, 10]], matrix,1                  

    matrix_left = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 0, 6, 7],
                  [15, 5, 2, 10]], matrix,1
    matrix_right = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                  [ 11, 9, 8, 12],
                  [ 3, 6, 7, 0],
                  [15, 5, 2, 10]], matrix,1   


    matrix.parents_count.should == 0
    matrix_up.parents_count.should == 1

    matrix_up.calculate_cost
    matrix_down.calculate_cost
    matrix_left.calculate_cost
    matrix_right.calculate_cost

    matrix.neighbors([],[]).collect{|e| e.matrix}.should == [matrix_up, matrix_down, matrix_left, matrix_right].collect{|e| e.matrix}
  end

  it "should return swapped matrix" do
    matrix = GameMatrix.new Matrix[[ 1, 4, 14, 13],
                [ 11, 9, 8, 12],
                [ 3, 6, 7, 0],
                [15, 5, 2, 10]], matrix   
    matrix.moved_matrix_with_parent(2,3,3,3,[], []).should == GameMatrix.new(Matrix[[ 1, 4, 14, 13],
                      [ 11, 9, 8, 12],
                      [ 3, 6, 7, 10],
                      [15, 5, 2, 0]], matrix    )         
  end

  it "should solve simplest 15 " do
    matrix1 = Matrix[[ 1, 2, 3, 4],
                [ 5, 6, 7, 8],
                [ 9, 10, 11, 12],
                [ 13, 14, 0, 15]]

    matrix2 = Matrix[[ 1, 2, 3, 0],
                [ 5, 6, 7, 4],
                [ 9, 10, 11, 8],
                [ 13, 14, 15, 12]]

    matrix3 = Matrix[[ 1, 2, 3, 4],
                [ 5, 6, 7, 8],
                [ 9, 10, 12, 15],
                [ 13, 14, 11, 0]]

    matrix5 = Matrix[[ 1, 2, 3, 4],
                [ 5, 6, 7, 8],
                [ 9, 10, 0, 12],
                [ 13, 14, 11, 15]]

    game_matrix = GameMatrix.new( matrix5 )
    algorithm = AStarAlgorithm.new( game_matrix )
    algorithm.run.should == true
    
    game_matrix = GameMatrix.new( matrix2 )
    algorithm = AStarAlgorithm.new( game_matrix )
    algorithm.run.should == true

    game_matrix = GameMatrix.new( matrix1 )
    algorithm = AStarAlgorithm.new( game_matrix )
    algorithm.run.should == true

    game_matrix = GameMatrix.new( matrix3 )
    algorithm = AStarAlgorithm.new( game_matrix )
    algorithm.run.should == true

  end

  it "should calc manhattan distance" do
    h_matrix = GameMatrix.new Matrix[[15,1,2,3],[4,5,6,7],[8,9,10,11],[0,13,14,12]]
    h_matrix.get_h.should == 28
  end

  it "should solve hard example" do
      matrix = Matrix[[1,3,4,8],[5,2,0,12],[11,7,6,14],[10,9,15,13]]
      matrix2 = Matrix[[6,4,8,7],[2,1,3,10],[5,0,9,12],[13,14,11,15]]
      matrix3 = Matrix[[1, 0, 2, 3],[5, 6, 7, 4],
                        [9, 10,  11,  8],
                        [13,  14,  15,  12]
                        ]
      matrix4= Matrix[[2,6,0,8],[1,9,7,4],[5,10,15,3],[13,12,14,11]]
      game_matrix = GameMatrix.new( matrix3 )
      algorithm = AStarAlgorithm.new( game_matrix )
      algorithm.run.should == true
  end

  it "should shuffle game matrix" do
    matrix = Matrix[[2,6,0,8],[1,9,7,4],[5,10,15,3],[13,12,14,11]]
    game_matrix = GameMatrix.new( matrix )
    p game_matrix.shuffle
    game_matrix.shuffle.should_not == game_matrix
  end


  
end