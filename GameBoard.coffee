class GameBoard
	numRows: 4
	numCols: 13

	constructor: () ->
		@board = []

	deal: (deck) ->
		@board = []
		deck.startDeal()
		for row in [0..@numRows-1]
			boardRow = []
			for col in [0..@numCols-1]
				boardRow.push deck.getNextCard()
			@board.push boardRow
		return true

	getBoard: () ->
		return @board
