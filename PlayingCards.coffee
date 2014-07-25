class PlayingCards
	cardsInDeck: 52
	cardsInSuit: 13
	suitNames: [ 'club', 'diamond', 'heart', 'spade' ]
	rankNames: [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King' ]
	dealNextIdx: 0
	AceId: 0
	TwoId: 1
	KingId: 12

	constructor: () ->
		@deck = @createUnsorted()
		@deck = @shuffle(@deck)
		# console.log @getCardInfo(cardIdx).cardFileNamePng for cardIdx in @deck

	createUnsorted: () ->
		deck = [0..@cardsInDeck-1]
		return deck

	getCardInfo: (cardId) ->
		suitIdx = Math.floor (cardId / @cardsInSuit)
		suitName = @suitNames[suitIdx]
		rankIdx = cardId % @cardsInSuit
		cardInfo =
			suitIdx: suitIdx
			suitName: suitName
			rankIdx: rankIdx
			rankName: @rankNames[rankIdx]
			cardFileNameSvg: "card_" + (rankIdx+1) + "_" + suitName + ".svg"
			cardFileNamePng: "card_" + (rankIdx+1) + "_" + suitName + ".png"
		return cardInfo

	getCardFileName: (cardId, useSvg) ->
		if cardId < 0
			return "card_empty" + if useSvg then ".svg" else ".png"
		if useSvg
			return @getCardInfo(cardId).cardFileNameSvg
		return @getCardInfo(cardId).cardFileNamePng

	shuffle: (deck) ->
		# From the end of the list to the beginning, pick element `i`.
		for i in [deck.length-1..1]
			# Choose random element `j` to the front of `i` to swap with.
			j = Math.floor Math.random() * (i + 1)
			# Swap `j` with `i`, using destructured assignment
			[deck[i], deck[j]] = [deck[j], deck[i]]
			# Return the shuffled array.
		return deck

	startDeal: () ->
		@dealNextIdx = 0

	getNextCard: () ->
		card = @deck[@dealNextIdx]
		@dealNextIdx += 1
		@dealNextIdx = @dealNextIdx % @cardsInDeck
		return card

	findNextCardInSameSuit: (cardId) ->
		cardInfo = @getCardInfo(cardId)
		if cardInfo.rankIdx == @KingId
			return -1
		return cardId + 1
