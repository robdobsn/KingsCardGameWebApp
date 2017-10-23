class GameBoard
	numRows: 4
	numCols: 13

	constructor: (@playingCards) ->
		@board = []
		@cardLookup = []
		@turns = 0
		@fixForNegativeNos = 4

	clone: () ->
		newBoard = new GameBoard(@playingCards)
		newBoard.board = @board.slice(0)
		newBoard.cardLookup = @cardLookup.slice(0)
		newBoard.turns = @turns
		return newBoard

	copy: (copyFrom) ->
		@board = copyFrom.board.slice(0)
		@cardLookup = copyFrom.cardLookup.slice(0)
		@turns = copyFrom.turns
		return true

	deal: () ->
		@board = []
		@cardLookup = (0 for n in [0..@playingCards.cardsInDeck-1])
		@playingCards.startDeal()
		for idx in [0..@playingCards.cardsInDeck-1]
			cardId = @playingCards.getNextCard()
			@board.push cardId
			@cardLookup[cardId] = idx
		return true

	removeAces: () ->
		gapCardId = -1
		for idx in [0..@playingCards.cardsInDeck-1]
			cardId = @board[idx]
			if @playingCards.getCardInfo(cardId).rankIdx == @playingCards.AceId
				@board[idx] = gapCardId
				gapCardId -= 1
	
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
				if cardInfo.isGap or cardInfo.rankIdx-1 != colIdx or cardInfo.suitIdx != suitIdxForRow
					colsToRedealFrom.push colIdx
					break
#			console.log colsToRedealFrom[colsToRedealFrom.length-1]
		# Create deck from remaining cards 
		deck = new PlayingCards()
		deck.empty()
		for rowIdx in [0..@numRows-1]
			for colIdx in [colsToRedealFrom[rowIdx]..@numCols-1]
				cardId = @board[rowIdx*@numCols+colIdx]
				if cardId >= 0
					deck.addCard(cardId)
		deck.shuffle()
		# Redeal
		deck.startDeal()
		for rowIdx in [0..@numRows-1]
			boardLocnIdx = rowIdx*@numCols+colsToRedealFrom[rowIdx]
			@board[boardLocnIdx] = -rowIdx - 1
			@cardLookup[rowIdx] = boardLocnIdx
			if colsToRedealFrom[rowIdx]+1 < @numCols
				for colIdx in [colsToRedealFrom[rowIdx]+1..@numCols-1]
					cardId = deck.getNextCard()
					if cardId >= 0
						cardLocnIdx = rowIdx*@numCols+colIdx
						@board[cardLocnIdx] = cardId
						@cardLookup[cardId] = cardLocnIdx
		@turns += 1
		return true

	getCardId: (rowIdx, colIdx) ->
		return @board[rowIdx*@numCols+colIdx]

	getCardFileName: (rowIdx, colIdx) ->
		cardId = @board[rowIdx*@numCols+colIdx]
		return @playingCards.getCardFileName(cardId)

	getCardToLeftInfo: (cardId) ->
		if cardId < 0 then cardId += @fixForNegativeNos
		cardLocnIdx = @cardLookup[cardId]
		colIdx = cardLocnIdx % @numCols
		rowIdx = Math.floor(cardLocnIdx / @numRows)
		if colIdx == 0
			return [-1, rowIdx, colIdx,0,0]
		return [@board[rowIdx*@numCols+colIdx-1],rowIdx,colIdx,rowIdx,colIdx-1]

#		 Math.floor (cardId / @cardsInSuit)

#		for rowIdx in [0..@numRows-1]
#			for colIdx in [0..@numCols-1]
#				chkCardId = @board[rowIdx*@numCols+colIdx]
#				if chkCardId == cardId
#					if colIdx == 0
#						return [-1, rowIdx, colIdx,0,0]
#					return [@board[rowIdx*@numCols+colIdx-1],rowIdx,colIdx,rowIdx,colIdx-1]
#		return [-2,0,0,0,0]

	getLocnOfCard: (cardId) ->
		if cardId < 0 then cardId += @fixForNegativeNos
		cardLocnIdx = @cardLookup[cardId]
		colIdx = cardLocnIdx % @numCols
		rowIdx = Math.floor(cardLocnIdx / @numRows)
		return [true, rowIdx, colIdx]

#		for rowIdx in [0..@numRows-1]
#			for colIdx in [0..@numCols-1]
#				chkCardId = @board[rowIdx*@numCols+colIdx]
#				if chkCardId == cardId
#					return [true, rowIdx, colIdx]
#		return [false, 0, 0]

	getEmptySquares: () ->
		emptySqList = []
		for i in [0..@numRows-1]
			cardLocnIdx = @cardLookup[i]
			colIdx = cardLocnIdx % @numCols
			rowIdx = Math.floor(cardLocnIdx / @numRows)
			emptySqList.push [rowIdx, colIdx]
		return emptySqList

#		emptySqList = []
#		for rowIdx in [0..@numRows-1]
#			for colIdx in [0..@numCols-1]
#				chkCardId = @board[rowIdx*@numCols+colIdx]
#				if chkCardId < 0
#					emptySqList.push [rowIdx, colIdx]
#		return emptySqList

	getValidMovesForEmptySq: (toCardId) ->
		validMoves = []
		# Get card at cell before empty one
		[cardToLeftId,spaceRow,spaceCol,cardRow,cardCol] = @getCardToLeftInfo(toCardId)
#		console.log "MovesValid " + toCardId + ", id " + cardToLeftId + ", row " + cardRow + ", col " + cardCol + " card " + @playingCards.getCardInfo(@getCardId(cardRow,cardCol)).cardShortName
		# check if first column
		if cardToLeftId == -1 and spaceCol == 0
			for suitIdx in [0..3]
				cardToMove = @playingCards.getCardId(suitIdx,@playingCards.TwoId)
				if cardToMove >= 0
					cardLocn = @getLocnOfCard(cardToMove)
					if cardLocn[2] != 0  # the 2 cannot be on the first column
						validMoves.push [[cardLocn[1], cardLocn[2]],[spaceRow,spaceCol]]
		#				validMoves.push [@playingCards.getCardId(suitIdx,@playingCards.TwoId), toCardId]
		else if cardToLeftId >= 0
			nextCard = @playingCards.findNextCardInSameSuit(cardToLeftId)
			cardLocn = @getLocnOfCard(nextCard)
			if nextCard >= 0
				validMoves.push [[cardLocn[1], cardLocn[2]],[spaceRow,spaceCol]]
#				validMoves.push [nextCard, toCardId]
		return validMoves

	moveValidCardToEmptyPlace: (toCardId) ->
		if toCardId < 0
			# Get card at cell before clicked one
			[cardToLeftId,clickedRow,clickedCol,cardRow,cardCol] = @getCardToLeftInfo(toCardId)
			# check for click on first column
			if cardToLeftId == -1
				return ["select2",0,0,clickedRow,clickedCol]
			# other space clicked
			if cardToLeftId >= 0
				# Don't accept cards at start of row (or failures)
				fromCardId = @playingCards.findNextCardInSameSuit(cardToLeftId)
				if fromCardId > 0
					return @moveCard(fromCardId, toCardId)
		return ["none",0,0,0,0]

	moveCardIfValid: (fromCardId, toCardId) ->
		if toCardId < 0
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
				cardId = @board[gapLocnIdx] = @board[cardLocnIdx]
				@board[cardLocnIdx] = gapId
				@cardLookup[cardId] = gapLocnIdx
				@cardLookup[gapId+@fixForNegativeNos] = cardLocnIdx
				return [ "ok", fromRowIdx, fromColIdx, toRowIdx, toColIdx ]
		return ["none",0,0,0,0]

	moveCardUsingRowAndColInfo: (fromRowCol, toRowCol) ->
		gapLocnIdx = toRowCol[0]*@numCols+toRowCol[1]
		gapId = @board[gapLocnIdx]
		cardLocnIdx = fromRowCol[0]*@numCols+fromRowCol[1]
		cardId = @board[gapLocnIdx] = @board[cardLocnIdx]
		@board[cardLocnIdx] = gapId
		@cardLookup[cardId] = gapLocnIdx
		@cardLookup[gapId+@fixForNegativeNos] = cardLocnIdx
		return [ "ok", fromRowCol[0], fromRowCol[1], toRowCol[0], toRowCol[1] ]

	getCardName: (cardId) ->

	debugDump: (debugStr) ->
		console.log debugStr
		for row in [0..@numRows-1]
			rowStr = ""
			for col in [0..@numCols-1]
				cardInfo = @playingCards.getCardInfo(@getCardId(row,col))
				rowStr += cardInfo.cardShortName + " "
			console.log rowStr

	getBoardScore: () ->
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
		kingSpaces = 0
		kingLastColumns = 0
		for row in [0..@numRows-1]
			lastCardWasKing = false
			for col in [0..@numCols-1]
				cardId = @getCardId(row,col)
				if @playingCards.getCardRank(cardId) == @playingCards.KingId
					if col == @numCols-1
						kingLastColumns++
					else
						lastCardWasKing = true
				else
					if cardId < 0 and lastCardWasKing
						kingSpaces++
					lastCardWasKing = false
		# Compute factored score
		if completeRows == 4
			factoredScore = 100
		else
			factoredScore = rawScore - kingSpaces + kingLastColumns + completeRows*5
		return [factoredScore, rawScore]
