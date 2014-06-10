require.register("index", function(exports, require, module){
    var App, Asset, Setting, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

require('lib/setup');

_ = require('underscore');

Asset = Nex.Models.Asset;

Setting = Nex.Models.Setting;

Nex.debug = window.location.host.indexOf(':') > 0;

Nex.tenant = 'tenantName';

Spine.Model.host = Nex.debug && Nex.data === 'online' ? "http://" + Nex.tenant + ".imagoapp.com/api/v2" : "/api/v2";

App = (function(_super) {
  __extends(App, _super);

  App.prototype.logPrefix = '(App) index: ';

  App.prototype.events = {
    'tap a': 'onNavigate'
  };

  function App() {
    this.goHome = __bind(this.goHome, this);
    this.onNavigate = __bind(this.onNavigate, this);
    this.setBodyClass = __bind(this.setBodyClass, this);
    this.setLanguage = __bind(this.setLanguage, this);
    this.appReady = __bind(this.appReady, this);
    this.onMouseWheelStart = __bind(this.onMouseWheelStart, this);
    this.onScrollStart = __bind(this.onScrollStart, this);
    this.onResizeStart = __bind(this.onResizeStart, this);
    App.__super__.constructor.apply(this, arguments);
    this.models = Nex.Models;
    Spine.Route.on('navigate', (function(_this) {
      return function(url) {
        if (_gaq && !Spine.debug) {
          return _gaq.push(['_trackPageview', "" + url]);
        }
      };
    })(this));
    this.window = $(window);
    this.window.on('resize', this.onResizeStart);
    this.window.on('resize', _.debounce(((function(_this) {
      return function() {
        return _this.window.trigger('resizestop');
      };
    })(this)), 200));
    this.window.on('resize', _.throttle(((function(_this) {
      return function() {
        return _this.window.trigger('resizelimit');
      };
    })(this)), 150));
    this.window.on('scroll', this.onScrollStart);
    this.window.on('scroll', _.debounce(((function(_this) {
      return function() {
        return _this.window.trigger('scrollstop');
      };
    })(this)), 200));
    this.window.on('scroll', _.throttle(((function(_this) {
      return function() {
        return _this.window.trigger('scrolllimit');
      };
    })(this)), 150));
    this.window.on('mousewheel', this.onMouseWheelStart);
    this.window.on('mousewheel', _.debounce(((function(_this) {
      return function() {
        return _this.window.trigger('mousewheelstop');
      };
    })(this)), 200));
    this.window.on('mousewheel', _.throttle(((function(_this) {
      return function() {
        return _this.window.trigger('mousewheellimit');
      };
    })(this)), 150));
    Spine.Route.bind('change', this.setBodyClass);
    this.el.empty();
    this.settings = new $.Deferred();
    Setting.bind('refresh', (function(_this) {
      return function() {
        return _this.settings.resolve();
      };
    })(this));
    this.manager = new Spine.Manager;
    $.when(this.settings).then(this.appReady, this.errorCallback);
    this.routes({
      '/': function() {}
    });
    Setting.fetch();
  }

  App.prototype.onResizeStart = function(e) {
    if (this.resizeing) {
      return;
    }
    this.window.trigger('resizestart');
    this.resizeing = true;
    return this.window.one('resizestop', (function(_this) {
      return function() {
        return _this.resizeing = false;
      };
    })(this));
  };

  App.prototype.onScrollStart = function(e) {
    if (this.scrolling) {
      return;
    }
    this.window.trigger('scrollstart');
    this.scrolling = true;
    return this.window.one('scrollstop', (function(_this) {
      return function() {
        return _this.scrolling = false;
      };
    })(this));
  };

  App.prototype.onMouseWheelStart = function(e) {
    if (this.isMouseWheeling) {
      return;
    }
    this.window.trigger('mousewheelstart');
    this.isMouseWheeling = true;
    return this.window.one('mousewheelstop', (function(_this) {
      return function() {
        return _this.isMouseWheeling = false;
      };
    })(this));
  };

  App.prototype.appReady = function() {
    var options;
    this.log('appReady');
    this.setLanguage();
    options = {
      history: true,
      shim: false
    };
    this.render();
    return Spine.Route.setup(options);
  };

  App.prototype.setLanguage = function() {
    var language;
    language = window.navigator.userLanguage || window.navigator.language;
    Nex.language = language.split('-')[0];
    return Nex.country = language.split('-')[1];
  };

  App.prototype.setBodyClass = function(Route, path) {
    var classes, _base, _ref, _ref1;
    if (path === '/') {
      path = '/home';
    }
    classes = "" + path + " " + (((_ref = this.manager) != null ? (_ref1 = _ref.getActive()) != null ? _ref1.className : void 0 : void 0) || '');
    return document.body.className = typeof (_base = classes.replace(/\//g, ' ')).trim === "function" ? _base.trim() : void 0;
  };

  App.prototype.onNavigate = function(e) {
    var href;
    href = $(e.target).closest('a').attr('href');
    if (href && !href.match(/^http/)) {
      return this.navigate(href);
    }
  };

  App.prototype.render = function() {
    return this.manager.add();
  };

  App.prototype.goHome = function() {
    return this.navigate('/');
  };

  return App;

})(Spine.Controller);

Spine.Manager.include({
  getActive: function() {
    var cont, _i, _len, _ref;
    _ref = this.controllers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cont = _ref[_i];
      if (cont.isActive()) {
        return cont;
      }
    }
  }
});

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
      var a, target, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
      target = $(e.target);
      a = target.closest('a');
      if (!(target.attr('target') === '_blank' || ((_ref = target.attr('href')) != null ? _ref.match(/^mailto/) : void 0) || ((_ref1 = target.attr('href')) != null ? _ref1.match('/api/') : void 0) || ((_ref2 = target.attr('href')) != null ? _ref2.match(/^tel/) : void 0) || ((_ref3 = target.attr('href')) != null ? _ref3.match(/^http/) : void 0) || ((_ref4 = target.attr('type')) != null ? _ref4.match(/checkbox/) : void 0) || ((_ref5 = target.attr('type')) != null ? _ref5.match(/checkbox|text/) : void 0) || target[0].nodeName.match(/LABEL/) || (!target[0].nodeName.match(/A/) && ((_ref6 = a.attr('href')) != null ? _ref6.match(/^http/) : void 0)))) {
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