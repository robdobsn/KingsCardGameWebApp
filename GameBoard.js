// Generated by CoffeeScript 1.6.3
var GameBoard;

GameBoard = (function() {
  GameBoard.prototype.numRows = 4;

  GameBoard.prototype.numCols = 13;

  function GameBoard() {
    this.board = [];
  }

  GameBoard.prototype.deal = function(deck) {
    var boardRow, col, row, _i, _j, _ref, _ref1;
    this.board = [];
    deck.startDeal();
    for (row = _i = 0, _ref = this.numRows - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
      boardRow = [];
      for (col = _j = 0, _ref1 = this.numCols - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; col = 0 <= _ref1 ? ++_j : --_j) {
        boardRow.push(deck.getNextCard());
      }
      this.board.push(boardRow);
    }
    return true;
  };

  GameBoard.prototype.getBoard = function() {
    return this.board;
  };

  return GameBoard;

})();