// Generated by CoffeeScript 1.12.7
var PlayingCards;

PlayingCards = (function() {
  PlayingCards.prototype.cardsInDeck = 52;

  PlayingCards.prototype.cardsInSuit = 13;

  PlayingCards.prototype.suitNames = ['club', 'diamond', 'heart', 'spade'];

  PlayingCards.prototype.shortSuitNames = ['C', 'D', 'H', 'S'];

  PlayingCards.prototype.rankNames = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'];

  PlayingCards.prototype.shortRankNames = ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K'];

  PlayingCards.prototype.dealNextIdx = 0;

  PlayingCards.prototype.AceId = 0;

  PlayingCards.prototype.TwoId = 1;

  PlayingCards.prototype.KingId = 12;

  PlayingCards.prototype.deck = [];

  function PlayingCards() {
    this.deck = this.createUnsorted();
    this.shuffle();
  }

  PlayingCards.prototype.createUnsorted = function() {
    var deck, k, ref, results;
    deck = (function() {
      results = [];
      for (var k = 0, ref = this.cardsInDeck - 1; 0 <= ref ? k <= ref : k >= ref; 0 <= ref ? k++ : k--){ results.push(k); }
      return results;
    }).apply(this);
    return deck;
  };

  PlayingCards.prototype.getCardId = function(suitIdx, rankIdx) {
    return suitIdx * this.cardsInSuit + rankIdx;
  };

  PlayingCards.prototype.getCardInfo = function(cardId) {
    var cardInfo, rankIdx, suitIdx, suitName;
    if (cardId < 0) {
      cardInfo = {
        suitIdx: 0,
        suitName: "GAP",
        rankIdx: -cardId,
        rankName: (-cardId).toString(),
        cardFileNamePng: "",
        cardShortName: "G" + (-cardId).toString(),
        isGap: true
      };
      return cardInfo;
    }
    if (cardId > this.cardsInDeck - 1) {
      debugger;
    }
    suitIdx = Math.floor(cardId / this.cardsInSuit);
    if (suitIdx < 0 || suitIdx >= this.suitNames.length) {
      debugger;
    }
    suitName = this.suitNames[suitIdx];
    rankIdx = cardId % this.cardsInSuit;
    cardInfo = {
      suitIdx: suitIdx,
      suitName: suitName,
      rankIdx: rankIdx,
      rankName: this.rankNames[rankIdx],
      cardFileNamePng: "card_" + (rankIdx + 1) + "_" + suitName + ".png",
      cardShortName: this.shortSuitNames[suitIdx] + this.shortRankNames[rankIdx],
      isGap: false
    };
    return cardInfo;
  };

  PlayingCards.prototype.getCardFileName = function(cardId) {
    if (cardId < 0) {
      return "card_empty.png";
    }
    return this.getCardInfo(cardId).cardFileNamePng;
  };

  PlayingCards.prototype.shuffle = function() {
    var i, j, k, ref, ref1;
    for (i = k = ref = this.deck.length - 1; ref <= 1 ? k <= 1 : k >= 1; i = ref <= 1 ? ++k : --k) {
      j = Math.floor(Math.random() * (i + 1));
      ref1 = [this.deck[j], this.deck[i]], this.deck[i] = ref1[0], this.deck[j] = ref1[1];
    }
    return true;
  };

  PlayingCards.prototype.startDeal = function() {
    return this.dealNextIdx = 0;
  };

  PlayingCards.prototype.getNextCard = function() {
    var card;
    card = this.deck[this.dealNextIdx];
    this.dealNextIdx += 1;
    this.dealNextIdx = this.dealNextIdx % this.deck.length;
    return card;
  };

  PlayingCards.prototype.findNextCardInSameSuit = function(cardId) {
    var cardInfo;
    cardInfo = this.getCardInfo(cardId);
    if (cardInfo.rankIdx === this.KingId) {
      return -1;
    }
    return cardId + 1;
  };

  PlayingCards.prototype.empty = function() {
    return this.deck = [];
  };

  PlayingCards.prototype.addCard = function(cardId) {
    return this.deck.push(cardId);
  };

  return PlayingCards;

})();

//# sourceMappingURL=PlayingCards.js.map
