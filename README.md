d&uuml;dlpad is a simple, lightweight, zero-dependency drawing surface that utilizes the HTML5 `canvas` tag.

It is implemented in [Coffee Script](http://jashkenas.github.com/coffee-script/).

Some features:
- callback-driven API
- undo/redo support
- (*planned*) drawing style support (e.g. line width, color, etc.)

A live demo can be seen [here](http://namuol.github.com/dudlpad/).

A jQuery plugin that handles input events across different devices is also planned.

---------------------------------------

d&uuml;dlpad API
=====================

v0.1-alpha
--------------

### DUDLPAD.create [parent]

```coffeescript
  pad = DUDLPAD.create $("#pad")[0]
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

  $("#undo").click ->
    pad.undo()
```

### pad.redo (->)

```coffeescript
  pad.redo ->
    console.log "redo!"

  $("#redo").click ->
    pad.redo()
```
