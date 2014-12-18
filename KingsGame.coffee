
class KingsGame

	constructor: (@basePath) ->
		@playingCards = new PlayingCards()
		@gameBoard = new GameBoard(@playingCards)
		@displayBoard = new DisplayBoard(@playingCards, @dragCellCallback, @clickCallback, @resizeHandler, @basePath, ".game-board")
		@gameHistory = new GameHistory()

	start: () ->
		btn = jQuery('.game-button-next')
		fn = btn.button
		jQuery('.game-button-next').button().click(@nextGamePhase)
		jQuery('.game-button-undo').button().click(@undoMove)
		jQuery('.game-button-redo').button().click(@redoMove)
		jQuery('.game-button-hint').button().click(@hintMove)
		@gameBoard.deal()
		@gameBoard.removeAces()
		@gameHistory.addToHistory(@gameBoard)
		@playGame()

	playGame: () ->
		console.log "Playing Kings"
		@displayBoard.hidePick2()
		@displayBoard.showGameState(@gameBoard)

	clickCallback: (clickedCardId) =>
		# Check if in process of picking a 2
		if @displayBoard.isPick2()
			toCardId = @gameBoard.getCardId(@move2ToCell[0], @move2ToCell[1])
			[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveCardIfValid(clickedCardId, toCardId)
			if moveResult == "ok"
				@displayBoard.showGameState(@gameBoard)
				@gameHistory.addToHistory(@gameBoard)
				@displayBoard.hidePick2()
				return
		# console.log "clicked", clickedCardId
		[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveValidCardToEmptyPlace(clickedCardId)
		if moveResult == "ok"
			@displayBoard.showGameState(@gameBoard)
			@gameHistory.addToHistory(@gameBoard)
			@displayBoard.hidePick2()
		else if moveResult == "select2"
			# display banner asking user to click on a 2
			@displayBoard.showPick2()
			@move2ToCell = [toRow, toCol]
		return

	dragCellCallback: (fromId, toId) =>
		@displayBoard.hidePick2()
		console.log "Dragged", fromId, toId
		[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveCardIfValid(fromId, toId)
		if moveResult == "ok"
			@displayBoard.showGameState(@gameBoard)
			@gameHistory.addToHistory(@gameBoard)

	nextGamePhase: () =>
		@displayBoard.hidePick2()
		@gameBoard.redeal()
		@displayBoard.showGameState(@gameBoard)
		@gameHistory.addToHistory(@gameBoard)

	resizeHandler: () =>
		@displayBoard.showGameState(@gameBoard)

	undoMove: () =>
		@displayBoard.hidePick2()
		# @gameBoard.debugDump("Board1")
		prevBoard = @gameHistory.getPreviousBoard()
		# prevBoard.debugDump("Board2")
		@gameBoard.copy(prevBoard)
		@displayBoard.showGameState(@gameBoard)

	redoMove: () =>
		@displayBoard.hidePick2()
		nextBoard = @gameHistory.getNextBoard()
		@gameBoard.copy(nextBoard)
		@displayBoard.showGameState(@gameBoard)

	hintMove: () =>
		console.log "Hint"