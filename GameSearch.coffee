class GameSearch

#  constructor: () ->

  getPossibleMoves: (gameBoard) ->
    moveOptions = []
    for mtId in [-1,-2,-3,-4]
      moveOptions = moveOptions.concat gameBoard.getValidMovesForEmptySq(mtId)
    console.log moveOptions
    return moveOptions
