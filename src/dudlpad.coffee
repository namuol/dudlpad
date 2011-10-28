DUDLPAD = {}

if module?
  module.exports = DUDLPAD
else
  window.DUDLPAD = DUDLPAD

# Lets you call any function with a single function
# or object that looks like `{before: <func>, after: <func>}`
# as the first argument to change the callback function
# that runs before or after the `inner` function is called.
#
# If a `function` is passed as the first argument, it overrides
# the `before` callback.
#
# To cancel the execution of the `inner` function, return `false` from
# the `before` callback.
# 
# To alter the `after` callback without changing the `before` callback,
# pass `{after: <func>}`.
canHaveCallback = (inner) ->
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

# For UNDO/REDO functionality.
history = ->

  # Returns a function that first runs the `func` argument and then
  # if we are `punchedIn`, appends the function to our current history item.
  wrap = (func) ->
    ->
      func.apply func, arguments
      if punchedIn
        hist[hpos].push
          func: func
          args: arguments

  # The array that stores each history item (an array of function/argument pairs).
  hist = []

  # The current position within our history array.
  hpos = -1

  # A flag that indicates whether we should record `wrap`ped functions.
  punchedIn = false

  # Set the `punchedIn` flag to true.
  punchIn = ->
    punchedIn = true

    # Punching in means that we need to start recording a new set of `wrap`ped
    # functions.
    hpos += 1
    hist[hpos] = []

    # We also need to nullify the next item since it is no longer a valid history.
    # This is especially important if we have called `undo` and thus find ourselves
    # somewhere in the middle of our history. If you alter the past, the future must
    # therefore change.
    hist[hpos + 1] = null

  # Set the `punchedIn` flag to false.
  punchOut = (callback) ->
    punchedIn = false
  
  _beforeUndo = null
  
  # A callback that should set the canvas/whatever to a pristine state
  # so it can be repainted using the recorded history. Takes no arguments.
  beforeUndo = (func) ->
    _beforeUndo = func
  
  # Restore the state prior to the current history position.
  undo = ->
    if punchedIn
      throw 'attempted to call `undo` during an operation that alters history'
    else if hpos < 0
      return # Nothing to undo.
    
    if _beforeUndo?
      _beforeUndo()

    # Now, starting from the beginning of our recorded history,
    # we re-`apply` every function/argument pair that has been recorded,
    # in order up until the current history position.
    i = 0
    while i < hpos and hist[i]?
      j = 0
      while j < hist[i].length
        hist[i][j].func.apply hist[i][j].func, hist[i][j].args
        j += 1
      i += 1
    hpos -= 1

  # `apply` the *next* item in our history, if it is not `null`.
  redo = ->
    next = hist[hpos + 1]
    if next?
      i = 0
      while i < next.length
        current = next[i]
        current.func.apply current.func, current.args
        i += 1
      hpos += 1

  wrap: wrap
  punchIn: punchIn
  punchOut: punchOut
  beforeUndo: beforeUndo
  undo: undo
  redo: redo

DUDLPAD.create = (container, width, height) ->
  if not container?
    throw 'null container was passed to `create`.'

  # Add the css-class `dudlpad-container`.
  container.class = container.class + ' dudlpad-container'
  
  # Create a new `canvas` element.
  canvas = document.createElement 'canvas'
  canvas.width = width
  canvas.height = height

  # Set the default properties of the canvas.
  context = canvas.getContext '2d'
  
  # Puts the canvas in a 'pristine' state.
  resetCanvas = ->
    context.clearRect 0, 0, canvas.width, canvas.height
    context.lineWidth = 2.0
    context.lineCap = 'round'
    context.lineJoin = 'round'

  resetCanvas()
  
  # Add the `canvas` to the passed-in `container`
  container.appendChild canvas

  # Flag to track when we have started/ended drawing.
  drawing = false

  # A `history` object to track changes for undo/redo functionality.
  hist = history()

  # Ensure that our canvas is 'pristine' before performing `undo`
  hist.beforeUndo resetCanvas

  # Draws lines based on a list of coordinates.
  drawLines = hist.wrap (coords) ->
    context.beginPath()

    i = 0
    while i < coords.length
      context.moveTo coords[i], coords[i + 1]
      context.lineTo coords[i + 2], coords[i + 3]
      i += 2

    context.closePath()
    context.stroke()
  
  # The `pad` object.
  start: canHaveCallback (pos) ->
    drawing = true
    hist.punchIn()
    drawLines [pos[0], pos[1], pos[0], pos[1] + 0.1]

  draw: canHaveCallback (coords) ->
    if drawing
      drawLines coords

  end: canHaveCallback (pos) ->
    drawing = false
    hist.punchOut()

  undo: canHaveCallback ->
    hist.undo()

  redo: canHaveCallback ->
    hist.redo()
  
  # For v0.2.0 (not implemented yet)
  lineColor: canHaveCallback ->
    throw 'not implemented yet'

  # For v0.2.0 (not implemented yet)
  lineWidth: canHaveCallback ->
    throw 'not implemented yet'
