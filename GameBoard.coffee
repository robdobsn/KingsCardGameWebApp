class GameBoard
	numRows: 4
	numCols: 13
	gapCards: [0,13,26,39]

	constructor: () ->
		# Deck of cards - initially empty
		@playingCards = new PlayingCards(false, false)
		# Container for cards - linear array with each row concatenated
		@board = []
		# Reverse lookup
		@cardLookup = []
		# Number of turns
		@turns = 0
		# Score
		@rowScores = [0,0,0,0]
		@score = 0
		# Game seed - allows for repeatable games based on seed numbers -
		# or "random" if a random 32 bit number is used as seed
		@gameSeed = 0

	clone: () ->
		newBoard = new GameBoard()
		newBoard.board = @board.slice(0)
		newBoard.cardLookup = @cardLookup.slice(0)
		newBoard.turns = @turns
		newBoard.rowScores = @rowScores.slice(0)
		newBoard.score = @score
		newBoard.gameSeed = @gameSeed
		return newBoard

	copy: (copyFrom) ->
		@board = copyFrom.board.slice(0)
		@cardLookup = copyFrom.cardLookup.slice(0)
		@turns = copyFrom.turns
		@rowScores = copyFrom.rowScores.slice(0)
		@score = copyFrom.score
		@gameSeed = copyFrom.gameSeed
		return true

	setFixedSeed: (gameNumber) ->
		@gameSeed = gameNumber

	setRandomSeed: () ->
		@gameSeed = 0

	decrementSeed: () ->
		@gameSeed = @gameSeed - 1
		if @gameSeed <= 0
			@gameSeed = 1

	incrementSeed: () ->
		@gameSeed = @gameSeed + 1
		if @gameSeed > @playingCards.maxSeed()
			@gameSeed = @playingCards.maxSeed()

	deal: () ->
		@board = []
		@cardLookup = (0 for n in [0..@playingCards.cardsInDeck-1])
		@playingCards.createUnsorted()
		if @gameSeed == 0
			@gameSeed = @playingCards.getPseudoRandomSeed()
		@playingCards.shuffle(@gameSeed)
		@playingCards.startDeal()
		for idx in [0..@playingCards.cardsInDeck-1]
			cardId = @playingCards.getNextCard()
			@board.push cardId
			@cardLookup[cardId] = idx
		# Recalculate the score
		@recalculateScore()
		return true

	isGap: (cardId) =>
		return @playingCards.isAce(cardId)

	removeAces: () ->
		# Just use the ace values as markers of gaps
		return

	redeal: () ->
		# Leave any cards at start of row which are in their correct places
		colsToRedealFrom = []
		for rowIdx in [0..@numRows-1]
			# Find position of first card to be redealt
			suitIdxForRow = -1
			for colIdx in [0..@numCols-1]
				cardId = @board[rowIdx*@numCols+colIdx]
				cardInfo = @playingCards.getCardInfo(cardId)
				if colIdx == 0
					suitIdxForRow = cardInfo.suitIdx
				if @isGap(cardId) or cardInfo.rankIdx-1 != colIdx or cardInfo.suitIdx != suitIdxForRow
					colsToRedealFrom.push colIdx
					break
#			console.log colsToRedealFrom[colsToRedealFrom.length-1]
		# Create deck from remaining cards
		deck = new PlayingCards(false, false)
		deck.empty()
		for rowIdx in [0..@numRows-1]
			for colIdx in [colsToRedealFrom[rowIdx]..@numCols-1]
				cardId = @board[rowIdx*@numCols+colIdx]
				if not @isGap(cardId)
					deck.addCard(cardId)
		deck.shuffle(@gameSeed)
		# Redeal
		deck.startDeal()
		for rowIdx in [0..@numRows-1]
			boardLocnIdx = rowIdx*@numCols+colsToRedealFrom[rowIdx]
			@board[boardLocnIdx] = @gapCards[rowIdx]
			@cardLookup[@gapCards[rowIdx]] = boardLocnIdx
			if colsToRedealFrom[rowIdx]+1 < @numCols
				for colIdx in [colsToRedealFrom[rowIdx]+1..@numCols-1]
					cardId = deck.getNextCard()
					if cardId >= 0
						boardLocnIdx = rowIdx*@numCols+colIdx
						@board[boardLocnIdx] = cardId
						@cardLookup[cardId] = boardLocnIdx
		@turns += 1
		# Recalculate the score
		@recalculateScore()
		return true

	getCardId: (rowIdx, colIdx) ->
		return @board[rowIdx*@numCols+colIdx]

	getCardFileName: (rowIdx, colIdx) ->
		cardId = @board[rowIdx*@numCols+colIdx]
		return @playingCards.getCardFileName(cardId)

	getCardToLeftInfo: (cardId) ->
		if cardId < 0 or cardId >= @cardLookup.length then debugger
		cardLocn = @cardLookup[cardId]
		rowIdx = Math.floor(cardLocn / @numCols)
		colIdx = cardLocn % @numCols
		if colIdx == 0
			return [-1, rowIdx, colIdx,0,0]
		return [@board[rowIdx*@numCols+colIdx-1],rowIdx,colIdx,rowIdx,colIdx-1]

	getLocnOfCard: (cardId) ->
		if cardId < 0 or cardId >= @cardLookup.length then debugger
		cardLocn = @cardLookup[cardId]
		rowIdx = Math.floor(cardLocn / @numCols)
		colIdx = cardLocn % @numCols
		return [true, rowIdx, colIdx]

	getEmptySquares: () ->
		emptySqList = []
		for mtIdx in [0..3]
			cardLocn = @cardLookup[ @gapCards[mtIdx]]
			rowIdx = Math.floor(cardLocn / @numCols)
			colIdx = cardLocn % @numCols
			emptySqList.push [rowIdx, colIdx]
		return emptySqList

	getValidMovesForEmptySq: (mtIdx) ->
		validMoves = []
		# Get card at cell before empty one
		[cardToLeftId,spaceRow,spaceCol,cardRow,cardCol] = @getCardToLeftInfo(@gapCards[mtIdx])
#		console.log "MovesValid " + toCardId + ", id " + cardToLeftId + ", row " + cardRow + ", col " + cardCol + " card " + @playingCards.getCardInfo(@getCardId(cardRow,cardCol)).cardShortName
		# check if first column
		if cardToLeftId < 0 and spaceCol == 0
			for suitIdx in [0..3]
				cardToMove = @playingCards.getCardId(suitIdx,@playingCards.TwoId)
				if cardToMove >= 0
					cardLocn = @getLocnOfCard(cardToMove)
					if cardLocn[2] != 0  # the 2 cannot be on the first column
						validMoves.push [[cardLocn[1], cardLocn[2]],[spaceRow,spaceCol]]
		#				validMoves.push [@playingCards.getCardId(suitIdx,@playingCards.TwoId), toCardId]
		else if not @isGap(cardToLeftId)
			nextCard = @playingCards.findNextCardInSameSuit(cardToLeftId)
			if nextCard >= 0
				cardLocn = @getLocnOfCard(nextCard)
				validMoves.push [[cardLocn[1], cardLocn[2]],[spaceRow,spaceCol]]
#				validMoves.push [nextCard, toCardId]
		return validMoves

	moveValidCardToEmptyPlace: (toCardId) ->
		if @isGap(toCardId)
			# Get card at cell before clicked one
			[cardToLeftId,clickedRow,clickedCol,cardRow,cardCol] = @getCardToLeftInfo(toCardId)
			# check for click on first column
			if cardToLeftId == -1
				return ["select2",0,0,clickedRow,clickedCol]
			# other space clicked
			if cardToLeftId > 0 and not @isGap(cardToLeftId)
				# Don't accept cards at start of row (or failures)
				fromCardId = @playingCards.findNextCardInSameSuit(cardToLeftId)
				if fromCardId > 0
					return @moveCard(fromCardId, toCardId)
		return ["none",0,0,0,0]

	moveCardIfValid: (fromCardId, toCardId) ->
		if @isGap(toCardId)
			moveOk = false
			if @playingCards.getCardInfo(fromCardId).rankIdx == @playingCards.TwoId
				[ok, toRowIdx, toColIdx] = @getLocnOfCard(toCardId)
				if ok and toColIdx == 0
					moveOk = true
			else
				[cardToLeftId,clickedRow,clickedCol,cardRow,cardCol] = @getCardToLeftInfo(toCardId)
				if cardToLeftId >= 0
					if fromCardId == @playingCards.findNextCardInSameSuit(cardToLeftId)
						moveOk = true
			if moveOk
				return @moveCard(fromCardId, toCardId)
		return ["none",0,0,0,0]

	updateScore: (cardId, fromRowIdx, fromColIdx, gapId, toRowIdx, toColIdx) ->
		# This code relies on the fact that cards are sequentially numbered in each suit
		# and the board array is sequentially indexed for cards in each row
		toBoardPos = toRowIdx*@numCols+toColIdx
		testCardId = cardId
		for col in [toColIdx..@numCols-1]
			if @rowScores[toRowIdx] == col and @board[toBoardPos] == testCardId
				@rowScores[toRowIdx]++
				@score++
				testCardId++
				toBoardPos++
			else
				break
#		# Cross check
#		ckRowScores = @rowScores.slice(0)
#		ckScore = @score
#		@recalculateScore()
#		if @score != ckScore then debugger
#		for rowScore, i in @rowScores
#			if ckRowScores[i] != rowScore then debugger


	moveCard: (fromCardId, toCardId) ->
		[ok, fromRowIdx, fromColIdx] = @getLocnOfCard(fromCardId)
		if ok 
			[ok, toRowIdx, toColIdx] = @getLocnOfCard(toCardId)
			if ok
				gapLocnIdx =toRowIdx*@numCols+toColIdx
				gapId = @board[gapLocnIdx]
				cardLocnIdx = fromRowIdx*@numCols+fromColIdx
				cardId = @board[cardLocnIdx]
				@board[gapLocnIdx] = cardId
				@board[cardLocnIdx] = gapId
				@cardLookup[cardId] = gapLocnIdx
				@cardLookup[gapId] = cardLocnIdx
#				@debugDump ""
#				@checkValidity()
				@updateScore(cardId, fromRowIdx, fromColIdx, gapId, toRowIdx, toColIdx)
				return [ "ok", fromRowIdx, fromColIdx, toRowIdx, toColIdx ]
		return ["none",0,0,0,0]

	moveCardUsingRowAndColInfo: (fromRowCol, toRowCol) ->
		gapLocnIdx = toRowCol[0]*@numCols+toRowCol[1]
		gapId = @board[gapLocnIdx]
		cardLocnIdx = fromRowCol[0]*@numCols+fromRowCol[1]
		cardId = @board[cardLocnIdx]
		@board[gapLocnIdx] = cardId
		@board[cardLocnIdx] = gapId
		@cardLookup[cardId] = gapLocnIdx
		@cardLookup[gapId] = cardLocnIdx
		@updateScore(cardId, fromRowCol[0], fromRowCol[1], gapId, toRowCol[0], toRowCol[1])
		return [ "ok", fromRowCol[0], fromRowCol[1], toRowCol[0], toRowCol[1] ]

	getCardName: (cardId) ->
			cardInfo = @playingCards.getCardInfo(cardId)
			if @isGap(cardId)
				return "GP"
			return cardInfo.cardShortName

	recalculateScore: () ->
		# Cards in sequence
		fullScore = 0
		completeRows = 0
		for row in [0..@numRows-1]
			rowScore = 0
			rowSuit = -1
			for col in [0..@numCols-1]
				cardId = @getCardId(row,col)
				if col == 0
					if @playingCards.getCardRank(cardId) == @playingCards.TwoId
						rowSuit = @playingCards.getCardSuit(cardId)
						rowScore++
					else
						break
				else
					if @playingCards.getCardRank(cardId) == col+1 and @playingCards.getCardSuit(cardId) == rowSuit
						rowScore++
						if col == @numCols-1
							completeRows++
					else
						break
			@rowScores[row] = rowScore
			fullScore += rowScore
		@score = fullScore
		return fullScore

	getScore: () ->
		return @score

	debugDump: (debugStr) ->
		console.log debugStr
		for row in [0..@numRows-1]
			rowStr = ""
			for col in [0..@numCols-1]
				cardId = @getCardId(row,col)
				rowStr += @getCardName(cardId) + " "
			console.log rowStr
		rowStr = ""
		for i in [0..51]
			rowStr += ("00" + @cardLookup[i]).substr(-2,2) + " "
		console.log rowStr
		rowStr = ""
		for i in [0..51]
			rowStr += @getCardName(i) + " "
		console.log rowStr

	checkValidity: () ->
		for cardId in [0..@playingCards.cardsInDeck-1]
			cardLocn = @cardLookup[cardId]
			if @board[cardLocn] != cardId
				cardStr = @getCardName(cardId)
				console.log "Mismatch cardId " + cardStr + " <> locn " + cardLocn

