
class KingsGame

	constructor: (@basePath) ->
		@gameMode = "random"
		@gameBoard = new GameBoard()
		@displayBoard = new DisplayBoard(@dragCellCallback, @clickCallback, @resizeHandler, @basePath, ".game-board")
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
		jQuery('.game-button-best').button().click(@getBest)
		jQuery('.game-button-play-best').button().click(@playBest)
		jQuery('.game-button-play-best').css('visibility', 'hidden')
		jQuery('.game-button-fixed-random').button().click(@fixedRandom)
		jQuery('.game-button-fixed-minus').button().click(@fixedGameMinus)
		jQuery('.game-button-fixed-plus').button().click(@fixedGamePlus)
		jQuery('.game-button-new-game').button().click(@newGame)
		@gameBoard.deal()
		@gameBoard.removeAces()
		@gameHistory.addToHistory(@gameBoard)
		@playGame()

	playGame: () ->
#		console.log "Playing Kings"
		@exitHintMode()
		@displayBoard.hidePick2()
		@displayBoard.showGameState(@gameBoard)

	newGame: () =>
		gameNumber = @gameBoard.gameSeed
#		console.log "New Game"
		@exitHintMode()
		@gameBoard = new GameBoard()
		if @gameMode == "fixed"
			@gameBoard.setFixedSeed(gameNumber)
		@gameBoard.deal()
		@gameBoard.removeAces()
		@gameHistory = new GameHistory()
		@gameHistory.addToHistory(@gameBoard)
		@playGame()

	fixedRandom: () =>
		if @gameMode == "random"
			@gameMode = "fixed"
			jQuery('.game-button-fixed-random span').text("Random")
			jQuery('.game-button-fixed-plus').show()
			jQuery('.game-button-fixed-minus').show()
			@gameBoard.setFixedSeed(1)
			@newGame()
		else
			@gameMode = "random"
			jQuery('.game-button-fixed-random span').text("Fixed")
			jQuery('.game-button-fixed-plus').hide()
			jQuery('.game-button-fixed-minus').hide()
			@gameBoard.setRandomSeed()
			@displayBoard.showGameState(@gameBoard)
			@newGame()

	fixedGameMinus: () =>
		@gameBoard.decrementSeed()
		@newGame()

	fixedGamePlus: () =>
		@gameBoard.incrementSeed()
		@newGame()

	clickCallback: (clickedCardId) =>
		if @hintMode
			# Find a loop
			@getLoop(clickedCardId)
			return
		@exitHintMode()
		# Check if in process of picking a 2
		if @displayBoard.isPick2()
			toCardId = @gameBoard.getCardIdByRowAndCol(@move2ToCell[0], @move2ToCell[1])
			[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveCardIfValid(clickedCardId, toCardId)
			if moveResult == "ok"
				@displayBoard.hidePick2()
				@displayBoard.showGameState(@gameBoard)
				@gameHistory.addToHistory(@gameBoard)
				return
		# console.log "clicked", clickedCardId
		[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveValidCardToEmptyPlace(clickedCardId)
		if moveResult == "ok"
			@displayBoard.hidePick2()
			@displayBoard.showGameState(@gameBoard)
			@gameHistory.addToHistory(@gameBoard)
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
		@hintMode = !@hintMode

	getLoop: (clickedCardId) =>
		loopMoves = @gameSearch.getLoop(@gameBoard, @displayBoard, clickedCardId)
		if loopMoves.length > 0
			@displayBoard.showMoveSequence(loopMoves, 0, 0, false)

	getBest: () =>
		[bestMoveList, bestScore] = @gameSearch.getDynamicTree(@gameBoard, @displayBoard)
		console.log "Best score " + bestScore
		for move in bestMoveList
			console.log "From " + move[0] + " to " + move[1]
		if bestMoveList.length > 0
			@hintMoveIdx = 0
			jQuery('.game-button-play-best').css('visibility', 'visible')
			@displayBoard.showMoveSequence(bestMoveList, bestScore, @hintMoveIdx, false)

	playBest: () =>
		# Check we're in hint mode
		if @hintMoveIdx < 0
			return
		# Get the hint moves
		[bestMoveList, bestScore] = @gameSearch.getBestMoves()
		moveToPlay = bestMoveList[@hintMoveIdx]
		# Make the move
		[moveResult, fromRow, fromCol, toRow, toCol] = @gameBoard.moveCardUsingRowAndColInfo(moveToPlay[0], moveToPlay[1])
		if moveResult == "ok"
			@displayBoard.hidePick2()
			@displayBoard.showGameState(@gameBoard)
			@gameHistory.addToHistory(@gameBoard)
		# Next hint move
		@hintMoveIdx++
		if @hintMoveIdx >= bestMoveList.length
			@exitHintMode()
			return
		@displayBoard.showMoveSequence(bestMoveList, bestScore, @hintMoveIdx, false)

	exitHintMode: () =>
		@hintMode = false
		@hintMoveIdx = -1
		@displayBoard.clearArrows()
		jQuery('.game-button-play-best').css('visibility', 'hidden')

