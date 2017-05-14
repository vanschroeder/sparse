// Generated by CoffeeScript 1.6.2
var Backbone, global, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

global = typeof exports !== "undefined" && exports !== null ? exports : window;

if (typeof exports !== 'undefined') {
  _ = require('underscore')._;
  Backbone = require('backbone');
}

(function() {
  'use strict';
  var sparse, _ref, _ref1;

  if (!global.sparse) {
    sparse = global.sparse = {
      VERSION: "0.0.1",
      APP_ID: void 0,
      REST_KEY: void 0,
      SESSION_TOKEN: void 0,
      API_VERSION: "1",
      MAX_BATCH_SIZE: 50,
      DEFAULT_FETCH_LIMIT_OVERRIDE: 200000,
      UNDEFINED_CLASSNAME: '__UNDEFINED_CLASSNAME__',
      API_URI: "http://ec2-34-224-166-183.compute-1.amazonaws.com:1337/parse",
      CRUD_METHODS: {
        create: 'POST',
        read: 'GET',
        update: 'PUT',
        destroy: 'DELETE'
      },
      apiOPTS: function() {
        return {
          contentType: "application/json",
          processData: false,
          dataType: 'json',
          data: null,
          headers: {
            'Content-Type': 'application/json',
            'X-Parse-Application-Id': sparse.APP_ID,
            'X-Parse-REST-API-Key': sparse.REST_KEY,
            'X-Parse-Session-Token': sparse.SESSION_TOKEN
          }
        };
      },
      getConstructorName: function(fun) {
        var n;

        return fun.constructor.name || ((n = fun.constructor.toString().match(/function+\s{1,}([A-Z]{1}[a-zA-Z]*)/)) != null ? n[1] : sparse.UNDEFINED_CLASSNAME);
      },
      Inflection: new (function() {
        return {
          __uncountable_words: ['equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'moose', 'deer', 'news'],
          __plural_rules: [[/(m)an$/gi, '$1en'], [/(pe)rson$/gi, '$1ople'], [/(child)$/gi, '$1ren'], [/^(ox)$/gi, '$1en'], [/(ax|test)is$/gi, '$1es'], [/(octop|vir)us$/gi, '$1i'], [/(alias|status)$/gi, '$1es'], [/(bu)s$/gi, '$1ses'], [/(buffal|tomat|potat)o$/gi, '$1oes'], [/([ti])um$/gi, '$1a'], [/sis$/gi, 'ses'], [/(?:([^f])fe|([lr])f)$/gi, '$1$2ves'], [/(hive)$/gi, '$1s'], [/([^aeiouy]|qu)y$/gi, '$1ies'], [/(x|ch|ss|sh|lens)$/gi, '$1es'], [/(matr|vert|ind)ix|ex$/gi, '$1ices'], [/([m|l])ouse$/gi, '$1ice'], [/(quiz)$/gi, '$1zes'], [/s$/gi, 's'], [/$/gi, 's']],
          apply_rules: function(str, rules, skip) {
            var rx,
              _this = this;

            if ((skip.indexOf(str.toLowerCase())) === -1) {
              if ((rx = _.find(rules, function(itm) {
                return str.match(itm[0]);
              })) != null) {
                return str.replace(rx[0], rx[1]);
              }
            }
            return str;
          },
          pluralize: function(str) {
            return this.apply_rules(str, this.__plural_rules, this.__uncountable_words);
          }
        };
      })
    };
  }
  sparse.Model = (function(_super) {
    __extends(Model, _super);

    Model.prototype.idAttribute = "objectId";

    function Model(attributes, options) {
      Model.__super__.constructor.call(this, attributes, options);
      if (typeof this.className === 'undefined' || this.className === null) {
        this.className = sparse.getConstructorName(this);
      }
      if (this.className === sparse.UNDEFINED_CLASSNAME) {
        console.warn("sparse.Collection requires className to be defined");
      }
      this.className = sparse.Inflection.pluralize(this.className);
    }

    Model.prototype.url = function() {
      return "" + sparse.API_URI + "/classes/" + this.className + (!this.isNew() ? '/' + (this.get('objectId')) : '');
    };

    Model.prototype.sync = function(method, model, options) {
      var opts;

      if (options == null) {
        options = {};
      }
      opts = sparse.apiOPTS();
      opts.data = JSON.stringify(this.toJSON());
      return Backbone.Model.prototype.sync.call(this, method, model, _.extend(options, opts));
    };

    Model.prototype.toJSON = function(options) {
      var data;

      data = Model.__super__.toJSON.call(this, options);
      delete data.createdAt;
      delete data.updatedAt;
      return data;
    };

    Model.prototype.__ops = [];

    Model.prototype.increment = function(attr, amount) {};

    return Model;

  })(Backbone.Model);
  sparse.Model.saveAll = function(list, options) {
    var _this = this;

    return (new sparse.Batch(list)).exec({
      complete: function(m, r, o) {
        if (options.success) {
          return options.success(m, r, o);
        }
      },
      error: function(m, r, o) {
        if (options.error) {
          return options.error(m, r, o);
        }
      }
    });
  };
  sparse.Collection = (function(_super) {
    __extends(Collection, _super);

    Collection.prototype.__count = void 0;

    Collection.prototype.count = function() {
      return this.__count || this.models.length;
    };

    function Collection(attributes, options) {
      Collection.__super__.constructor.call(this, attributes, options);
      if (typeof this.className === 'undefined' || this.className === null) {
        this.className = sparse.getConstructorName(this);
      }
      if (this.className === sparse.UNDEFINED_CLASSNAME) {
        console.warn("sparse.Collection requires className to be defined");
      }
      this.className = sparse.Inflection.pluralize(this.className);
    }

    Collection.prototype.__params = {
      limit: sparse.DEFAULT_FETCH_LIMIT_OVERRIDE,
      count: 1
    };

    Collection.prototype.getParams = function() {
      var _this = this;

      return (_.map(_.pairs(this.__params || null), function(v, k) {
        return v.join('=');
      })).join('&');
    };

    Collection.prototype.url = function() {
      var p;

      return encodeURI("" + sparse.API_URI + "/classes/" + this.className + (this.__method === 'read' && (p = this.getParams()).length ? '?' + p : ''));
    };

    Collection.prototype.parse = function(options) {
      var data;

      data = Collection.__super__.parse.call(this, options);
      return data.results || data;
    };

    Collection.prototype.sync = function(__method, model, options) {
      var opts,
        _this = this;

      this.__method = __method;
      if (options == null) {
        options = {};
      }
      opts = sparse.apiOPTS();
      if (this.__method === 'read') {
        _.each(['order', 'count', 'limit', 'where'], function(v, k) {
          if (options[v]) {
            _this.__params[v] = JSON.stringify(options[v]);
            return delete options[v];
          }
        });
      }
      opts.success = function(m, r, o) {
        _this.__params = {
          limit: sparse.DEFAULT_FETCH_LIMIT_OVERRIDE,
          count: 1
        };
        if (options.success != null) {
          return options.success(m, r, o);
        }
      };
      return Backbone.Collection.prototype.sync.call(this, this.__method, model, _.extend(_.clone(options), opts));
    };

    Collection.prototype.query = function(query, options) {
      if (options == null) {
        options = {};
      }
      return this.fetch(_.extend(options, {
        where: query
      }));
    };

    Collection.prototype.save = function(options) {
      var _this = this;

      return _.each(this.models, function(v, k) {
        if (v.isNew() || v.hasChanged()) {
          return v.fetch(options);
        }
      });
    };

    return Collection;

  })(Backbone.Collection);
  sparse.User = (function(_super) {
    __extends(User, _super);

    function User() {
      _ref = User.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    User.prototype.defaults = {
      username: null,
      password: null,
      email: null
    };

    User.prototype.__action = 'operate';

    User.prototype.urlMap = {
      create: "" + sparse.API_URI + "/users",
      login: "" + sparse.API_URI + "/login",
      passwordReset: "" + sparse.API_URI + "/requestPasswordReset",
      operate: "" + sparse.API_URI + "/users"
    };

    User.prototype.url = function() {
      return this.urlMap[this.__action] + (this.__action === 'operate' && !this.isNew() ? "/" + (this.get('objectId')) : '');
    };

    User.prototype.logout = function() {
      sparse.SESSION_TOKEN = void 0;
      return this.urlMap['login'] = this.urlMap['login'].replace(/\/login+.*/, '/login');
    };

    User.prototype.login = function(username, password, options) {
      var opts,
        _this = this;

      this.__action = 'login';
      this.urlMap['login'] = encodeURI(this.urlMap['login'].replace(/\/login+.*/, "/login?username=" + username + "&password=" + password));
      opts = {};
      opts.success = function(m, r, o) {
        sparse.SESSION_TOKEN = _this.get('sessionToken');
        delete _this.attributes.sessionToken;
        if (options.success) {
          return options.success(m, r, o);
        }
      };
      return this.fetch(_.extend(_.clone(options), opts));
    };

    User.prototype.save = function(attributes, options) {
      this.__action = (this.isNew() ? 'create' : 'operate');
      return User.__super__.save.call(this, attributes, options);
    };

    User.prototype.destroy = function(options) {
      var opts,
        _this = this;

      this.__action = 'operate';
      opts = {};
      opts.success = function(m, r, o) {
        _this.logout();
        if (options.success) {
          return options.success(m, r, o);
        }
      };
      return User.__super__.destroy.call(this, _.extend(_.clone(options), opts));
    };

    User.prototype.resetPassword = function(options) {
      var email;

      if ((email = this.get('email')) === null) {
        return false;
      }
      this.__action = 'passwordReset';
      return User.__super__.save.call(this, {
        email: email
      }, options);
    };

    return User;

  })(sparse.Model);
  sparse.Users = (function(_super) {
    __extends(Users, _super);

    function Users() {
      _ref1 = Users.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Users.prototype.url = function() {
      return "" + sparse.API_URI + "/users";
    };

    return Users;

  })(sparse.Collection);
  return sparse.Batch = (function(_super) {
    __extends(Batch, _super);

    function Batch(attributes, options) {
      Batch.__super__.constructor.call(this, attributes, options);
    }

    Batch.prototype.url = function() {
      return "" + sparse.API_URI + "/batch";
    };

    Batch.prototype.__processed = [];

    Batch.prototype.processed = function(flatten) {
      if (flatten == null) {
        flatten = true;
      }
      if (flatten) {
        return _.flatten(this.__processed);
      } else {
        return this.__processed;
      }
    };

    Batch.prototype.toJSON = function(options) {
      return JSON.stringify({
        requests: Batch.__super__.toJSON.call(this, options)
      });
    };

    Batch.prototype._memberIsNew = function(attrs) {
      return (attrs.hasOwnProperty('isNew') && attrs.isNew()) || (typeof (attrs.get('objectId')) === 'undefined' || attrs.get('objectId' === null || attrs.get('objectId' === "")));
    };

    Batch.prototype._prepareModel = function(attrs, options) {
      var obj;

      if (options == null) {
        options = {};
      }
      if (!(options.hasOwnProperty('destroy'))) {
        options = _.extend(options, {
          destroy: false
        });
      }
      if (options.destroy && this._memberIsNew(attrs)) {
        obj = null;
      } else {
        obj = {
          method: sparse.CRUD_METHODS[options.destroy ? 'destroy' : (this._memberIsNew(attrs) ? 'create' : 'update')],
          path: "/" + sparse.API_VERSION + "/classes/" + attrs.className + (!this._memberIsNew(attrs) ? '/' + attrs.get('objectId') : '')
        };
        if (!options.destroy) {
          obj.body = attrs;
        }
      }
      return Backbone.Collection.prototype._prepareModel.call(this, obj, options);
    };

    Batch.prototype.sync = function(method, model, options) {
      var opts,
        _this = this;

      if (!model.models || model.models.length === 0) {
        return;
      }
      opts = sparse.apiOPTS();
      opts.data = JSON.stringify({
        requests: (this.__to_remove = model.slice(0, (sparse.MAX_BATCH_SIZE >= 0 && sparse.MAX_BATCH_SIZE < model.models.length ? sparse.MAX_BATCH_SIZE : model.models.length)))
      });
      opts.success = function(m, r, o) {
        _this.__processed.push(_.map(m, function(v, k, l) {
          return _.chain(_this.__to_remove[k].get('body')).tap(function(_o) {
            if (typeof _o !== 'undefined') {
              return _o.set(v.success);
            } else {
              return _o = v.success;
            }
          }).value();
        }));
        _this.remove(_this.__to_remove, {
          index: 0,
          silent: true
        });
        setTimeout((function() {
          if (model.models.length > 0) {
            return _this.sync(method, _this, options);
          } else {
            if (options.complete) {
              return options.complete(_this.__processed, r, o);
            }
          }
        }), 200);
        if (options.success) {
          return options.success(m, r, o);
        }
      };
      opts.error = function(m, r, o) {
        if (options.error) {
          return options.error(m, r, o);
        }
      };
      opts.complete = function(m, r, o) {
        if (options.completed) {
          return options.completed(m, r, o);
        }
      };
      return Backbone.sync(method, model, _.extend(_.clone(options), opts));
    };

    Batch.prototype.fetch = function(options) {
      return console.warn('fetch is not supported by sparse.Batch try using sparse.Collection instead');
    };

    Batch.prototype.exec = function(options) {
      return this.sync('create', this, options);
    };

    Batch.prototype.destroy = function(models, options) {
      return this.add(models, _.extend(_.clone(options || {}), {
        destroy: true
      }));
    };

    Batch.prototype.save = function(models, options) {
      return this.add(models, options);
    };

    return Batch;

  })(sparse.Collection);
}).call(this);
