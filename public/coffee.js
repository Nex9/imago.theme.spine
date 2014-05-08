require.register("index", function(exports, require, module){
    var App,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

require('lib/setup');

App = (function(_super) {
  __extends(App, _super);

  App.prototype.logPrefix = '(App) index: ';

  function App() {
    App.__super__.constructor.apply(this, arguments);
  }

  return App;

})(Spine.Controller);

module.exports = App;

});
require.register("lib/setup", function(exports, require, module){
    require('json2ify');

require('es5-shimify');

require('jqueryify');

require('underscore');

require('spine');

require('spine/lib/ajax');

require('spine/lib/manager');

require('spine/lib/route');

require('lib/touch');

require('lib/screenfull');

require('nex/lib/nex');

require('nex/lib/utils');

require('nex/lib/models');

require('nex/lib/panel');

require('nex/lib/widgets');

require('nex/lib/page');

require('nex/lib/contact');

});
require.register("lib/touch", function(exports, require, module){
    var $, m, parentIfText, swipeDirection, touch, types, _fn, _i, _len;

$ = require('spine').$;

$.support.touch = !!navigator.userAgent.match(/iPad|iPhone|iPod/i);

touch = {};

parentIfText = function(node) {
  if ('tagName' in node) {
    return node;
  } else {
    return node.parentNode;
  }
};

swipeDirection = function(x1, x2, y1, y2) {
  var xDelta, yDelta;
  xDelta = Math.abs(x1 - x2);
  yDelta = Math.abs(y1 - y2);
  if (xDelta >= yDelta) {
    if (x1 - x2 > 0) {
      return 'Left';
    } else {
      return 'Right';
    }
  } else {
    if (y1 - y2 > 0) {
      return 'Up';
    } else {
      return 'Down';
    }
  }
};

$(function() {
  return $('body').bind('touchstart', function(e) {
    var delta, now;
    e = e.originalEvent;
    now = Date.now();
    delta = now - (touch.last || now);
    touch.target = parentIfText(e.touches[0].target);
    touch.x1 = e.touches[0].pageX;
    touch.y1 = e.touches[0].pageY;
    return touch.last = now;
  }).bind('touchmove', function(e) {
    e = e.originalEvent;
    touch.x2 = e.touches[0].pageX;
    return touch.y2 = e.touches[0].pageY;
  }).bind('touchend', function(e) {
    e = e.originalEvent;
    if (touch.x2 > 0 || touch.y2 > 0) {
      (Math.abs(touch.x1 - touch.x2) > 30 || Math.abs(touch.y1 - touch.y2) > 30) && $(touch.target).trigger('swipe') && $(touch.target).trigger('swipe' + (swipeDirection(touch.x1, touch.x2, touch.y1, touch.y2)));
      return touch.x1 = touch.x2 = touch.y1 = touch.y2 = touch.last = 0;
    } else if ('last' in touch) {
      $(touch.target).trigger('tap');
      return touch = {};
    }
  }).bind('touchcancel', function(e) {
    return touch = {};
  });
});

if ($.support.touch) {
  $('body').bind('click', function(e) {
    var target, _ref, _ref1, _ref2;
    target = $(e.target);
    if (!(target.attr('target') === '_blank' || ((_ref = target.attr('href')) != null ? _ref.match(/^mailto/) : void 0) || ((_ref1 = target.attr('href')) != null ? _ref1.match(/^tel/) : void 0) || ((_ref2 = target.attr('href')) != null ? _ref2.match(/^http/) : void 0))) {
      return e.preventDefault();
    }
  });
} else {
  $(function() {
    return $('body').bind('click', function(e) {
      var target, _ref, _ref1, _ref2, _ref3, _ref4;
      target = $(e.target);
      if (!(target.attr('target') === '_blank' || ((_ref = target.attr('href')) != null ? _ref.match(/^mailto/) : void 0) || ((_ref1 = target.attr('href')) != null ? _ref1.match(/^tel/) : void 0) || ((_ref2 = target.attr('href')) != null ? _ref2.match(/^http/) : void 0) || ((_ref3 = target.attr('type')) != null ? _ref3.match(/checkbox/) : void 0) || ((_ref4 = target.attr('type')) != null ? _ref4.match(/checkbox|text/) : void 0) || target[0].nodeName.match(/LABEL/))) {
        e.preventDefault();
      }
      return target.trigger('tap');
    });
  });
}

types = ['swipe', 'swipeLeft', 'swipeRight', 'swipeUp', 'swipeDown', 'tap'];

_fn = function(m) {
  return $.fn[m] = function(callback) {
    return this.bind(m, callback);
  };
};
for (_i = 0, _len = types.length; _i < _len; _i++) {
  m = types[_i];
  _fn(m);
}

});