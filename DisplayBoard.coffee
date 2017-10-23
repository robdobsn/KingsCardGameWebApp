class DisplayBoard

	constructor: (@playingCards, @dragCallback, @clickCallback, @resizeHandler, @basePath, @selectorForPage) ->
		@registerListeners()
		@USE_DRAG_AND_DROP = false
		@rainbow = []
		@arrowBaseIdx = 0

	createArrowColours: (numColours) ->
		for i in [0..numColours]
			@rainbow.push "hsl(#{i*360/numColours},100%,50%)"

	showGameState: (gameBoard) ->
		# Calculate playing area dimensions
		displayWidth = jQuery(@selectorForPage).width() 
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
				cardRank = @playingCards.getCardRank(cardId)
				if cardRank == @playingCards.AceId
					cardFileName = "cards/card_empty.png"
				else
					cardFileName = @basePath + "cards/" + gameBoard.getCardFileName(rowIdx, colIdx)
				jQuery("#row#{rowIdx}").append("<img id='cardid#{cardId}' class='card' width='#{cardWidth}px' height='#{cardHeight}px' src='#{cardFileName}'></img>")
		# Show status
		jQuery('.game-status-box').html("Turn #{gameBoard.turns+1} Score #{gameBoard.getBoardScore()[1]}")
#		console.log "Score " + gameBoard.getBoardScore()
		# Add hooks
		jQuery('.card').click(@onCardClick)
		if @USE_DRAG_AND_DROP
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

	addArrow: (fromPos, toPos, moveIdx) ->
		dString = "M" + fromPos.left + "," + fromPos.top + " " + "L" + toPos.left + "," + toPos.top
		lineColour = if moveIdx < @rainbow.length then @rainbow[moveIdx] else "blue"
		newArrow = jQuery(document.createElementNS("http://www.w3.org/2000/svg", "path")).attr({
        d: dString,
        style: "stroke:#{lineColour}; stroke-width: 3px; fill: none; marker-end: url(#arrow-#{@arrowBaseIdx})"
    })
		jQuery('#arrowOverlay').find("g").append newArrow
		# arrow marker (arrowhead)
		newMarker = document.createElementNS("http://www.w3.org/2000/svg", "marker")
		newMarker.setAttribute("id", "arrow-#{@arrowBaseIdx}")
		newMarker.setAttribute("markerWidth", "10")
		newMarker.setAttribute("markerHeight", "10")
		newMarker.setAttribute("refX", "9")
		newMarker.setAttribute("refY", "6")
		newMarker.setAttribute("orient", "auto")
		newMarkerPath = document.createElementNS("http://www.w3.org/2000/svg", "path")
		newMarkerPath.setAttribute("fill", "#{lineColour}")
		newMarkerPath.setAttribute("d", "M2,1 L2,10 L10,6 L2,2")
		newMarker.appendChild newMarkerPath
		jQuery('#arrowOverlay').find("defs").append newMarker
		@arrowBaseIdx++

	clearArrows: () ->
		@arrowBaseIdx = 0
		jQuery('#arrowOverlay').find("g").empty()
#		jQuery('#arrowOverlay').find("defs").empty()
		jQuery('.hint-info').css('visibility', 'hidden')

	getSVGAreaSize: () ->
		arrowArea = [ jQuery('#gameboard').width(), jQuery('#gameboard').height() ]
		jQuery('#arrowOverlay').width(arrowArea[0])
		jQuery('#arrowOverlay').height(arrowArea[1])
		return arrowArea

	showPossibleMoveArrows: (allPossMoves) ->
		arrowArea = @getSVGAreaSize()
		cardWidth = arrowArea[0]/13
		cardHeight = arrowArea[1]/4
		@clearArrows()
		for startMove,startMoveIdx in allPossMoves
			for movesAtLevel in startMove
				for possMove in movesAtLevel
					fromCentre = {left: possMove[0][1] * cardWidth + cardWidth/2, top: possMove[0][0] * cardHeight + cardHeight/2}
					toCentre = {left: possMove[1][1] * cardWidth + cardWidth/2, top: possMove[1][0] * cardHeight + cardHeight/2}
					@addArrow(fromCentre, toCentre, startMoveIdx)

	showMoveSequence: (moveSequence, bestMoveInfo, fromMoveIdx, isPreview) ->
		arrowArea = @getSVGAreaSize()
		cardWidth = arrowArea[0]/13
		cardHeight = arrowArea[1]/4
		@clearArrows()
		# Reset arrow colours
		@createArrowColours(if isPreview then 30 else moveSequence.length)
		# Create arrows
		for possMove, moveIdx in moveSequence
			if moveIdx < fromMoveIdx
				continue
			fromCentre = {left: possMove[0][1] * cardWidth + cardWidth/2, top: possMove[0][0] * cardHeight + cardHeight/2}
			toCentre = {left: possMove[1][1] * cardWidth + cardWidth/2, top: possMove[1][0] * cardHeight + cardHeight/2}
			@addArrow(fromCentre, toCentre, moveIdx)
		jQuery('.hint-info-box').html("Best factored score #{bestMoveInfo}")
		jQuery('.hint-info').css('visibility', 'visible')
