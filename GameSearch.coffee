class GameSearch

  constructor: () ->
    @bestFactoredScore = -10000
    @bestMoveList = []
    @maxRecurseDepth = 15
    @movesConsidered = 0
    @maxMovesToConsider = 1000000

  getPossibleMoves: (gameBoard) ->
#    gameBoard.debugDump("Debug")
    moveOptions = []
    for mtId in [-1,-2,-3,-4]
      moveOptions = moveOptions.concat gameBoard.getValidMovesForEmptySq(mtId)
#    console.log moveOptions
    return moveOptions

  getFullTreeByInitalMove: (startBoard) ->
    @bestFactoredScore = -10000
    @bestMoveList = []
    # Get the possible moves from start position
    possMoves = @getPossibleMoves(startBoard)
    for possMove, possMoveIdx in possMoves
      @movesConsidered = 0
      # Create a copy of game board and play the first move
      newBoard = new GameBoard(startBoard.playingCards)
      newBoard.copy(startBoard)
      newBoard.moveCardUsingRowAndColInfo(possMove[0], possMove[1])
      newMoveList = [possMove]
      # Check if this move improves on the best
      newScore = newBoard.getBoardScore()
      if @bestFactoredScore < newScore[0]
        @bestFactoredScore = newScore[0]
        @bestMoveList = newMoveList.slice(0)
      # Recurse from here
      @treeFromHere(newBoard, newMoveList, 1)
      console.log "Start move " + possMoveIdx + " considered " + @movesConsidered
    return [@bestMoveList, @bestFactoredScore]

  treeFromHere: (startBoard, pastMoveList, recurseDepth) ->
    # Only recurse as far as asked to
    if recurseDepth >= @maxRecurseDepth
      return
    # Get the possible moves from this position
    possMoves = @getPossibleMoves(startBoard)
    @movesConsidered += possMoves.length
    if @movesConsidered > @maxMovesToConsider
      return
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
      if @bestFactoredScore < newScore[0]
        @bestFactoredScore = newScore[0]
        @bestMoveList = newMoveList.slice(0)
      # Recursively search the tree
      @treeFromHere(newBoard, newMoveList, recurseDepth+1)
    return

  getBestMoves: () ->
    return [@bestMoveList, @bestFactoredScore]
