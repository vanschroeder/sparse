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
  return SparseDemo.ModelView = (function(superClass) {
    extend(ModelView, superClass);

    function ModelView() {
      return ModelView.__super__.constructor.apply(this, arguments);
    }

    ModelView.prototype.reset = function() {
      this['form'].model.clear();
      return this['form'].model.set(this['form'].__defaults);
    };

    ModelView.prototype.subviews = {
      'form': SparseDemo.ModelForm = (function(superClass1) {
        var SparseClass;

        extend(ModelForm, superClass1);

        function ModelForm() {
          return ModelForm.__super__.constructor.apply(this, arguments);
        }

        ModelForm.prototype.__defaults = {
          name: 'Record One',
          description: 'This record created with sParse'
        };

        ModelForm.prototype.init = function(o) {
          this.events = _.extend(this.events, ModelForm.__super__.events);
          this.delegateEvents();
          this.model.set(this.__defaults);
          this.model.on('change', (function(_this) {
            return function() {
              var n;
              return _this.$el.find('#create_model').attr('disabled', !(n = _this.model.isNew())).siblings().attr('disabled', n);
            };
          })(this));
          return rivets.bind(this.el, {
            model: this.model
          });
        };

        ModelForm.prototype.model = new (SparseClass = (function(superClass2) {
          extend(SparseClass, superClass2);

          function SparseClass() {
            return SparseClass.__super__.constructor.apply(this, arguments);
          }

          return SparseClass;

        })(sparse.Model));

        ModelForm.prototype.events = {
          'click #create_model': function(evt) {
            return this.model.save(null, {
              success: (function(_this) {
                return function(m, r, o) {
                  return _this.__parent.__parent.collection.destroy(m);
                };
              })(this),
              error: function(m, r, o) {
                return console.log('failed to create model');
              }
            });
          },
          'click #update_model': function(evt) {
            evt.preventDefault();
            this.model.save({
              success: (function(_this) {
                return function(m, r, o) {};
              })(this),
              error: function(m, r, o) {
                return console.log('failed to update model');
              }
            });
            return false;
          },
          'click #destroy_model': function(evt) {
            evt.preventDefault();
            this.model.destroy({
              success: (function(_this) {
                return function(m, r, o) {
                  _this.__parent.__parent.collection.remove(_.filter(_this.__parent.__parent.collection.models, function(o) {
                    return o.attributes.path.match(new RegExp("\/" + _this.model.id + "+$"));
                  }));
                  return _this.__parent.reset();
                };
              })(this),
              error: function(m, r, o) {
                return console.log('failed to destroy model');
              }
            });
            return false;
          }
        };

        return ModelForm;

      })(SparseDemo.APIFormView)
    };

    return ModelView;

  })(SparseDemo.BaseView);
})(jQuery);