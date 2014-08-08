class GameBoard
	numRows: 4
	numCols: 13

	constructor: (@playingCards) ->
		@board = []
		@turns = 0

	copy: (copyFrom) ->
		@board = []
		for row in [0..@numRows-1]
			boardRow = []
			for col in [0..@numCols-1]
				boardRow.push copyFrom.board[row][col]
			@board.push boardRow
		@turns = copyFrom.turns
		return true

	deal: () ->
		@board = []
		@playingCards.startDeal()
		for row in [0..@numRows-1]
			boardRow = []
			for col in [0..@numCols-1]
				boardRow.push @playingCards.getNextCard()
			@board.push boardRow
		return true

	removeAces: () ->
		gapCardId = -1
		for rowIdx in [0..@numRows-1]
			for colIdx in [0..@numCols-1]
				cardId = @board[rowIdx][colIdx]
				if @playingCards.getCardInfo(cardId).rankIdx == @playingCards.AceId
					@board[rowIdx][colIdx] = gapCardId
					gapCardId -= 1
	
	redeal: () ->
		# Leave any cards at start of row which are in their correct places
		colsToRedealFrom = []
		for rowIdx in [0..@numRows-1]
			# Find position of first card to be redealt
			suitIdxForRow = -1
			for colIdx in [0..@numCols-1]
				cardId = @board[rowIdx][colIdx]
				cardInfo = @playingCards.getCardInfo(cardId)
				if colIdx == 0
					suitIdxForRow = cardInfo.suitIdx
				if cardInfo.isGap or cardInfo.rankIdx-1 != colIdx or cardInfo.suitIdx != suitIdxForRow
					colsToRedealFrom.push colIdx
					break
			console.log colsToRedealFrom[colsToRedealFrom.length-1]
		# Create deck from remaining cards 
		deck = new PlayingCards()
		deck.empty()
		for rowIdx in [0..@numRows-1]
			for colIdx in [colsToRedealFrom[rowIdx]..@numCols-1]
				cardId = @board[rowIdx][colIdx]
				if cardId >= 0
					deck.addCard(cardId)
		deck.shuffle()
		# Redeal
		deck.startDeal()
		for rowIdx in [0..@numRows-1]
			@board[rowIdx][colsToRedealFrom[rowIdx]] = -rowIdx - 1
			if colsToRedealFrom[rowIdx]+1 < @numCols
				for colIdx in [colsToRedealFrom[rowIdx]+1..@numCols-1]
					cardId = deck.getNextCard()
					if cardId >= 0
						@board[rowIdx][colIdx] = cardId
		@turns += 1
		return true

	getCardId: (rowIdx, colIdx) ->
		return @board[rowIdx][colIdx]

	getCardFileName: (rowIdx, colIdx) ->
		cardId = @board[rowIdx][colIdx]
		return @playingCards.getCardFileName(cardId)

	getCardToLeftInfo: (cardId) ->
		for row, rowIdx in @board
			for chkCardId, cardIdx in row
				if chkCardId == cardId
					if cardIdx == 0
						return [-1, rowIdx, cardIdx]
					return [@board[rowIdx][cardIdx-1],rowIdx,cardIdx]
		return [-2,0,0]

	getLocnOfCard: (cardId) ->
		for row, rowIdx in @board
			for chkCardId, colIdx in row
				if chkCardId == cardId
					return [true, rowIdx, colIdx]
		return [false, 0, 0]

	moveValidCardToEmptyPlace: (toCardId) ->
		if toCardId < 0
			# Get card at cell before clicked one
			[cardToLeftId,clickedRow,clickedCol] = @getCardToLeftInfo(toCardId)
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
				[cardToLeftId,clickedRow,clickedCol] = @getCardToLeftInfo(toCardId)
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
				gapId = @board[toRowIdx][toColIdx]
				@board[toRowIdx][toColIdx] = @board[fromRowIdx][fromColIdx]
				@board[fromRowIdx][fromColIdx] = gapId
				return [ "ok", fromRowIdx, fromColIdx, toRowIdx, toColIdx ]
		return ["none",0,0,0,0]

	getCardName: (cardId) ->

	debugDump: (debugStr) ->
		console.log debugStr
		for row in [0..@numRows-1]
			rowStr = ""
			for col in [0..@numCols-1]
				cardInfo = @playingCards.getCardInfo(@getCardId(row,col))
				rowStr += cardInfo.cardShortName + " "
			console.log rowStr

