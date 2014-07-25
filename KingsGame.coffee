
class KingsGame

	constructor: () ->
		@playingCards = new PlayingCards()
		@gameBoard = new GameBoard(@playingCards)
		@displayBoard = new DisplayBoard(@selCellCallback, @dragCellCallback, @selCompleteCallback, @clickCallback, @playingCards, false)

	start: () ->
		@gameBoard.deal(@playingCards)
		# Remove Aces
		board = @gameBoard.getBoard()
		gapCardId = -1
		for row, rowIdx in board
			for cardId, colIdx in row
				if @playingCards.getCardInfo(cardId).rankIdx == @playingCards.AceId
					board[rowIdx][colIdx] = gapCardId
					gapCardId -= 1
		@playGame()

	playGame: () ->
		console.log "Playing Kings"
		@displayBoard.showGameState(@gameBoard)

	clickCallback: (clickedCardId) =>
		# console.log "clicked", clickedCardId
		[movedOk, fromRow, fromCol, toRow, toCol] = @gameBoard.moveValidCardToEmptyPlace(clickedCardId)
		if movedOk
			@displayBoard.showGameState(@gameBoard)

	dragCellCallback: (fromId, toId) =>
		console.log "Dragged", fromId, toId
		if @gameBoard.moveCardIfValid(fromId, toId)
			@displayBoard.showGameState(@gameBoard)
