DUDLPAD = {}

if module?
  module.exports = DUDLPAD
else
  window.DUDLPAD = DUDLPAD

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
    callback = null
    return (args...) ->
      if args[0]? and typeof args[0] == 'function'
        callback = args[0]
        return
      inner.apply inner, args
      callback.apply inner, args if callback?

  _drawLines = (coords) ->
    context.beginPath()

    i = 0
    while i < coords.length
      context.moveTo coords[i], coords[i + 1]
      context.lineTo coords[i + 2], coords[i + 3]
      i += 2

    context.closePath()
    context.stroke()

  pad =
    start: _canHaveCallback (pos) ->
      drawing = true
      _drawLines [pos[0], pos[1], pos[0], pos[1] + 0.1]

    draw: _canHaveCallback (coords) ->
      _drawLines coords

    end: _canHaveCallback (pos) ->
      drawing = false

    undo: _canHaveCallback ->
      throw 'not implemented yet'

    redo: _canHaveCallback ->
      throw 'not implemented yet'

    canvas: canvas
    
    canvasPos: (pagePos) ->
      # Might want to remove this; KISS
      canvasPos = $(canvas).offset()
      absX = pagePos[0] - canvasPos.left
      absY = pagePos[1] - canvasPos.top

      return [
        absX * (canvas.width / $(canvas).innerWidth())
        absY * (canvas.height / $(canvas).innerHeight())
      ]

  return pad
