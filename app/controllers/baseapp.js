(function() {
  var BaseApp, BrowserWarning, Maintenance, Setting, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  require('lib/setup');

  _ = require('underscore');

  Setting = Nex.Models.Setting;

  Nex.debug = window.location.host.indexOf(':') > 0;

  Maintenance = require('controllers/maintenance');

  BrowserWarning = require('controllers/browserwarning');

  Nex.data = window.location.host.indexOf('8080') + 1 ? 'local' : 'online';

  Spine.Model.host = Nex.debug && Nex.data === 'online' ? "http://" + Nex.tenant + ".imagoapp.com/api/v2" : "/api/v2";

  BaseApp = (function(_super) {
    __extends(BaseApp, _super);

    BaseApp.prototype.logPrefix = '(App) index: ';

    BaseApp.prototype.events = {
      'tap a': 'onNavigate'
    };

    function BaseApp() {
      this.onNavigate = __bind(this.onNavigate, this);
      this.setBodyClass = __bind(this.setBodyClass, this);
      this.setLanguage = __bind(this.setLanguage, this);
      this.appReady = __bind(this.appReady, this);
      this.onMouseWheelStart = __bind(this.onMouseWheelStart, this);
      this.onScrollStart = __bind(this.onScrollStart, this);
      this.onResizeStart = __bind(this.onResizeStart, this);
      BaseApp.__super__.constructor.apply(this, arguments);
      this.el.empty();
      this.models = Nex.Models;
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
      this.settings = new $.Deferred();
      Setting.bind('refresh', (function(_this) {
        return function() {
          return _this.settings.resolve();
        };
      })(this));
      this.manager = new Spine.Manager;
      $.when(this.settings).then(this.appReady, this.errorCallback);
      Setting.fetch();
    }

    BaseApp.prototype.onResizeStart = function(e) {
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

    BaseApp.prototype.onScrollStart = function(e) {
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

    BaseApp.prototype.onMouseWheelStart = function(e) {
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

    BaseApp.prototype.appReady = function() {
      var language, options;
      this.log('appReady');
      language = window.navigator.userLanguage || window.navigator.language;
      Nex.language = language.split('-')[0];
      Nex.country = language.split('-')[1];
      options = {
        history: true,
        shim: false
      };
      if (bowser.msie && bowser.version <= 8) {
        return this.append(new BrowserWarning({
          bowser: bowser
        }));
      } else if (Nex.maintenance) {
        return this.append(new Maintenance);
      } else {
        Setting.setSessionData();
        this.render();
        Spine.Route.setup(options);
        return this.navigate(window.location.pathname);
      }
    };

    BaseApp.prototype.setLanguage = function(Route, path) {
      path = path.split('/');
      if (!!path[1]) {
        return Nex.language = path[1];
      }
    };

    BaseApp.prototype.setBodyClass = function(Route, path) {
      var classes, _base, _ref, _ref1;
      if (path === '/') {
        path = '/home';
      }
      classes = "" + path + " " + (((_ref = this.manager) != null ? (_ref1 = _ref.getActive()) != null ? _ref1.className : void 0 : void 0) || '');
      return document.body.className = typeof (_base = classes.replace(/\//g, ' ')).trim === "function" ? _base.trim() : void 0;
    };

    BaseApp.prototype.onNavigate = function(e) {
      var href;
      href = $(e.target).closest('a').attr('href');
      if (href && !href.match(/^http/)) {
        return this.navigate(href);
      }
    };

    BaseApp.prototype.render = function() {};

    return BaseApp;

  })(Spine.Controller);

  module.exports = BaseApp;

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

}).call(this);
