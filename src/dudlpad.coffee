DUDLPAD = {}

if module?
  module.exports = DUDLPAD
else
  window.DUDLPAD = DUDLPAD

track = ->
  wrap = (func) ->
    ->
      func.apply func, arguments
      if punchedIn
        hist[hpos].push
          func: func
          args: arguments
  hist = []
  hpos = -1
  punchedIn = false

  punchIn = ->
    punchedIn = true
    hpos += 1
    hist[hpos] = []
    hist[hpos + 1] = `undefined`

  punchOut = (callback) ->
    punchedIn = false

  canUndo = ->
    hpos >= 0

  undo = ->
    return if !canUndo()
    console.log hist
    i = 0
    while i < hpos and (typeof hist[i] isnt "undefined")
      j = 0
      while j < hist[i].length
        hist[i][j].func.apply hist[i][j].func, hist[i][j].args
        j += 1
      i += 1
    hpos -= 1

  redo = ->
    if typeof hist[hpos + 1] isnt "undefined" and hist[hpos + 1] isnt null
      i = 0
      while i < hist[hpos + 1].length
        hist[hpos + 1][i].func.apply hist[hpos + 1][i].func, hist[hpos + 1][i].args
        i += 1
      hpos += 1

  hist: hist
  wrap: wrap
  punchIn: punchIn
  punchOut: punchOut
  isPunchedIn: ->
    punchedIn

  canUndo: canUndo
  undo: undo
  redo: redo


DUDLPAD.create = (container, width, height) ->
  if not container?
    throw 'null container was passed to `create`.'
  
  container.class = container.class + ' dudlpad-container'
  canvas = document.createElement 'canvas'
  canvas.width = width
  canvas.height = height
  context = canvas.getContext '2d'
  context.lineWidth = 2.0
  context.lineCap = 'round'
  context.lineJoin = 'round'

  container.appendChild canvas
  mouseX = mouseY = 0
  mouseHeld = false
  drawing = false

  _canHaveCallback = (inner) ->
    before = null
    after = null
    return (args...) ->
      if args[0]?
        if typeof args[0] == 'function'
          before = args[0]
          return
        else if typeof args[0] == 'object' and (args[0].before? or args[0].after?)
          before = args[0].before if args[0].before?
          after = args[0].after if args[0].after?
          return
      res = true
      res = before.apply pad, args if before?
      if res != false
        inner.apply pad, args
      after.apply pad, args if after?

  pad = do ->
    hist = track()

    _drawLines = hist.wrap (coords) ->
      context.beginPath()

      i = 0
      while i < coords.length
        context.moveTo coords[i], coords[i + 1]
        context.lineTo coords[i + 2], coords[i + 3]
        i += 2

      context.closePath()
      context.stroke()


    start: _canHaveCallback (pos) ->
      drawing = true
      hist.punchIn()
      _drawLines [pos[0], pos[1], pos[0], pos[1] + 0.1]

    draw: _canHaveCallback (coords) ->
      if drawing
        _drawLines coords

    end: _canHaveCallback (pos) ->
      drawing = false
      hist.punchOut()

    undo: _canHaveCallback ->
      if hist.isPunchedIn()
        throw 'attempted to call `undo` during an operation that alters history'
      context.clearRect 0, 0, canvas.width, canvas.height
      hist.undo()

    redo: _canHaveCallback ->
      hist.redo()

    canvas: canvas

  return pad
