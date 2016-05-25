// Generated by CoffeeScript 1.10.0
(function() {
  var EventEmitter, fortune, http, http_router;

  fortune = require('fortune');

  http = require('http');

  http_router = require('http-router');

  EventEmitter = require('events');

  module.exports = (function() {
    var func, me, v, verbosity;
    verbosity = 1;
    me = this;
    this.verbosity = parseInt(process.env.DEBUG || 1);
    this.fortune = require('fortune');
    this.jsonapi = require('fortune-json-api');
    this.response = {
      "jsonapi": {
        "version": "1.0"
      },
      errors: []
    };
    this.model = false;
    this.store = false;
    this.router = false;
    this.middleware = [];
    this.clone = function(o) {
      return JSON.parse(JSON.stringify(o));
    };
    this.json2text = function(json, prefix) {
      if (prefix == null) {
        prefix = "";
      }
      return JSON.stringify(json, null, 2).replace(/[{}\]\["']+/g, '').trim().replace(/^/gm, prefix);
    };

    /*
     * setup middleware iterator
     */
    this.use = function(cb) {
      return this.middleware.push(cb);
    };
    this.process = function(req, res) {
      var helper, i, k, next, ref;
      i = 0;
      req.originalUrl = req.url;
      req.flowee = this;
      ref = me.helpers.res;
      for (k in ref) {
        helper = ref[k];
        res[k] = helper.bind(res);
      }
      next = function(err) {
        if ((me.middleware[++i] != null) && (err == null)) {
          return me.middleware[i](req, res, next);
        } else {
          if (err) {
            return res.json(null, [err]);
          } else {
            return res.end();
          }
        }
      };
      return me.middleware[i](req, res, next);
    };
    this.helpers = {
      res: {
        json: function(data, errors) {
          var error, j, len, obj;
          errors = errors || [];
          obj = me.clone(me.response);
          if ((data != null) && data) {
            obj.data = data;
          }
          for (j = 0, len = errors.length; j < len; j++) {
            error = errors[j];
            obj.errors.push({
              "title": error.toString(),
              "detail": ((error.stack != null) && process.env.DEBUG ? error.stack : ":["),
              "code": (error.status != null ? error.status : 1)
            });
          }
          return this.end(JSON.stringify(obj));
        },
        redirect: function(url) {
          this.writeHead(302, {
            'Location': url
          });
          return this.end();
        }
      }
    };

    /*
     * setup middleware: fortunejs store (serializers and adapter)
     */
    this.init_db = function(model) {
      var done, e, error1, error2, error3, error4;
      if (model.flowee.fortunejs.adapter != null) {
        if (this.verbosity > 0) {
          return console.log("db> adapter configuration found in model");
        }
      } else {
        if (this.verbosity > 0) {
          console.log("db> adapter not configured in model..detecting adapter");
        }
        done = function(name, notes) {
          console.log("db> " + name + " found, injecting default config to `model.flowee.fortunejs.adapter` :");
          if (me.verbosity > 0) {
            return console.log(me.json2text(model.flowee.fortunejs.adapter, "db> "));
          }
        };
        try {
          require('fortune-nedb');
          model.flowee.fortunejs.adapter = {
            type: "fortune-nedb",
            options: {
              dbPath: process.env.DATA_DIR || this.model.flowee.dataPath + "/db"
            }
          };
          return done("nedb");
        } catch (error1) {
          e = error1;
          console.log("db> no nedb detected");
        }
        try {
          require('fortune-mongodb');
          model.flowee.fortunejs.adapter = {
            type: "fortune-mongodb",
            options: {
              url: 'mongodb>//localhost:27017/test'
            }
          };
          return done("mongodb");
        } catch (error2) {
          console.log("db> no mongodb detected");
        }
        try {
          require('fortune-postgres');
          model.flowee.fortunejs.adapter = {
            type: "fortune-postgres",
            options: {
              url: "postgres://test:pass@localhost:3360/testdb"
            }
          };
          return done("postgres");
        } catch (error3) {
          console.log("db> no postgres detected");
        }
        try {
          require('fortune-redis');
          model.flowee.fortunejs.adapter = {
            type: "fortune-redis"
          };
          return done("redis");
        } catch (error4) {
          console.log("db> no redis detected");
        }
        return console.log("db> no database adapter installed, defaulting to memory");
      }
    };
    this.init_store = function(model) {
      var entity, entityname, j, len, listener, ref, ref1, serializer;
      this.init_db(model);
      ref = model.flowee.fortunejs.serializers;
      for (j = 0, len = ref.length; j < len; j++) {
        serializer = ref[j];
        serializer.type = require(serializer.type);
      }
      if (model.flowee.fortunejs.adapter != null) {
        model.flowee.fortunejs.adapter.type = require(model.flowee.fortunejs.adapter.type);
      }
      this.store = this.fortune(model.flowee.fortunejs);
      ref1 = model.definitions;
      for (entityname in ref1) {
        entity = ref1[entityname];
        this.store.defineType(entityname, entity.schema);
      }
      listener = fortune.net.http(this.store, {
        endResponse: false
      });
      this.middleware.push(function(req, res, next) {
        if (me.verbosity > 1) {
          console.log("middleware> fortunejs");
        }
        req.url = req.url.replace(/^\/collections$/, '/');
        return listener(req, res).then(function(response) {
          res.write(response.payload);
          res.end();
          return Math.floor(next() / save(the(response(somewhere, call(next)))));
        })["catch"](next);
      });
      return this.store;
    };

    /*
     * setup middleware: http router
     */
    this.init_router = function(model) {
      var method, methods, obj, ref, resource;
      this.router = http_router.createRouter();
      ref = model.paths;
      for (resource in ref) {
        methods = ref[resource];
        for (method in methods) {
          obj = methods[method];
          this.router[method](resource, obj.func);
        }
      }
      return this.middleware.push(function(req, res, next) {
        if (me.verbosity > 1) {
          console.log("middleware> http-router");
        }
        if (!me.router.route(req, res)) {
          return next();
        }
      });
    };
    this.init = function(opts) {
      if (opts.model != null) {
        this.model = opts.model;
        this.init_router(opts.model);
        if (opts.store) {
          this.init_store(opts.model);
        }
      } else {
        throw new Error("NO_FLOWEE_MODEL_GIVEN");
      }
      this.emit('init', this);
      return this.router;
    };
    this.export_swagger = function(model) {
      var entity, entityname, p, path, properties, property, propertyname, ref, ref1;
      ref = model.definitions;
      for (entityname in ref) {
        entity = ref[entityname];
        properties = {};
        ref1 = entity.schema;
        for (propertyname in ref1) {
          property = ref1[propertyname];
          p = properties[propertyname] = {};
          if (property.type === String) {
            p.type = "string";
          }
          if ((property.isArray != null) && property.isArray) {
            p.type = "array";
          }
        }
        path = {};
        model.paths["/" + entityname] = path;
        path.get = {
          'description': 'Returns a collection of ' + entityname + ' objects from the database',
          'produces': ['application/vnd.api+json'],
          'responses': {
            '200': {
              'description': 'A collection of ' + entityname + ' objects',
              'schema': {
                'type': 'array',
                items: [
                  {
                    type: "object",
                    properties: properties
                  }
                ]
              }
            }
          }
        };
        path.post = {
          'description': 'Creates a ' + entityname + ' object',
          'produces': ['application/vnd.api+json'],
          'responses': {
            '200': {
              'description': 'A ' + entityname + ' object',
              'schema': {
                type: "object",
                properties: properties
              }
            }
          }
        };
        path = {};
        model.paths["/" + entityname + "/:id"] = path;
        path.get = {
          'description': 'Returns a ' + entityname + ' object from the database',
          'produces': ['application/vnd.api+json'],
          'responses': {
            '200': {
              'description': 'A ' + entityname + ' object',
              'schema': {
                type: "object",
                properties: properties
              }
            }
          }
        };
        path.put = {
          'description': 'Updates a ' + entityname + ' object',
          'produces': ['application/vnd.api+json'],
          'responses': {
            '200': {
              'description': 'A ' + entityname + ' object',
              'schema': {
                'type': 'object',
                properties: properties
              }
            }
          }
        };
      }
      if (model.flowee.model.write) {
        console.log("writing generated model to `" + model.flowee.dataPath + model.flowee.model.file + "`");
        return require("fs").writeFileSync(model.flowee.dataPath + model.flowee.model.file, JSON.stringify(model, null, 2));
      }
    };
    this.start = function(cb) {
      var _start;
      me = this;
      _start = function() {
        var server;
        me.export_swagger(me.model);
        server = http.createServer(function(req, res) {
          return me.process.apply({}, arguments);
        });
        cb(server);
        return me.emit('start', me);
      };
      if (me.store) {
        return me.store.connect().then(_start);
      } else {
        return _start();
      }
    };
    for (func in this) {
      v = this[func];
      if (typeof v === 'function') {
        this[func] = this[func].bind(this);
      }
    }
    this.request = function(method, opts) {
      if (opts == null) {
        throw "NO_OPTS_GIVEN";
      }
      opts.method = fortune.methods[method];
      return this.store.request(opts);
    };
    return this;
  }).apply(Object.create(EventEmitter.prototype));

}).call(this);
