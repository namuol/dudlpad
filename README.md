**d&uuml;dlpad** is a simple, lightweight, zero-dependency drawing surface that utilizes the HTML5 `canvas` tag.

It is implemented in [Coffee Script](http://jashkenas.github.com/coffee-script/).

Some features:

- callback-driven API
- undo/redo support
- drawing style support (e.g. line width, color, etc.)
- (*planned*) recording/playback capabilities

A live demo can be seen [here](http://namuol.github.com/dudlpad/).

Annotated source can be viewed [here](http://namuol.github.com/dudlpad/docs/dudlpad.html).

A jQuery plugin that handles input events across different devices is also planned.

v0.2.0 API
==========

### DUDLPAD.create [parent]

```coffeescript
  pad = DUDLPAD.create my_canvas
```

### pad.start [pos] | [(pos) ->]

```coffeescript
  pad.start (pos) ->
    console.log "started at #{pos[0]}, #{pos[1]}"

  pad.start [25,25]
```

### pad.draw [coords] | [(coords) ->]

```coffeescript
  pad.draw (coords) ->
    i = 0
    while i < coords.length
      console.log "#{'drew from' if i==0 else '  then to'} (#{coords[i]}, #{coords[i+1]})"
      i += 2

  pad.draw [
    25,25
    50,50
  ]
```

### pad.end [pos] | [(pos) ->]

```coffeescript
  pad.end (pos) ->
    console.log "ended at #{pos[0]}, #{pos[1]}"

  pad.end [50,50]
```

### pad.undo (->)

```coffeescript
  pad.undo ->
    console.log "undo!"

  $('#undo').click ->
    pad.undo()
```

### pad.redo (->)

```coffeescript
  pad.redo ->
    console.log "redo!"

  $('#redo').click ->
    pad.redo()
```

### pad.lineColor () | [[cssColor](http://dev.w3.org/csswg/css3-color/)] | [([cssColor](http://dev.w3.org/csswg/css3-color/)) ->]
```coffeescript
  console.log "the current line color is '#{pad.lineColor()}'"

  pad.lineColor (cssColor) ->
    console.log "line color was changed to '#{cssColor}'"

  $('input#color').change ->
    pad.lineColor $(this).val()
```

### pad.lineWidth () | [width] | [(width) ->]
```coffeescript
  console.log "the current line width is '#{pad.lineWidth()}'"

  pad.lineWidth (width) ->
    console.log "line width was changed to '#{width}'"

  $('#widen').click ->
    pad.lineWidth pad.lineWidth() + 1.0

  $('#narrow').click ->
    pad.lineWidth pad.lineWidth() - 1.0
```

### pad.clear (->)
```coffeescript
  pad.clear ->
    console.log 'canvas was cleared!'

  $('#clear').click ->
    pad.clear()
```

### pad.unbind (event)
```coffeescript
  pad.start ->
    console.log 'start!'
  pad.start [0,0] # console output: 'start!'

  pad.unbind 'start'

  pad.start [0,0] # No console output.
```

### pad.reset (->)

This will clear the canvas *and* reset the line color/thickness.
It doesn't reset any callbacks. (See `unbind`)

```coffeescript
  pad.reset ->
    console.log 'canvas was reset!'

  $('#reset').click ->
    pad.reset()
```
