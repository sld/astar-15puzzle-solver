# FifteenPuzzle

Fifteen puzzle solver by A* algorithm.
NOTE: In puzzle with more than 20 turns program may work > 1 min.
Tested in Ruby 1.9.3-p125

## Installation

Add this line to your application's Gemfile:

    gem 'fifteen_puzzle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fifteen_puzzle

## Usage

1. Create the game matrix: 
    @game_matrix = FifteenPuzzle::GameMatrix.new( Matrix[[ 1, 4, 14, 13],
					                  [ 11, 9, 8, 12],
					                  [ 3, 6, FifteenPuzzle::GameMatrix::FREE_CELL, 7],
					                  [15, 5, 2, 10]] )
2. Create AStar alogrithm runner:
    @algorithm = FifteenPuzzle::AStarAlgorithm.new( @game_matrix )					                  
3. Run AStar:
	@algorithm.run
	#NOTE: In puzzle with more than 20 turns to solve program may work > 1 min.
4. To access the solution:
	@solution = algorithm.solution
It returns the goal state of game matrix
To Get previous states enter:
	@solution.parent
	#...
5. To get the Matrix of board:
	@solution.matrix
	@solution.parent.matrix

## Testing
RSpec needs for testing.
The specs can run more than 1 minute.
There are several example of matrixes. 
You can change the run matrixes in spec/game_matrix_spec.rb
To run tests enter in command line:
	rspec


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
