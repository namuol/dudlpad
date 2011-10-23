dudlpad (planned) API
===========

v0.1
----

`DUDLPAD.create [parent]`

    pad = DUDLPAD.create $('#pad')

`pad.start [(pos) ->]`
    
    pad.start (pos) ->
      console.log 'started at #{pos[0]}, #{pos[1]}'

`pad.draw [(start, end) ->]`

    pad.draw (pos) ->
      console.log 'drew from (#{start[0]}, #{start[1]}) to (#{end[0]}, #{end[1]})'

`pad.end [(pos) ->]`

    pad.start (pos) ->
      console.log 'started at #{pos[0]}, #{pos[1]}'

`pad.undo (->)`
    
    pad.undo ->
      console.log 'undo!'

    $('#undo').click ->
      pad.undo()

`pad.redo (->)`

    pad.redo ->
      console.log 'redo!'

    $('#redo').click ->
      pad.redo()

