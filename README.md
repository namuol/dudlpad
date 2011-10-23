dudlpad (planned) API
=====================

v0.1alpha
---------

### DUDLPAD.create [parent]

```coffeescript
  pad = DUDLPAD.create $('#pad')
```

### pad.start [(pos) ->]

```coffeescript
  pad.start (pos) ->
    console.log 'started at #{pos[0]}, #{pos[1]}'
```

### pad.draw [(start, end) ->]

```coffeescript
  pad.draw (start, end) ->
    console.log 'drew from (#{start[0]}, #{start[1]}) to (#{end[0]}, #{end[1]})'
```

### pad.end [(pos) ->]

```coffeescript
  pad.start (pos) ->
    console.log 'started at #{pos[0]}, #{pos[1]}'
```

### pad.undo (->)

```coffeescript
  pad.undo ->
    console.log 'undo!'

  $('#undo').click ->
    pad.undo()
```

### pad.redo (->)

```coffeescript
  pad.redo ->
    console.log 'redo!'

  $('#redo').click ->
    pad.redo()
```
