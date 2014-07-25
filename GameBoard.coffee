class GameBoard
	numRows: 4
	numCols: 13

	constructor: (@playingCards) ->
		@board = []

	deal: (deck) ->
		@board = []
		deck.startDeal()
		for row in [0..@numRows-1]
			boardRow = []
			for col in [0..@numCols-1]
				boardRow.push deck.getNextCard()
			@board.push boardRow
		return true

	getBoard: () ->
		return @board

	getCardToLeftInfo: (cardId) ->
		for row, rowIdx in @board
			for chkCardId, cardIdx in row
				if chkCardId == cardId
					if cardIdx == 0
						return -1
					return @board[rowIdx][cardIdx-1]
		return -2

	getLocnOfCard: (cardId) ->
		for row, rowIdx in @board
			for chkCardId, colIdx in row
				if chkCardId == cardId
					return [true, rowIdx, colIdx]
		return [false, 0, 0]

	moveValidCardToEmptyPlace: (toCardId) ->
		if toCardId < 0
			# Get card at cell before clicked one
			cardToLeftId = @getCardToLeftInfo(toCardId)
			if cardToLeftId >= 0
				# Don't accept cards at start of row (or failures)
				fromCardId = @playingCards.findNextCardInSameSuit(cardToLeftId)
				if fromCardId > 0
					return @moveCard(fromCardId, toCardId)
		return [ false,0,0,0,0 ]

	moveCardIfValid: (fromCardId, toCardId) ->
		if toCardId < 0
			moveOk = false
			if @playingCards.getCardInfo(fromCardId).rankIdx == @playingCards.TwoId
				[ok, toRowIdx, toColIdx] = @getLocnOfCard(toCardId)
				if ok and toColIdx == 0
					moveOk = true
			else
				cardToLeftId = @getCardToLeftInfo(toCardId)
				if cardToLeftId >= 0
					if fromCardId == @playingCards.findNextCardInSameSuit(cardToLeftId)
						moveOk = true
			if moveOk
				return @moveCard(fromCardId, toCardId)
		return [ false,0,0,0,0 ]

	moveCard: (fromCardId, toCardId) ->
		[ok, fromRowIdx, fromColIdx] = @getLocnOfCard(fromCardId)
		if ok 
			[ok, toRowIdx, toColIdx] = @getLocnOfCard(toCardId)
			if ok
				gapId = @board[toRowIdx][toColIdx]
				@board[toRowIdx][toColIdx] = @board[fromRowIdx][fromColIdx]
				@board[fromRowIdx][fromColIdx] = gapId
				return [ true, fromRowIdx, fromColIdx, toRowIdx, toColIdx ]
		return [ false,0,0,0,0 ]

