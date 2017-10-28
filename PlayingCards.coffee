class PlayingCards
	# Class variables
	@cardsInDeck: 52
	@cardsInSuit: 13
	@suitNames: [ 'club', 'diamond', 'heart', 'spade' ]
	@shortSuitNames: [ 'C', 'D', 'H', 'S' ]
	@rankNames: [ 'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King' ]
	@shortRankNames: ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K' ]
	@AceId: 0
	@TwoId: 1
	@KingId: 12
	# Instance variables
	dealNextIdx: 0
	deck: []

	####################################################
	# Instance methods
	constructor: (create=true, shuffle=true) ->
		if create
			@createUnsorted()
		if shuffle
			@shuffle()
		# console.log @getCardInfo(cardIdx).cardFileNamePng for cardIdx in @deck

	empty: () ->
		@deck = []

	createUnsorted: () ->
		@deck = [0..PlayingCards.cardsInDeck-1]

	addCard: (cardId) ->
		@deck.push cardId

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

	dealNextCard: () ->
		card = @deck[@dealNextIdx]
		@dealNextIdx += 1
		@dealNextIdx = @dealNextIdx % @deck.length
		return card

	####################################################
	# Class Methods
	@getPseudoRandomSeed: () ->
		return PseudoRandom.getRandomSeed()

	@maxSeed: () ->
		return PseudoRandom.getMaxSeed()

	@getCardIdBySuitAndRank: (suitIdx, rankIdx) ->
		return suitIdx * PlayingCards.cardsInSuit + rankIdx

	@getCardRank: (cardId) ->
		return cardId % PlayingCards.cardsInSuit

	@getCardSuit: (cardId) ->
		return Math.floor (cardId / PlayingCards.cardsInSuit)

	@isAce: (cardId) ->
		return (cardId % PlayingCards.cardsInSuit) == PlayingCards.AceId

	@getCardInfo: (cardId) ->
		if cardId > PlayingCards.cardsInDeck-1 then debugger
		suitIdx = Math.floor (cardId / PlayingCards.cardsInSuit)
		if suitIdx < 0 or suitIdx >= PlayingCards.suitNames.length then debugger
		suitName = PlayingCards.suitNames[suitIdx]
		rankIdx = cardId % PlayingCards.cardsInSuit
		cardInfo =
			suitIdx: suitIdx
			suitName: suitName
			rankIdx: rankIdx
			rankName: PlayingCards.rankNames[rankIdx]
			cardFileNamePng: "card_" + (rankIdx+1) + "_" + suitName + ".png"
			cardShortName: PlayingCards.shortSuitNames[suitIdx] + PlayingCards.shortRankNames[rankIdx]
		return cardInfo

	@getCardFileName: (cardId) ->
		return @getCardInfo(cardId).cardFileNamePng

	@findPrevCardInSameSuit: (cardId) ->
		if @getCardRank(cardId) == PlayingCards.AceId
			return -1
		return cardId - 1

	@findNextCardInSameSuit: (cardId) ->
		if @getCardRank(cardId) == PlayingCards.KingId
			return -1
		return cardId + 1
