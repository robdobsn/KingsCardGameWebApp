// Generated by CoffeeScript 1.12.7
var GameSearch;

GameSearch = (function() {
  function GameSearch() {
    this.bestScore = -10000;
    this.bestMoveList = [];
    this.maxRecurseDepth = 10;
    this.movesConsidered = 0;
    this.maxMovesToConsider = 100000;
  }

  GameSearch.prototype.getPossibleMoves = function(gameBoard) {
    var i, len, moveOptions, mtId, ref;
    moveOptions = [];
    ref = [-1, -2, -3, -4];
    for (i = 0, len = ref.length; i < len; i++) {
      mtId = ref[i];
      moveOptions = moveOptions.concat(gameBoard.getValidMovesForEmptySq(mtId));
    }
    return moveOptions;
  };

  GameSearch.prototype.getFullTreeByInitalMove = function(startBoard, allPossMovesByStartMove) {
    var allMovesFromHere, i, len, newBoard, pastMoveList, possMove, possMoves;
    this.bestScore = -10000;
    this.bestMoveList = [];
    possMoves = this.getPossibleMoves(startBoard);
    for (i = 0, len = possMoves.length; i < len; i++) {
      possMove = possMoves[i];
      this.movesConsidered = 0;
      allMovesFromHere = [];
      newBoard = new GameBoard(startBoard.playingCards);
      newBoard.copy(startBoard);
      newBoard.moveCardUsingRowAndColInfo(possMove[0], possMove[1]);
      pastMoveList = [possMove];
      allMovesFromHere.push([possMove]);
      this.treeFromHere(newBoard, pastMoveList, 1, allMovesFromHere);
      allPossMovesByStartMove.push(allMovesFromHere);
      console.log("Start move " + possMoveIdx + " considered " + this.movesConsidered);
    }
    return [this.bestMoveList, this.bestScore];
  };

  GameSearch.prototype.treeFromHere = function(startBoard, pastMoveList, recurseDepth, allPossMoves) {
    var i, len, newBoard, newMoveList, newScore, possMove, possMoves;
    if (recurseDepth >= this.maxRecurseDepth) {
      return;
    }
    possMoves = this.getPossibleMoves(startBoard);
    this.movesConsidered += possMoves.length;
    if (this.movesConsidered > this.maxMovesToConsider) {
      return;
    }
    if (allPossMoves.length <= recurseDepth) {
      allPossMoves.push([]);
    }
    allPossMoves[recurseDepth] = allPossMoves[recurseDepth].concat(possMoves);
    for (i = 0, len = possMoves.length; i < len; i++) {
      possMove = possMoves[i];
      newBoard = new GameBoard(startBoard.playingCards);
      newBoard.copy(startBoard);
      newBoard.moveCardUsingRowAndColInfo(possMove[0], possMove[1]);
      newMoveList = pastMoveList.slice(0);
      newMoveList.push(possMove);
      newScore = newBoard.getBoardScore();
      if (this.bestScore < newScore[0]) {
        this.bestScore = newScore[0];
        this.bestMoveList = newMoveList.slice(0);
      }
      this.treeFromHere(newBoard, newMoveList, recurseDepth + 1, allPossMoves);
    }
    return allPossMoves;
  };

  return GameSearch;

})();

//# sourceMappingURL=GameSearch.js.map