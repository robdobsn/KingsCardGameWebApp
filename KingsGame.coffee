
class KingsGame

	constructor: () ->
		@playingCards = new PlayingCards()
		@gameBoard = new GameBoard()
		@displayBoard = new DisplayBoard(@selCellCallback, @dragCellCallback, @selCompleteCallback, @playingCards, false)

	start: () ->
		@gameBoard.deal(@playingCards)
		# Remove Aces
		board = @gameBoard.getBoard()
		for row, rowIdx in board
			for cardId, colIdx in row
				if @playingCards.getCardInfo(cardId).rankIdx == 0
					board[rowIdx][colIdx] = -1
		@playGame()

	playGame: () ->
		console.log "Playing Kings"
		@displayBoard.showGameState(@gameBoard)

