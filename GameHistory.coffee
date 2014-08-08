class GameHistory

	constructor: () ->
		@historyListPos = -1
		@historyList = []

	addToHistory: (board) ->
		copyOfBoard = new GameBoard(board.playingCards)
		copyOfBoard.copy(board)
		if @historyListPos+1 < @historyList.length
			@historyList = @historyList.slice(0,@historyListPos+1)
		@historyList.push copyOfBoard
		@historyListPos += 1

	getPreviousBoard: () ->
		if @historyListPos > 0
			@historyListPos -= 1
			return @historyList[@historyListPos]
		if @historyListPos == 0
			return @historyList[@historyListPos]
		return null

	getNextBoard: () ->
		if @historyListPos < @historyList.length
			if @historyList.length == 0
				return null
			if @historyListPos+1 < @historyList.length
				@historyListPos += 1
			return @historyList[@historyListPos]
		return null
