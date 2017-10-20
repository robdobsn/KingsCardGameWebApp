
class KingsGame

	constructor: (@basePath) ->
		@playingCards = new PlayingCards()
		@gameBoard = new GameBoard(@playingCards)
		@displayBoard = new DisplayBoard(@playingCards, @dragCellCallback, @clickCallback, @resizeHandler, @basePath, ".game-board")
		@gameHistory = new GameHistory()
		@gameSearch = new GameSearch()
		@exitHintMode()

	start: () ->
		@exitHintMode()
		btn = jQuery('.game-button-next')
		fn = btn.button
		jQuery('.game-button-next').button().click(@nextGamePhase)
		jQuery('.game-button-undo').button().click(@undoMove)
		jQuery('.game-button-redo').button().click(@redoMove)
		jQuery('.game-button-hint').button().click(@getHint)
		jQuery('.game-button-play-hint').button().click(@playHint)
		jQuery('.game-button-play-hint').css('visibility', 'hidden')
		@gameBoard.deal()
		@gameBoard.removeAces()
		@gameHistory.addToHistory(@gameBoard)
		@playGame()

	playGame: () ->
		console.log "Playing Kings"
		@exitHintMode()
		@displayBoard.hidePick2()
		@displayBoard.showGameState(@gameBoard)

	clickCallback: (clickedCardId) =>
		@exitHintMode()
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
		@exitHintMode()
		@displayBoard.hidePick2()
		console.log "Dragged", fromId, toId
		[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveCardIfValid(fromId, toId)
		if moveResult == "ok"
			@displayBoard.showGameState(@gameBoard)
			@gameHistory.addToHistory(@gameBoard)

	nextGamePhase: () =>
		@exitHintMode()
		@displayBoard.hidePick2()
		@gameBoard.redeal()
		@displayBoard.showGameState(@gameBoard)
		@gameHistory.addToHistory(@gameBoard)
		@displayBoard.clearArrows()

	resizeHandler: () =>
		@displayBoard.showGameState(@gameBoard)
		if @hintMoveIdx >= 0
			bestMoves = @gameSearch.getBestMoves()
			@displayBoard.showMoveSequence(bestMoves[0], bestMoves[1], @hintMoveIdx, false)

	undoMove: () =>
		@displayBoard.hidePick2()
		# @gameBoard.debugDump("Board1")
		prevBoard = @gameHistory.getPreviousBoard()
		# prevBoard.debugDump("Board2")
		@gameBoard.copy(prevBoard)
		@displayBoard.showGameState(@gameBoard)
		# Hint mode
		if @hintMoveIdx > 0
			@hintMoveIdx--
			bestMoves = @gameSearch.getBestMoves()
			@displayBoard.showMoveSequence(bestMoves[0], bestMoves[1], @hintMoveIdx, false)
		else
			@exitHintMode()

	redoMove: () =>
		@exitHintMode()
		@displayBoard.hidePick2()
		nextBoard = @gameHistory.getNextBoard()
		@gameBoard.copy(nextBoard)
		@displayBoard.showGameState(@gameBoard)

	getHint: () =>
		bestMoves = @gameSearch.getDynamicTree(@gameBoard, @displayBoard)
		console.log "Best score " + bestMoves[1]
		for move in bestMoves[0]
			console.log "From " + move[0] + " to " + move[1]
		if bestMoves[0].length > 0
			@hintMoveIdx = 0
			jQuery('.game-button-play-hint').css('visibility', 'visible')
			@displayBoard.showMoveSequence(bestMoves[0], bestMoves[1], @hintMoveIdx, false)

	playHint: () =>
		# Check we're in hint mode
		if @hintMoveIdx < 0
			return
		# Get the hint moves
		bestMoves = @gameSearch.getBestMoves()
		moveToPlay = bestMoves[0][@hintMoveIdx]
		# Make the move
		[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveCardUsingRowAndColInfo(moveToPlay[0], moveToPlay[1])
		if moveResult == "ok"
			@displayBoard.showGameState(@gameBoard)
			@gameHistory.addToHistory(@gameBoard)
			@displayBoard.hidePick2()
		# Next hint move
		@hintMoveIdx++
		if @hintMoveIdx >= bestMoves[0].length
			@exitHintMode()
			return
		@displayBoard.showMoveSequence(bestMoves[0], bestMoves[1], @hintMoveIdx, false)

	exitHintMode: () =>
		@hintMoveIdx = -1
		@displayBoard.clearArrows()
		jQuery('.game-button-play-hint').css('visibility', 'hidden')

