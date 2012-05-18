DUDLPAD = {}

if module?
  module.exports = DUDLPAD
else
  window.DUDLPAD = DUDLPAD

noFalses = (array) ->
  if array.length > 0
    val = array.pop()
    return false if val is false
    return noFalses(array)
  return true

# Internal object reference used for `unbind`
__clearCallbacks = {}

# Lets you call any function with a single function
# or object that looks like `{before: <func>, after: <func>}`
# as the second argument to change the callback(pad, function
# that runs before or after the `inner` function is called.
#
# If a `function` is passed as the second argument, it overrides
# the `before` callback.
#
# To cancel the execution of the `inner` function, return `false` from
# the `before` callback.
# 
# To alter the `after` callback without changing the `before` callback,
# pass `{after: <func>}`.
#
# To clear a callback, pass in the internal `__clearCallbacks` object
# reference instead of a function in any of the above situations.
canHaveCallback = (pad, inner, retVal) ->
  before = []
  after = []
  before.remove = after.remove = (from, to) ->
    rest = @slice((to or from) + 1 or @length)
    @length = if from < 0 then @length + from else from
    @push.apply(@, rest)
  
  clearCallbacks = ->
    before = []
    after = []

  func = (args...) ->
    if args[0]?
      if typeof args[0] == 'function'
        before.push args[0]
        return retVal
      else if args[0] is __clearCallbacks
        clearCallbacks()
        return retVal
      else if typeof args[0] == 'object' and (args[0].before? or args[0].after?)
        if args[0].before?
          before.push args[0].before
        if args[0].after?
          after.push args[0].after
        return retVal

    beforeResults = []
    for bef in before
      beforeResults.push bef.apply pad, args
    if noFalses beforeResults
      res = inner.apply pad, args
    aft.apply pad, args for aft in after
    return res

# For UNDO/REDO functionality.
history = ->

  # Returns a function that first runs the `func` argument and then
  # if we are `punchedIn`, appends the function to our current history item.
  wrap = (func) ->
    (args...) ->
      res = func.apply func, args
      if punchedIn
        hist[hpos].push
          func: func
          args: args
      return res

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
  
  # A callback(pad, that should set the canvas/whatever to a pristine state
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

DUDLPAD.create = (canvas) ->
  if not canvas?
    throw 'null canvas was passed to `create`.'
  # Draws lines based on a list of coordinates.
  # Set in the `resetAll` method as it needs to be `wrap`ped
  # by the `hist` object which is not set until `resetAll`
  # is called.
  drawLines = null

  # A `history` object to track changes for undo/redo functionality.
  # It is set in the `resetAll` method.
  hist = null

  # For keeping track of the current drawing style.
  # These are set in the `resetAll` method.
  strokeStyle = null
  lineWidth = null

  clearCanvas = null

  # Puts the canvas in a 'pristine' state.
  resetCanvas = ->
    clearCanvas()
    context.strokeStyle = 'black'
    context.lineWidth = 2.0
    context.lineCap = 'round'
    context.lineJoin = 'round'

  # Resets the canvas and the history object.
  resetAll = ->
    hist = history()

    # Ensure that our canvas is 'pristine' before performing `undo`
    hist.beforeUndo resetCanvas

    clearCanvas = hist.wrap ->
      context.clearRect 0, 0, canvas.width, canvas.height

    drawLines = hist.wrap (style, coords) ->
      for own name, value of style
        context[name] = value
      context.beginPath()

      i = 0
      while i+3 < coords.length
        context.moveTo coords[i], coords[i + 1]
        context.lineTo coords[i + 2], coords[i + 3]
        i += 2

      context.closePath()
      context.stroke()

    resetCanvas()

    strokeStyle = context.strokeStyle
    lineWidth = context.lineWidth

  # Set the default properties of the canvas.
  context = canvas.getContext '2d'

  resetAll()
  
  # Flag to track when we have started/ended drawing.
  drawing = false

  # The `pad` object.
  pad =
    start: canHaveCallback(@, (pos, color) ->
      drawing = true
      hist.punchIn()
      if color?
        _strokeStyle = color
      else
        _strokeStyle = strokeStyle
      drawLines
        lineWidth: lineWidth
        strokeStyle: _strokeStyle
      , [pos[0], pos[1], pos[0], pos[1] + 0.1]
      return @
    )

    draw: canHaveCallback(@, (coords, color) ->
      if color?
        _strokeStyle = color
      else
        _strokeStyle = strokeStyle
      drawLines
        lineWidth: lineWidth
        strokeStyle: _strokeStyle
      , coords
      return @
    )

    end: canHaveCallback(@, (pos) ->
      drawing = false
      hist.punchOut()
      return @
    )

    undo: canHaveCallback(@, ->
      hist.undo()
      return @
    )

    redo: canHaveCallback(@, ->
      hist.redo()
      return @
    )
    
    lineColor: canHaveCallback(@, (color) ->
      return strokeStyle if arguments.length is 0
      strokeStyle = color
      return @
    )

    lineWidth: canHaveCallback(@, (width) ->
      return lineWidth if arguments.length is 0
      lineWidth = width
      return @
    )
    
    clear: canHaveCallback(@, ->
      hist.punchIn()
      clearCanvas()
      hist.punchOut()
      return @
    )

    reset: canHaveCallback(@, ->
      resetAll()
      return @
    )
    
    unbind: (name) ->
      if @[name]?
        @[name](__clearCallbacks)
