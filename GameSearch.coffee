class GameSearch

  constructor: () ->
    @searchDepthAtLayer = [5] # [13,12,12,11,11,11,11,11,10,9,8,7]
    @maxMovesAtLayer = [100000] # [1000000,500000,500000,250000,100000]
    @bestFactoredScore = -10000
    @bestMoveList = []
    @maxRecurseDepth = 12
    @movesConsidered = 0
    @maxMovesToConsider = 200000

  getPossibleMoves: (gameBoard) ->
#    gameBoard.debugDump("Debug")
    moveOptions = []
    for mtIdx in [0..3]
      moveOptions = moveOptions.concat gameBoard.getValidMovesForEmptySq(mtIdx)
#    console.log moveOptions
    return moveOptions

  getDynamicTree: (startBoard, displayBoard) ->
    @dynamicMoveList = []
    @dynamicFactoredScore = -10000
    # Start position will move on as routes are found
    dynamicBoard = startBoard.clone()
    for dynIdx in [0..100]
      console.log "Dynamic tree " + dynIdx
      @maxRecurseDepth = if @searchDepthAtLayer.length > dynIdx then @searchDepthAtLayer[dynIdx] else @searchDepthAtLayer[@searchDepthAtLayer.length-1]
      @maxMovesToConsider = if @maxMovesAtLayer.length > dynIdx then @maxMovesAtLayer[dynIdx] else @maxMovesAtLayer[@maxMovesAtLayer.length-1]
      @bestFactoredScore = -10000
      @bestMoveList = []
      # Get the possible moves from start position
      possMoves = @getPossibleMoves(dynamicBoard)
      for possMove, possMoveIdx in possMoves
        @movesConsidered = 0
        # Create a copy of game board and play the first move
        newBoard = dynamicBoard.clone()
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
      # Get the first move of the best sequence
      if @bestMoveList.length <= 0
        break
      bestMove = @bestMoveList[0]
      @dynamicMoveList.push bestMove
      @dynamicFactoredScore = @bestFactoredScore
      # Create a copy of game board and play the best move
      dynamicBoard.moveCardUsingRowAndColInfo(bestMove[0], bestMove[1])
      # Preview if required
      if displayBoard is not null
        displayBoard.showMoveSequence(@dynamicMoveList, @dynamicFactoredScore, 0, true)
    # These are now the best
    @bestMoveList = @dynamicMoveList.slice(0)
    @bestFactoredScore = @dynamicFactoredScore
    return [@dynamicMoveList, @dynamicFactoredScore]

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
