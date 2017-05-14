// Generated by CoffeeScript 1.10.0
var SparseDemo, global,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

global = typeof exports !== "undefined" && exports !== null ? exports : window;

if (!global.SparseDemo) {
  SparseDemo = global.SparseDemo = {};
}

(function($) {
  'use strict';
  SparseDemo.BaseView = (function(superClass) {
    extend(BaseView, superClass);

    function BaseView() {
      return BaseView.__super__.constructor.apply(this, arguments);
    }

    BaseView.prototype.__children = [];

    BaseView.prototype.__parent = {};

    BaseView.prototype.render = function() {
      if (typeof this.subviews !== 'undefined' && (this.subviews != null) && _.isObject(this.subviews)) {
        _.each(this.subviews, ((function(_this) {
          return function(view, selector) {
            if (typeof view === 'undefined') {
              return;
            }
            return _.each(_this.$el.find(selector), function(v, k) {
              return _this.__children.push((_this[selector] = new view({
                el: v,
                __parent: _this
              })));
            });
          };
        })(this)));
        this.delegateEvents();
      }
      return this.childrenComplete();
    };

    BaseView.prototype.setElement = function(el) {
      if (el) {
        this.$el = $(this.el = el);
      }
      this.delegateEvents();
      return this.$el;
    };

    BaseView.prototype.childrenComplete = function() {};

    BaseView.prototype.initialize = function(o) {
      if ((o != null) && o.el) {
        this.setElement(o.el);
      }
      if ((o != null) && o.__parent) {
        this.__parent = o.__parent;
      }
      if (typeof this.init === 'function') {
        if (o != null) {
          this.init(o);
        } else {
          this.init();
        }
      }
      return this.render();
    };

    return BaseView;

  })(Backbone.View);
  return SparseDemo.APIFormView = (function(superClass) {
    extend(APIFormView, superClass);

    function APIFormView() {
      return APIFormView.__super__.constructor.apply(this, arguments);
    }

    APIFormView.prototype.subviews = {
      '.api-btn': SparseDemo.APIFormView = (function(superClass1) {
        extend(APIFormView, superClass1);

        function APIFormView() {
          return APIFormView.__super__.constructor.apply(this, arguments);
        }

        APIFormView.prototype.events = {
          'click': 'handleAPIButton'
        };

        APIFormView.prototype.handleAPIButton = function(evt) {
          evt.preventDefault();
          if (global.app.getCredentials() === null) {
            evt.stopImmediatePropagation();
            global.app['#credentialsModal'].show();
            return false;
          }
        };

        return APIFormView;

      })(SparseDemo.BaseView)
    };

    return APIFormView;

  })(SparseDemo.BaseView);
})(jQuery);