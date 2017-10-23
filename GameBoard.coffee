class GameBoard

	constructor: (@playingCards) ->
		@gapCards = (s*@playingCards.cardsInSuit+@playingCards.AceId for s in [0..3])
		@board = []
		@turns = 0
		@numRows = 4
		@numCols = 13

	clone: () ->
		newBoard = new GameBoard(@playingCards)
		newBoard.board = @board.slice(0)
		newBoard.turns = @turns
		return newBoard

	copy: (copyFrom) ->
		@board = copyFrom.board.slice(0)
		@turns = copyFrom.turns
		return true

	deal: () ->
		@board = []
		@playingCards.startDeal()
		for idx in [0..@playingCards.cardsInDeck-1]
			@board.push @playingCards.getNextCard()
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
			@board[rowIdx*@numCols+colsToRedealFrom[rowIdx]] = @gapCards[rowIdx]
			if colsToRedealFrom[rowIdx]+1 < @numCols
				for colIdx in [colsToRedealFrom[rowIdx]+1..@numCols-1]
					cardId = deck.getNextCard()
					if cardId >= 0
						@board[rowIdx*@numCols+colIdx] = cardId
		@turns += 1
		return true

	getCardId: (rowIdx, colIdx) ->
		return @board[rowIdx*@numCols+colIdx]

	getCardFileName: (rowIdx, colIdx) ->
		cardId = @board[rowIdx*@numCols+colIdx]
		return @playingCards.getCardFileName(cardId)

	getCardToLeftInfo: (cardId) ->
		for rowIdx in [0..@numRows-1]
			for colIdx in [0..@numCols-1]
				chkCardId = @board[rowIdx*@numCols+colIdx]
				if chkCardId == cardId
					if colIdx == 0
						return [-1, rowIdx, colIdx,0,0]
					return [@board[rowIdx*@numCols+colIdx-1],rowIdx,colIdx,rowIdx,colIdx-1]
		return [-2,0,0,0,0]

	getLocnOfCard: (cardId) ->
		for rowIdx in [0..@numRows-1]
			for colIdx in [0..@numCols-1]
				chkCardId = @board[rowIdx*@numCols+colIdx]
				if chkCardId == cardId
					return [true, rowIdx, colIdx]
		return [false, 0, 0]

	getEmptySquares: () ->
		emptySqList = []
		for rowIdx in [0..@numRows-1]
			for colIdx in [0..@numCols-1]
				chkCardId = @board[rowIdx*@numCols+colIdx]
				if @isGap(chkCardId)
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
			cardLocn = @getLocnOfCard(nextCard)
			if nextCard >= 0
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
			if cardToLeftId >= 0
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
				gapId = @board[toRowIdx*@numCols+toColIdx]
				@board[toRowIdx*@numCols+toColIdx] = @board[fromRowIdx*@numCols+fromColIdx]
				@board[fromRowIdx*@numCols+fromColIdx] = gapId
				return [ "ok", fromRowIdx, fromColIdx, toRowIdx, toColIdx ]
		return ["none",0,0,0,0]

	moveCardUsingRowAndColInfo: (fromRowCol, toRowCol) ->
		gapId = @board[toRowCol[0]*@numCols+toRowCol[1]]
		@board[toRowCol[0]*@numCols+toRowCol[1]] = @board[fromRowCol[0]*@numCols+fromRowCol[1]]
		@board[fromRowCol[0]*@numCols+fromRowCol[1]] = gapId
		return [ "ok", fromRowCol[0], fromRowCol[1], toRowCol[0], toRowCol[1] ]

	getCardName: (cardId) ->

	debugDump: (debugStr) ->
		console.log debugStr
		for row in [0..@numRows-1]
			rowStr = ""
			for col in [0..@numCols-1]
				cardId = @getCardId(row,col)
				cardInfo = @playingCards.getCardInfo(cardId)
				if @isGap(cardId)
					rowStr += "G" + " "
				else
					rowStr += cardInfo.cardShortName + " "
			console.log rowStr

	getBoardScore: () ->
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
		# Spaces behind king
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
					if @playingCards.getCardRank(cardId) == @playingCards.AceId and lastCardWasKing
						kingSpaces++
					lastCardWasKing = false
		# Compute factored score
		if completeRows == 4
			factoredScore = 100
		else
			factoredScore = rawScore - kingSpaces + kingLastColumns + completeRows*5
		return [factoredScore, rawScore]
