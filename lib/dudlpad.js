(function() {
  var DUDLPAD, canHaveCallback, history;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty;
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
        res = inner.apply(pad, args);
      }
      if (after != null) {
        after.apply(pad, args);
      }
      return res;
    };
  };
  history = function() {
    var beforeUndo, hist, hpos, punchIn, punchOut, punchedIn, redo, undo, wrap, _beforeUndo;
    wrap = function(func) {
      return function() {
        var args, res;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        res = func.apply(func, args);
        if (punchedIn) {
          hist[hpos].push({
            func: func,
            args: args
          });
        }
        return res;
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
    var canvas, clearCanvas, context, drawLines, drawing, hist, lineWidth, resetAll, resetCanvas, strokeStyle;
    if (!(container != null)) {
      throw 'null container was passed to `create`.';
    }
    drawLines = null;
    hist = null;
    strokeStyle = null;
    lineWidth = null;
    clearCanvas = null;
    resetCanvas = function() {
      clearCanvas();
      context.strokeStyle = 'black';
      context.lineWidth = 2.0;
      context.lineCap = 'round';
      return context.lineJoin = 'round';
    };
    resetAll = function() {
      hist = history();
      hist.beforeUndo(resetCanvas);
      clearCanvas = hist.wrap(function() {
        return context.clearRect(0, 0, canvas.width, canvas.height);
      });
      drawLines = hist.wrap(function(style, coords) {
        var i, name, value;
        for (name in style) {
          if (!__hasProp.call(style, name)) continue;
          value = style[name];
          context[name] = value;
        }
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
      resetCanvas();
      strokeStyle = context.strokeStyle;
      return lineWidth = context.lineWidth;
    };
    container["class"] = container["class"] + ' dudlpad-container';
    canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    context = canvas.getContext('2d');
    resetAll();
    container.appendChild(canvas);
    drawing = false;
    return {
      start: canHaveCallback(function(pos) {
        drawing = true;
        hist.punchIn();
        drawLines({
          lineWidth: lineWidth,
          strokeStyle: strokeStyle
        }, [pos[0], pos[1], pos[0], pos[1] + 0.1]);
        return this;
      }),
      draw: canHaveCallback(function(coords) {
        if (drawing) {
          drawLines({
            lineWidth: lineWidth,
            strokeStyle: strokeStyle
          }, coords);
        }
        return this;
      }),
      end: canHaveCallback(function(pos) {
        drawing = false;
        hist.punchOut();
        return this;
      }),
      undo: canHaveCallback(function() {
        hist.undo();
        return this;
      }),
      redo: canHaveCallback(function() {
        hist.redo();
        return this;
      }),
      lineColor: canHaveCallback(function(color) {
        if (arguments.length === 0) {
          return strokeStyle;
        }
        strokeStyle = color;
        return this;
      }),
      lineWidth: canHaveCallback(function(width) {
        if (arguments.length === 0) {
          return lineWidth;
        }
        lineWidth = width;
        return this;
      }),
      clear: canHaveCallback(function() {
        hist.punchIn();
        clearCanvas();
        hist.punchOut();
        return this;
      }),
      reset: canHaveCallback(function() {
        resetAll();
        return this;
      })
    };
  };
}).call(this);
