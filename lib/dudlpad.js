(function() {
  var DUDLPAD, canHaveCallback, history;
  var __slice = Array.prototype.slice;
  DUDLPAD = {};
  if (typeof module !== "undefined" && module !== null) {
    module.exports = DUDLPAD;
  } else {
    window.DUDLPAD = DUDLPAD;
  }
  canHaveCallback = function(inner) {
    var after, before;
    before = null;
    after = null;
    return function() {
      var args, res;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args[0] != null) {
        if (typeof args[0] === 'function') {
          before = args[0];
          return;
        } else if (typeof args[0] === 'object' && ((args[0].before != null) || (args[0].after != null))) {
          if (args[0].before != null) {
            before = args[0].before;
          }
          if (args[0].after != null) {
            after = args[0].after;
          }
          return;
        }
      }
      res = true;
      if (before != null) {
        res = before.apply(pad, args);
      }
      if (res !== false) {
        inner.apply(pad, args);
      }
      if (after != null) {
        return after.apply(pad, args);
      }
    };
  };
  history = function() {
    var beforeUndo, hist, hpos, punchIn, punchOut, punchedIn, redo, undo, wrap, _beforeUndo;
    wrap = function(func) {
      return function() {
        func.apply(func, arguments);
        if (punchedIn) {
          return hist[hpos].push({
            func: func,
            args: arguments
          });
        }
      };
    };
    hist = [];
    hpos = -1;
    punchedIn = false;
    punchIn = function() {
      punchedIn = true;
      hpos += 1;
      hist[hpos] = [];
      return hist[hpos + 1] = null;
    };
    punchOut = function(callback) {
      return punchedIn = false;
    };
    _beforeUndo = null;
    beforeUndo = function(func) {
      return _beforeUndo = func;
    };
    undo = function() {
      var i, j;
      if (punchedIn) {
        throw 'attempted to call `undo` during an operation that alters history';
      } else if (hpos < 0) {
        return;
      }
      if (_beforeUndo != null) {
        _beforeUndo();
      }
      i = 0;
      while (i < hpos && (hist[i] != null)) {
        j = 0;
        while (j < hist[i].length) {
          hist[i][j].func.apply(hist[i][j].func, hist[i][j].args);
          j += 1;
        }
        i += 1;
      }
      return hpos -= 1;
    };
    redo = function() {
      var current, i, next;
      next = hist[hpos + 1];
      if (next != null) {
        i = 0;
        while (i < next.length) {
          current = next[i];
          current.func.apply(current.func, current.args);
          i += 1;
        }
        return hpos += 1;
      }
    };
    return {
      wrap: wrap,
      punchIn: punchIn,
      punchOut: punchOut,
      beforeUndo: beforeUndo,
      undo: undo,
      redo: redo
    };
  };
  DUDLPAD.create = function(container, width, height) {
    var canvas, context, drawLines, drawing, hist, resetCanvas;
    if (!(container != null)) {
      throw 'null container was passed to `create`.';
    }
    container["class"] = container["class"] + ' dudlpad-container';
    canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    context = canvas.getContext('2d');
    resetCanvas = function() {
      context.clearRect(0, 0, canvas.width, canvas.height);
      context.lineWidth = 2.0;
      context.lineCap = 'round';
      return context.lineJoin = 'round';
    };
    resetCanvas();
    container.appendChild(canvas);
    drawing = false;
    hist = history();
    hist.beforeUndo(resetCanvas);
    drawLines = hist.wrap(function(coords) {
      var i;
      context.beginPath();
      i = 0;
      while (i < coords.length) {
        context.moveTo(coords[i], coords[i + 1]);
        context.lineTo(coords[i + 2], coords[i + 3]);
        i += 2;
      }
      context.closePath();
      return context.stroke();
    });
    return {
      start: canHaveCallback(function(pos) {
        drawing = true;
        hist.punchIn();
        return drawLines([pos[0], pos[1], pos[0], pos[1] + 0.1]);
      }),
      draw: canHaveCallback(function(coords) {
        if (drawing) {
          return drawLines(coords);
        }
      }),
      end: canHaveCallback(function(pos) {
        drawing = false;
        return hist.punchOut();
      }),
      undo: canHaveCallback(function() {
        return hist.undo();
      }),
      redo: canHaveCallback(function() {
        return hist.redo();
      })
    };
  };
}).call(this);
