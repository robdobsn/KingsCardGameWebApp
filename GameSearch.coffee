class GameSearch

  constructor: () ->
    @searchDepthAtLayer = [13,12,12,11,11,11,11,11,10,9,8,7]
    @maxMovesAtLayer = [500000,500000,500000,250000,100000]
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
        newScore = newBoard.getScore()
        if @bestFactoredScore < newScore
          @bestFactoredScore = newScore
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
    return [@bestMoveList, @bestFactoredScore]

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
      newScore = newBoard.getScore()
      if @bestFactoredScore < newScore
        @bestFactoredScore = newScore
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
#    console.log "Poss moves " + possMoves.length
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
      newScore = newBoard.getScore()
      if @bestFactoredScore < newScore
        @bestFactoredScore = newScore
        @bestMoveList = newMoveList.slice(0)
      # Recursively search the tree
      @treeFromHere(newBoard, newMoveList, recurseDepth+1)
    return

  getBestMoves: () ->
    return [@bestMoveList, @bestFactoredScore]

  getLoop: (gameBoard, displayBoard, startCardId) ->
    # Go through finding next card in sequence
    moveList = []
    curCardId = startCardId
    for i in [0..100]
      # Check if current card is a gap
      if gameBoard.isGap(curCardId)
        console.log "Current card is a gap"
        break
      # Get location of current card
      curCardLocn = gameBoard.getLocnOfCard(curCardId)
      # Find the card before the current one
      prevCardId = gameBoard.getIdOfPrevCard(curCardId)
      prevCardStr = if prevCardId >= 0 then PlayingCards.getCardInfo(prevCardId).cardShortName else "INVALID"
      console.log "cur card " + PlayingCards.getCardInfo(curCardId).cardShortName + ", prev " + prevCardStr
      if prevCardId < 0 # The current card is a 2 or error
        console.log "prev card is 2 or error"
        break
      # Find the card to the right of the prev card
      [cardToRightId,prevCardRow,prevCardCol,cardRow,cardCol] = gameBoard.getCardToRightInfo(prevCardId)
      if cardToRightId < 0 # The prev card is at the end of a row
        console.log "prev card at end of row"
        break
      moveList.push [[curCardLocn[1], curCardLocn[2]],[cardRow,cardCol]]
      curCardId = cardToRightId
    return moveList
