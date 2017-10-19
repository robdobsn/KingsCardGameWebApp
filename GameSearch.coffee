class GameSearch

  constructor: () ->
    @bestScore = -10000
    @bestMoveList = []
    @maxRecurseDepth = 10
    @movesConsidered = 0
    @maxMovesToConsider = 100000

  getPossibleMoves: (gameBoard) ->
#    gameBoard.debugDump("Debug")
    moveOptions = []
    for mtId in [-1,-2,-3,-4]
      moveOptions = moveOptions.concat gameBoard.getValidMovesForEmptySq(mtId)
#    console.log moveOptions
    return moveOptions

  getFullTreeByInitalMove: (startBoard, allPossMovesByStartMove) ->
    @bestScore = -10000
    @bestMoveList = []
    # Get the possible moves from start position
    possMoves = @getPossibleMoves(startBoard)
    for possMove, possMoveIdx in possMoves
      @movesConsidered = 0
      allMovesFromHere = []
      # Create a copy of game board and play the first move
      newBoard = new GameBoard(startBoard.playingCards)
      newBoard.copy(startBoard)
      newBoard.moveCardUsingRowAndColInfo(possMove[0], possMove[1])
      pastMoveList = [possMove]
      allMovesFromHere.push [possMove]
      @treeFromHere(newBoard, pastMoveList, 1, allMovesFromHere)
      allPossMovesByStartMove.push allMovesFromHere
      console.log "Start move " + possMoveIdx + " considered " + @movesConsidered
    return [@bestMoveList, @bestScore]

  treeFromHere: (startBoard, pastMoveList, recurseDepth, allPossMoves) ->
    # Only recurse as far as asked to
    if recurseDepth >= @maxRecurseDepth
      return
    # Get the possible moves from this position
    possMoves = @getPossibleMoves(startBoard)
    @movesConsidered += possMoves.length
    if @movesConsidered > @maxMovesToConsider
      return
    # Add to the list of all possible moves
    if allPossMoves.length <= recurseDepth
      allPossMoves.push []
    allPossMoves[recurseDepth] = allPossMoves[recurseDepth].concat possMoves
    # Go through each possible move
    for possMove in possMoves
      # Create a copy of game board and play the move
      newBoard = new GameBoard(startBoard.playingCards)
      newBoard.copy(startBoard)
      newBoard.moveCardUsingRowAndColInfo(possMove[0], possMove[1])
      # Copy the list of moves to this point and add this move
      newMoveList = pastMoveList.slice(0)
      newMoveList.push possMove
      # Check if this move improves on the best
      newScore = newBoard.getBoardScore()
      if @bestScore < newScore[0]
        @bestScore = newScore[0]
        @bestMoveList = newMoveList.slice(0)
      # Recursively search the tree
      @treeFromHere(newBoard, newMoveList, recurseDepth+1, allPossMoves)
    return allPossMoves
