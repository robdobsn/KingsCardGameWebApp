// Generated by CoffeeScript 1.12.7
var GameBoard,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

GameBoard = (function() {
  GameBoard.prototype.numRows = 4;

  GameBoard.prototype.numCols = 13;

  GameBoard.prototype.gapCards = [0, 13, 26, 39];

  function GameBoard() {
    this.isGap = bind(this.isGap, this);
    this.playingCards = new PlayingCards(false, false);
    this.board = [];
    this.cardLookup = [];
    this.turns = 0;
    this.rowScores = [0, 0, 0, 0];
    this.score = 0;
    this.gameSeed = 0;
  }

  GameBoard.prototype.clone = function() {
    var newBoard;
    newBoard = new GameBoard();
    newBoard.board = this.board.slice(0);
    newBoard.cardLookup = this.cardLookup.slice(0);
    newBoard.turns = this.turns;
    newBoard.rowScores = this.rowScores.slice(0);
    newBoard.score = this.score;
    newBoard.gameSeed = this.gameSeed;
    return newBoard;
  };

  GameBoard.prototype.copy = function(copyFrom) {
    this.board = copyFrom.board.slice(0);
    this.cardLookup = copyFrom.cardLookup.slice(0);
    this.turns = copyFrom.turns;
    this.rowScores = copyFrom.rowScores.slice(0);
    this.score = copyFrom.score;
    this.gameSeed = copyFrom.gameSeed;
    return true;
  };

  GameBoard.prototype.setFixedSeed = function(gameNumber) {
    return this.gameSeed = gameNumber;
  };

  GameBoard.prototype.setRandomSeed = function() {
    return this.gameSeed = 0;
  };

  GameBoard.prototype.decrementSeed = function() {
    this.gameSeed = this.gameSeed - 1;
    if (this.gameSeed <= 0) {
      return this.gameSeed = 1;
    }
  };

  GameBoard.prototype.incrementSeed = function() {
    this.gameSeed = this.gameSeed + 1;
    if (this.gameSeed > PlayingCards.maxSeed()) {
      return this.gameSeed = PlayingCards.maxSeed();
    }
  };

  GameBoard.prototype.deal = function() {
    var cardId, idx, j, n, ref;
    this.board = [];
    this.cardLookup = (function() {
      var j, ref, results;
      results = [];
      for (n = j = 0, ref = PlayingCards.cardsInDeck - 1; 0 <= ref ? j <= ref : j >= ref; n = 0 <= ref ? ++j : --j) {
        results.push(0);
      }
      return results;
    })();
    this.playingCards.createUnsorted();
    if (this.gameSeed === 0) {
      this.gameSeed = PlayingCards.getPseudoRandomSeed();
    }
    this.playingCards.shuffle(this.gameSeed);
    this.playingCards.startDeal();
    for (idx = j = 0, ref = PlayingCards.cardsInDeck - 1; 0 <= ref ? j <= ref : j >= ref; idx = 0 <= ref ? ++j : --j) {
      cardId = this.playingCards.dealNextCard();
      this.board.push(cardId);
      this.cardLookup[cardId] = idx;
    }
    this.recalculateScore();
    return true;
  };

  GameBoard.prototype.isGap = function(cardId) {
    return PlayingCards.isAce(cardId);
  };

  GameBoard.prototype.removeAces = function() {};

  GameBoard.prototype.redeal = function() {
    var boardLocnIdx, cardId, cardInfo, colIdx, colsToRedealFrom, deck, j, k, l, m, o, p, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, rowIdx, suitIdxForRow;
    colsToRedealFrom = [];
    for (rowIdx = j = 0, ref = this.numRows - 1; 0 <= ref ? j <= ref : j >= ref; rowIdx = 0 <= ref ? ++j : --j) {
      suitIdxForRow = -1;
      for (colIdx = k = 0, ref1 = this.numCols - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; colIdx = 0 <= ref1 ? ++k : --k) {
        cardId = this.board[rowIdx * this.numCols + colIdx];
        cardInfo = PlayingCards.getCardInfo(cardId);
        if (colIdx === 0) {
          suitIdxForRow = cardInfo.suitIdx;
        }
        if (this.isGap(cardId) || cardInfo.rankIdx - 1 !== colIdx || cardInfo.suitIdx !== suitIdxForRow) {
          colsToRedealFrom.push(colIdx);
          break;
        }
      }
    }
    deck = new PlayingCards(false, false);
    deck.empty();
    for (rowIdx = l = 0, ref2 = this.numRows - 1; 0 <= ref2 ? l <= ref2 : l >= ref2; rowIdx = 0 <= ref2 ? ++l : --l) {
      for (colIdx = m = ref3 = colsToRedealFrom[rowIdx], ref4 = this.numCols - 1; ref3 <= ref4 ? m <= ref4 : m >= ref4; colIdx = ref3 <= ref4 ? ++m : --m) {
        cardId = this.board[rowIdx * this.numCols + colIdx];
        if (!this.isGap(cardId)) {
          deck.addCard(cardId);
        }
      }
    }
    deck.shuffle(this.gameSeed);
    deck.startDeal();
    for (rowIdx = o = 0, ref5 = this.numRows - 1; 0 <= ref5 ? o <= ref5 : o >= ref5; rowIdx = 0 <= ref5 ? ++o : --o) {
      boardLocnIdx = rowIdx * this.numCols + colsToRedealFrom[rowIdx];
      this.board[boardLocnIdx] = this.gapCards[rowIdx];
      this.cardLookup[this.gapCards[rowIdx]] = boardLocnIdx;
      if (colsToRedealFrom[rowIdx] + 1 < this.numCols) {
        for (colIdx = p = ref6 = colsToRedealFrom[rowIdx] + 1, ref7 = this.numCols - 1; ref6 <= ref7 ? p <= ref7 : p >= ref7; colIdx = ref6 <= ref7 ? ++p : --p) {
          cardId = deck.dealNextCard();
          if (cardId >= 0) {
            boardLocnIdx = rowIdx * this.numCols + colIdx;
            this.board[boardLocnIdx] = cardId;
            this.cardLookup[cardId] = boardLocnIdx;
          }
        }
      }
    }
    this.turns += 1;
    this.recalculateScore();
    return true;
  };

  GameBoard.prototype.getCardIdByRowAndCol = function(rowIdx, colIdx) {
    return this.board[rowIdx * this.numCols + colIdx];
  };

  GameBoard.prototype.getCardFileName = function(rowIdx, colIdx) {
    var cardId;
    cardId = this.board[rowIdx * this.numCols + colIdx];
    return PlayingCards.getCardFileName(cardId);
  };

  GameBoard.prototype.getCardToLeftInfo = function(cardId) {
    var cardLocn, colIdx, rowIdx;
    if (cardId < 0 || cardId >= this.cardLookup.length) {
      debugger;
    }
    cardLocn = this.cardLookup[cardId];
    rowIdx = Math.floor(cardLocn / this.numCols);
    colIdx = cardLocn % this.numCols;
    if (colIdx === 0) {
      return [-1, rowIdx, colIdx, 0, 0];
    }
    return [this.board[rowIdx * this.numCols + colIdx - 1], rowIdx, colIdx, rowIdx, colIdx - 1];
  };

  GameBoard.prototype.getCardToRightInfo = function(cardId) {
    var cardLocn, colIdx, rowIdx;
    if (cardId < 0 || cardId >= this.cardLookup.length) {
      debugger;
    }
    cardLocn = this.cardLookup[cardId];
    rowIdx = Math.floor(cardLocn / this.numCols);
    colIdx = cardLocn % this.numCols;
    if (colIdx === this.numCols - 1) {
      return [-1, rowIdx, colIdx, 0, 0];
    }
    return [this.board[rowIdx * this.numCols + colIdx + 1], rowIdx, colIdx, rowIdx, colIdx + 1];
  };

  GameBoard.prototype.getLocnOfCard = function(cardId) {
    var cardLocn, colIdx, rowIdx;
    if (cardId < 0 || cardId >= this.cardLookup.length) {
      debugger;
    }
    cardLocn = this.cardLookup[cardId];
    rowIdx = Math.floor(cardLocn / this.numCols);
    colIdx = cardLocn % this.numCols;
    return [true, rowIdx, colIdx];
  };

  GameBoard.prototype.getEmptySquares = function() {
    var cardLocn, colIdx, emptySqList, j, mtIdx, rowIdx;
    emptySqList = [];
    for (mtIdx = j = 0; j <= 3; mtIdx = ++j) {
      cardLocn = this.cardLookup[this.gapCards[mtIdx]];
      rowIdx = Math.floor(cardLocn / this.numCols);
      colIdx = cardLocn % this.numCols;
      emptySqList.push([rowIdx, colIdx]);
    }
    return emptySqList;
  };

  GameBoard.prototype.getValidMovesForEmptySq = function(mtIdx) {
    var cardCol, cardLocn, cardRow, cardToLeftId, cardToMove, j, nextCard, ref, spaceCol, spaceRow, suitIdx, validMoves;
    validMoves = [];
    ref = this.getCardToLeftInfo(this.gapCards[mtIdx]), cardToLeftId = ref[0], spaceRow = ref[1], spaceCol = ref[2], cardRow = ref[3], cardCol = ref[4];
    if (cardToLeftId < 0 && spaceCol === 0) {
      for (suitIdx = j = 0; j <= 3; suitIdx = ++j) {
        cardToMove = PlayingCards.getCardIdBySuitAndRank(suitIdx, PlayingCards.TwoId);
        if (cardToMove >= 0) {
          cardLocn = this.getLocnOfCard(cardToMove);
          if (cardLocn[2] !== 0) {
            validMoves.push([[cardLocn[1], cardLocn[2]], [spaceRow, spaceCol]]);
          }
        }
      }
    } else if (!this.isGap(cardToLeftId)) {
      nextCard = PlayingCards.findNextCardInSameSuit(cardToLeftId);
      if (nextCard >= 0) {
        cardLocn = this.getLocnOfCard(nextCard);
        validMoves.push([[cardLocn[1], cardLocn[2]], [spaceRow, spaceCol]]);
      }
    }
    return validMoves;
  };

  GameBoard.prototype.moveValidCardToEmptyPlace = function(toCardId) {
    var cardCol, cardRow, cardToLeftId, clickedCol, clickedRow, fromCardId, ref;
    if (this.isGap(toCardId)) {
      ref = this.getCardToLeftInfo(toCardId), cardToLeftId = ref[0], clickedRow = ref[1], clickedCol = ref[2], cardRow = ref[3], cardCol = ref[4];
      if (cardToLeftId === -1) {
        return ["select2", 0, 0, clickedRow, clickedCol];
      }
      if (cardToLeftId > 0 && !this.isGap(cardToLeftId)) {
        fromCardId = PlayingCards.findNextCardInSameSuit(cardToLeftId);
        if (fromCardId > 0) {
          return this.moveCard(fromCardId, toCardId);
        }
      }
    }
    return ["none", 0, 0, 0, 0];
  };

  GameBoard.prototype.moveCardIfValid = function(fromCardId, toCardId) {
    var cardCol, cardRow, cardToLeftId, clickedCol, clickedRow, moveOk, ok, ref, ref1, toColIdx, toRowIdx;
    if (this.isGap(toCardId)) {
      moveOk = false;
      if (PlayingCards.getCardInfo(fromCardId).rankIdx === PlayingCards.TwoId) {
        ref = this.getLocnOfCard(toCardId), ok = ref[0], toRowIdx = ref[1], toColIdx = ref[2];
        if (ok && toColIdx === 0) {
          moveOk = true;
        }
      } else {
        ref1 = this.getCardToLeftInfo(toCardId), cardToLeftId = ref1[0], clickedRow = ref1[1], clickedCol = ref1[2], cardRow = ref1[3], cardCol = ref1[4];
        if (cardToLeftId >= 0) {
          if (fromCardId === PlayingCards.findNextCardInSameSuit(cardToLeftId)) {
            moveOk = true;
          }
        }
      }
      if (moveOk) {
        return this.moveCard(fromCardId, toCardId);
      }
    }
    return ["none", 0, 0, 0, 0];
  };

  GameBoard.prototype.updateScore = function(cardId, fromRowIdx, fromColIdx, gapId, toRowIdx, toColIdx) {
    var col, j, ref, ref1, results, testCardId, toBoardPos;
    toBoardPos = toRowIdx * this.numCols + toColIdx;
    testCardId = cardId;
    results = [];
    for (col = j = ref = toColIdx, ref1 = this.numCols - 1; ref <= ref1 ? j <= ref1 : j >= ref1; col = ref <= ref1 ? ++j : --j) {
      if (this.rowScores[toRowIdx] === col && this.board[toBoardPos] === testCardId) {
        this.rowScores[toRowIdx]++;
        this.score++;
        testCardId++;
        results.push(toBoardPos++);
      } else {
        break;
      }
    }
    return results;
  };

  GameBoard.prototype.moveCard = function(fromCardId, toCardId) {
    var cardId, cardLocnIdx, fromColIdx, fromRowIdx, gapId, gapLocnIdx, ok, ref, ref1, toColIdx, toRowIdx;
    ref = this.getLocnOfCard(fromCardId), ok = ref[0], fromRowIdx = ref[1], fromColIdx = ref[2];
    if (ok) {
      ref1 = this.getLocnOfCard(toCardId), ok = ref1[0], toRowIdx = ref1[1], toColIdx = ref1[2];
      if (ok) {
        gapLocnIdx = toRowIdx * this.numCols + toColIdx;
        gapId = this.board[gapLocnIdx];
        cardLocnIdx = fromRowIdx * this.numCols + fromColIdx;
        cardId = this.board[cardLocnIdx];
        this.board[gapLocnIdx] = cardId;
        this.board[cardLocnIdx] = gapId;
        this.cardLookup[cardId] = gapLocnIdx;
        this.cardLookup[gapId] = cardLocnIdx;
        this.updateScore(cardId, fromRowIdx, fromColIdx, gapId, toRowIdx, toColIdx);
        return ["ok", fromRowIdx, fromColIdx, toRowIdx, toColIdx];
      }
    }
    return ["none", 0, 0, 0, 0];
  };

  GameBoard.prototype.moveCardUsingRowAndColInfo = function(fromRowCol, toRowCol) {
    var cardId, cardLocnIdx, gapId, gapLocnIdx;
    gapLocnIdx = toRowCol[0] * this.numCols + toRowCol[1];
    gapId = this.board[gapLocnIdx];
    cardLocnIdx = fromRowCol[0] * this.numCols + fromRowCol[1];
    cardId = this.board[cardLocnIdx];
    this.board[gapLocnIdx] = cardId;
    this.board[cardLocnIdx] = gapId;
    this.cardLookup[cardId] = gapLocnIdx;
    this.cardLookup[gapId] = cardLocnIdx;
    this.updateScore(cardId, fromRowCol[0], fromRowCol[1], gapId, toRowCol[0], toRowCol[1]);
    return ["ok", fromRowCol[0], fromRowCol[1], toRowCol[0], toRowCol[1]];
  };

  GameBoard.prototype.getCardName = function(cardId) {
    var cardInfo;
    cardInfo = PlayingCards.getCardInfo(cardId);
    if (this.isGap(cardId)) {
      return "GP";
    }
    return cardInfo.cardShortName;
  };

  GameBoard.prototype.getIdOfPrevCard = function(cardId) {
    var prevCardId;
    prevCardId = PlayingCards.findPrevCardInSameSuit(cardId);
    if (PlayingCards.getCardRank(prevCardId) === PlayingCards.AceId) {
      return -2;
    }
    return prevCardId;
  };

  GameBoard.prototype.recalculateScore = function() {
    var cardId, col, completeRows, fullScore, j, k, ref, ref1, row, rowScore, rowSuit;
    fullScore = 0;
    completeRows = 0;
    for (row = j = 0, ref = this.numRows - 1; 0 <= ref ? j <= ref : j >= ref; row = 0 <= ref ? ++j : --j) {
      rowScore = 0;
      rowSuit = -1;
      for (col = k = 0, ref1 = this.numCols - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; col = 0 <= ref1 ? ++k : --k) {
        cardId = this.getCardIdByRowAndCol(row, col);
        if (col === 0) {
          if (PlayingCards.getCardRank(cardId) === PlayingCards.TwoId) {
            rowSuit = PlayingCards.getCardSuit(cardId);
            rowScore++;
          } else {
            break;
          }
        } else {
          if (PlayingCards.getCardRank(cardId) === col + 1 && PlayingCards.getCardSuit(cardId) === rowSuit) {
            rowScore++;
            if (col === this.numCols - 1) {
              completeRows++;
            }
          } else {
            break;
          }
        }
      }
      this.rowScores[row] = rowScore;
      fullScore += rowScore;
    }
    this.score = fullScore;
    return fullScore;
  };

  GameBoard.prototype.getScore = function() {
    return this.score;
  };

  GameBoard.prototype.debugDump = function(debugStr) {
    var cardId, col, i, j, k, l, m, ref, ref1, row, rowStr;
    console.log(debugStr);
    for (row = j = 0, ref = this.numRows - 1; 0 <= ref ? j <= ref : j >= ref; row = 0 <= ref ? ++j : --j) {
      rowStr = "";
      for (col = k = 0, ref1 = this.numCols - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; col = 0 <= ref1 ? ++k : --k) {
        cardId = this.getCardIdByRowAndCol(row, col);
        rowStr += this.getCardName(cardId) + " ";
      }
      console.log(rowStr);
    }
    rowStr = "";
    for (i = l = 0; l <= 51; i = ++l) {
      rowStr += ("00" + this.cardLookup[i]).substr(-2, 2) + " ";
    }
    console.log(rowStr);
    rowStr = "";
    for (i = m = 0; m <= 51; i = ++m) {
      rowStr += this.getCardName(i) + " ";
    }
    return console.log(rowStr);
  };

  GameBoard.prototype.checkValidity = function() {
    var cardId, cardLocn, cardStr, j, ref, results;
    results = [];
    for (cardId = j = 0, ref = PlayingCards.cardsInDeck - 1; 0 <= ref ? j <= ref : j >= ref; cardId = 0 <= ref ? ++j : --j) {
      cardLocn = this.cardLookup[cardId];
      if (this.board[cardLocn] !== cardId) {
        cardStr = this.getCardName(cardId);
        results.push(console.log("Mismatch cardId " + cardStr + " <> locn " + cardLocn));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return GameBoard;

})();

//# sourceMappingURL=GameBoard.js.map
