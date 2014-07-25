class DisplayBoard

	constructor: (@selCellCallback, @dragCallback, @selCompleteCallback, @clickCallback, @playingCards, @useSvg) ->
		@registerListeners()

	showGameState: (gameBoard) ->
		displayWidth = $(window).width() - 50
		displayHeight = $(window).height()
		cardWidth = displayWidth / gameBoard.numCols
		cardHeight = cardWidth * 1.545
		$('.game-board').html("")
		board = gameBoard.getBoard()
		for row,rowIdx in board
			$('.game-board').append("<div class='row' id='row#{rowIdx}'></div>")
			for cardId in row
				cardFileName = @playingCards.getCardFileName(cardId, @useSvg)
				if @useSvg
					$("#row#{rowIdx}").append("<object type='image/svg+xml' id='cardid#{cardId}' width='50' height='80' data='cards/#{cardFileName}'></object>")
				else
					$("#row#{rowIdx}").append("<img id='cardid#{cardId}' class='card' width='#{cardWidth}px' height='#{cardHeight}px' src='cards/#{cardFileName}'></img>")
		$('.card').draggable
			cancel: "a.ui-icon"
			revert: "invalid"
			containment: "document"
			helper: "clone"
			cursor: "move"
		$('.card').droppable
			accept: ".card"
			activeClass: "ui-state-highlight"
			# over: (event, ui) ->
			# 	console.log "over", ui.draggable, @
			drop: (event, ui) =>
				# console.log "dropped", ui.draggable, @
				# console.log ui.draggable.attr("id")
				# console.log $(@).attr("id")
				fromId = @getIdNumFromIdAttr(ui.draggable)
				toId = @getIdNumFromIdAttr($(event.target))
				@dragCallback(fromId, toId)
		$('.card').click(@onCardClick)

	getIdNumFromIdAttr: (idElem) ->
		return parseInt(idElem.attr("id")[6..])

	registerListeners: ->
		return
		document.addEventListener "mousemove", @onMousemove, (false)
		document.addEventListener "mousedown", @onMousedown, (false)
		document.addEventListener "mouseup", @onMouseup, (false)

	onMousemove: (event) =>
		event.preventDefault()

	onMousedown: (event) =>
		event.preventDefault()

	onMouseup: (event) =>
		event.preventDefault()

	onCardClick: (event) =>
		# console.log event.target
		@clickCallback(@getIdNumFromIdAttr($(event.target)))

