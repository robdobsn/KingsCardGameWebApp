class PlayingCards
	cardsInDeck: 52
	cardsInSuit: 13
	suitNames: [ 'club', 'diamond', 'heart', 'spade' ]
	shortSuitNames: [ 'C', 'D', 'H', 'S' ]
	rankNames: [ 'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King' ]
	shortRankNames: ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K' ]
	dealNextIdx: 0
	AceId: 0
	TwoId: 1
	KingId: 12
	deck: []

	constructor: () ->
		@deck = @createUnsorted()
		@shuffle()
		# console.log @getCardInfo(cardIdx).cardFileNamePng for cardIdx in @deck

	createUnsorted: () ->
		deck = [0..@cardsInDeck-1]
		return deck

	getCardId: (suitIdx, rankIdx) ->
		return suitIdx * @cardsInSuit + rankIdx

	getCardInfo: (cardId) ->
		if cardId < 0
			cardInfo =
				suitIdx: 0
				suitName: "GAP"
				rankIdx: -cardId
				rankName: (-cardId).toString()
				cardFileNamePng: ""
				cardShortName: "G" + (-cardId).toString()
				isGap: true
			return cardInfo
		if cardId > @cardsInDeck-1 then debugger
		suitIdx = Math.floor (cardId / @cardsInSuit)
		if suitIdx < 0 or suitIdx >= @suitNames.length then debugger
		suitName = @suitNames[suitIdx]
		rankIdx = cardId % @cardsInSuit
		cardInfo =
			suitIdx: suitIdx
			suitName: suitName
			rankIdx: rankIdx
			rankName: @rankNames[rankIdx]
			cardFileNamePng: "card_" + (rankIdx+1) + "_" + suitName + ".png"
			cardShortName: @shortSuitNames[suitIdx] + @shortRankNames[rankIdx]
			isGap: false
		return cardInfo

	getCardFileName: (cardId) ->
		if cardId < 0
			return "card_empty.png"
		return @getCardInfo(cardId).cardFileNamePng

	shuffle: () ->
		# From the end of the list to the beginning, pick element `i`.
		for i in [@deck.length-1..1]
			# Choose random element `j` to the front of `i` to swap with.
			j = Math.floor Math.random() * (i + 1)
			# Swap `j` with `i`, using destructured assignment
			[@deck[i], @deck[j]] = [@deck[j], @deck[i]]
			# Return the shuffled array.
		return true

	startDeal: () ->
		@dealNextIdx = 0

	getNextCard: () ->
		card = @deck[@dealNextIdx]
		@dealNextIdx += 1
		@dealNextIdx = @dealNextIdx % @deck.length
		return card

	findNextCardInSameSuit: (cardId) ->
		cardInfo = @getCardInfo(cardId)
		if cardInfo.rankIdx == @KingId
			return -1
		return cardId + 1

	empty: () ->
		@deck = []

	addCard: (cardId) ->
		@deck.push cardId

