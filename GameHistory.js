// Generated by CoffeeScript 1.12.7
var GameHistory;

GameHistory = (function() {
  function GameHistory() {
    this.historyListPos = -1;
    this.historyList = [];
  }

  GameHistory.prototype.addToHistory = function(board) {
    var copyOfBoard;
    copyOfBoard = new GameBoard(board.playingCards);
    copyOfBoard.copy(board);
    if (this.historyListPos + 1 < this.historyList.length) {
      this.historyList = this.historyList.slice(0, this.historyListPos + 1);
    }
    this.historyList.push(copyOfBoard);
    return this.historyListPos += 1;
  };

  GameHistory.prototype.getPreviousBoard = function() {
    if (this.historyListPos > 0) {
      this.historyListPos -= 1;
      return this.historyList[this.historyListPos];
    }
    if (this.historyListPos === 0) {
      return this.historyList[this.historyListPos];
    }
    return null;
  };

  GameHistory.prototype.getNextBoard = function() {
    if (this.historyListPos < this.historyList.length) {
      if (this.historyList.length === 0) {
        return null;
      }
      if (this.historyListPos + 1 < this.historyList.length) {
        this.historyListPos += 1;
      }
      return this.historyList[this.historyListPos];
    }
    return null;
  };

  return GameHistory;

})();

//# sourceMappingURL=GameHistory.js.map
