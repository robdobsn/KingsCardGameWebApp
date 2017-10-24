class GameBoard
	numRows: 4
	numCols: 13
	gapCards: [0,13,26,39]

	constructor: (@playingCards) ->
		@board = []
		@cardLookup = []
		@turns = 0
		@score = 0

	clone: () ->
		newBoard = new GameBoard(@playingCards)
		newBoard.board = @board.slice(0)
		newBoard.cardLookup = @cardLookup.slice(0)
		newBoard.turns = @turns
		newBoard.score = @score
		return newBoard

	copy: (copyFrom) ->
		@board = copyFrom.board.slice(0)
		@cardLookup = copyFrom.cardLookup.slice(0)
		@turns = copyFrom.turns
		@score = copyFrom.score
		return true

	deal: () ->
		@board = []
		@cardLookup = (0 for n in [0..@playingCards.cardsInDeck-1])
		@playingCards.startDeal()
		for idx in [0..@playingCards.cardsInDeck-1]
			cardId = @playingCards.getNextCard()
			@board.push cardId
			@cardLookup[cardId] = idx
		@score = @getScore()
		return true

	isGap: (cardId) =>
		return @playingCards.isAce(cardId)

	removeAces: () ->
		# Just use the ace values as markers of gaps
		return
#		gapCardId = -1
#		for idx in [0..@playingCards.cardsInDeck-1]
#			cardId = @board[idx]
#			if @playingCards.getCardInfo(cardId).rankIdx == @playingCards.AceId
#				@board[idx] = gapCardId
#				gapCardId -= 1
	
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
		deck = new PlayingCards()
		deck.empty()
		for rowIdx in [0..@numRows-1]
			for colIdx in [colsToRedealFrom[rowIdx]..@numCols-1]
				cardId = @board[rowIdx*@numCols+colIdx]
				if not @isGap(cardId)
					deck.addCard(cardId)
		deck.shuffle()
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
		@score = @getScore()
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

#	getCardToLeftInfo: (cardId) ->
#		for rowIdx in [0..@numRows-1]
#			for colIdx in [0..@numCols-1]
#				chkCardId = @board[rowIdx*@numCols+colIdx]
#				if chkCardId == cardId
#					if colIdx == 0
#						return [-1, rowIdx, colIdx,0,0]
#					return [@board[rowIdx*@numCols+colIdx-1],rowIdx,colIdx,rowIdx,colIdx-1]
#		return [-2,0,0,0,0]

	getLocnOfCard: (cardId) ->
		if cardId < 0 or cardId >= @cardLookup.length then debugger
		cardLocn = @cardLookup[cardId]
		rowIdx = Math.floor(cardLocn / @numCols)
		colIdx = cardLocn % @numCols
		return [true, rowIdx, colIdx]

#	getLocnOfCard: (cardId) ->
#		for rowIdx in [0..@numRows-1]
#			for colIdx in [0..@numCols-1]
#				chkCardId = @board[rowIdx*@numCols+colIdx]
#				if chkCardId == cardId
#					return [true, rowIdx, colIdx]
#		return [false, 0, 0]

	getEmptySquares: () ->
		emptySqList = []
		for mtIdx in [0..3]
			cardLocn = @cardLookup[ @gapCards[mtIdx]]
			rowIdx = Math.floor(cardLocn / @numCols)
			colIdx = cardLocn % @numCols
			emptySqList.push [rowIdx, colIdx]
		return emptySqList

#	getEmptySquares: () ->
#		emptySqList = []
#		for rowIdx in [0..@numRows-1]
#			for colIdx in [0..@numCols-1]
#				chkCardId = @board[rowIdx*@numCols+colIdx]
#				if @isGap(chkCardId)
#					emptySqList.push [rowIdx, colIdx]
#		return emptySqList

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
		return [ "ok", fromRowCol[0], fromRowCol[1], toRowCol[0], toRowCol[1] ]

	getCardName: (cardId) ->
			cardInfo = @playingCards.getCardInfo(cardId)
			if @isGap(cardId)
				return "GP"
			return cardInfo.cardShortName

#	getBoardScore: () ->
#		# Cards in sequence
#		rawScore = 0
#		completeRows = 0
#		for row in [0..@numRows-1]
#			rowSuit = -1
#			for col in [0..@numCols-1]
#				cardId = @getCardId(row,col)
#				if col == 0
#					if @playingCards.getCardRank(cardId) == @playingCards.TwoId
#						rowSuit = @playingCards.getCardSuit(cardId)
#						rawScore++
#					else
#						break
#				else
#					if @playingCards.getCardRank(cardId) == col+1 and @playingCards.getCardSuit(cardId) == rowSuit
#						rawScore++
#						if col == @numCols-1
#							completeRows++
#					else
#						break
#		# Spaces behind king
#		kingSpaces = 0
#		kingLastColumns = 0
#		for row in [0..@numRows-1]
#			lastCardWasKing = false
#			for col in [0..@numCols-1]
#				cardId = @getCardId(row,col)
#				if @playingCards.getCardRank(cardId) == @playingCards.KingId
#					if col == @numCols-1
#						kingLastColumns++
#					else
#						lastCardWasKing = true
#				else
#					if @playingCards.getCardRank(cardId) == @playingCards.AceId and lastCardWasKing
#						kingSpaces++
#					lastCardWasKing = false
#		# Compute factored score
#		if completeRows == 4
#			factoredScore = 100
#		else
#			factoredScore = rawScore - kingSpaces + kingLastColumns + completeRows*5
#		return [factoredScore, rawScore]

	getScore: () ->
		# Cards in sequence
		rawScore = 0
		completeRows = 0
		for row in [0..@numRows-1]
			rowSuit = -1
			for col in [0..@numCols-1]
				cardId = @getCardId(row,col)
				if col == 0
					if @playingCards.getCardRank(cardId) == @playingCards.TwoId
						rowSuit = @playingCards.getCardSuit(cardId)
						rawScore++
					else
						break
				else
					if @playingCards.getCardRank(cardId) == col+1 and @playingCards.getCardSuit(cardId) == rowSuit
						rawScore++
						if col == @numCols-1
							completeRows++
					else
						break
		return rawScore

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

