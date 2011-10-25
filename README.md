d&uuml;dlpad (planned) API
=====================

v0.1-pre-alpha
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

### pad.canvas

```coffeescript
  pad.canvas # HTMLElement: <canvas>
```
