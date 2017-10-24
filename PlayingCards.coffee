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

	constructor: (create=true, shuffle=true) ->
		if create
			@createUnsorted()
		if shuffle
			@shuffle()
		# console.log @getCardInfo(cardIdx).cardFileNamePng for cardIdx in @deck

	getPseudoRandomSeed: () ->
		pseudoRandom = new PseudoRandom(0)
		return pseudoRandom.getRandomSeed()

	maxSeed: () ->
		pseudoRandom = new PseudoRandom(0)
		return pseudoRandom.getMaxSeed()

	createUnsorted: () ->
		@deck = [0..@cardsInDeck-1]

	getCardId: (suitIdx, rankIdx) ->
		return suitIdx * @cardsInSuit + rankIdx

	getCardInfo: (cardId) ->
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
		return cardInfo

	getCardFileName: (cardId) ->
		return @getCardInfo(cardId).cardFileNamePng

	shuffle: (randomSeed = 0) ->
		# From the end of the list to the beginning, pick element `i`.
		pseudoRandom = new PseudoRandom(randomSeed)
		for i in [@deck.length-1..1]
			# Choose random element `j` to the front of `i` to swap with.
			#j = Math.floor pseudoRandom.next() * (i + 1)
			j = Math.floor pseudoRandom.nextFloat() * (i + 1)
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

	getCardRank: (cardId) ->
		return cardId % @cardsInSuit

	getCardSuit: (cardId) ->
		return Math.floor (cardId / @cardsInSuit)

	isAce: (cardId) ->
		return (cardId % @cardsInSuit) == @AceId

