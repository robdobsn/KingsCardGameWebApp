class DisplayBoard

	constructor: (@playingCards, @dragCallback, @clickCallback, @resizeHandler, @basePath, @selectorForPage) ->
		@registerListeners()

	showGameState: (gameBoard) ->
		# Calculate playing area dimensions
		displayWidth = jQuery(@selectorForPage).width() - 50
		displayHeight = jQuery(@selectorForPage).height()
		cardWidth = displayWidth / gameBoard.numCols
		cardHeight = cardWidth * 1.545
		# Clear the display area
		jQuery('.game-board').html("")
		# Show the cards
		for rowIdx in [0..gameBoard.numRows-1]
			jQuery('.game-board').append("<div class='row' id='row#{rowIdx}'></div>")
			for colIdx in [0..gameBoard.numCols-1]
				cardId = gameBoard.getCardId(rowIdx, colIdx)
				cardFileName = @basePath + "cards/" + gameBoard.getCardFileName(rowIdx, colIdx)
				jQuery("#row#{rowIdx}").append("<img id='cardid#{cardId}' class='card' width='#{cardWidth}px' height='#{cardHeight}px' src='#{cardFileName}'></img>")
		# Add hooks
		jQuery('.card').draggable
			cancel: "a.ui-icon"
			revert: "invalid"
			containment: "document"
			helper: "clone"
			cursor: "move"
			distance: 20
		jQuery('.card').droppable
			accept: ".card"
			activeClass: "ui-state-highlight"
			# over: (event, ui) ->
			# 	console.log "over", ui.draggable, @
			drop: (event, ui) =>
				# console.log "dropped", ui.draggable, @
				# console.log ui.draggable.attr("id")
				# console.log $(@).attr("id")
				fromId = @getIdNumFromIdAttr(ui.draggable)
				toId = @getIdNumFromIdAttr(jQuery(event.target))
				@dragCallback(fromId, toId)
		jQuery('.card').click(@onCardClick)

	getIdNumFromIdAttr: (idElem) ->
		return parseInt(idElem.attr("id")[6..])

	registerListeners: ->
		jQuery(window).resize @resizeHandler
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
		@clickCallback(@getIdNumFromIdAttr(jQuery(event.target)))

	showPick2: () ->
		pickPos = jQuery(@selectorForPage).height() + 100
		console.log "{top:#{pickPos/2}px}"
		jQuery(".click-on-two").css('top',"#{-pickPos/2}px")
		jQuery(".click-on-two").show()

	hidePick2: () ->
		jQuery(".click-on-two").hide()

	isPick2: () ->
		return jQuery(".click-on-two").is(":visible")

