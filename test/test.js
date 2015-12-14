// Generated by CoffeeScript 1.10.0
(function() {
  var async, error, fetch, flowee, model, name, request;

  fetch = require('node-fetch');

  async = require('async');

  flowee = require('./../index.coffee');

  model = require('./model.coffee');

  name = "foo-" + new Date();

  error = function(msg) {
    console.error("ERROR: name not found");
    return process.exit(1);
  };

  request = function(method, resource, data, cb) {
    var options;
    if (process.env.DEBUG) {
      console.log(method + " " + resource + " " + JSON.stringify(data, null, 2));
    }
    options = {
      method: method,
      headers: {
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
    };
    if (data) {
      options.body = JSON.stringify(data);
    }
    return fetch('http://localhost:1337' + resource, options).then(function(res, err) {
      console.dir(err);
      return res.json();
    }).then(function(json, err) {
      if (process.env.DEBUG) {
        console.log(JSON.stringify(json, null, 2));
      }
      return cb(json);
    });
  };

  flowee.start(model, function(server) {
    var port, tests;
    port = process.env.PORT || 1337;
    console.log("starting flowee at port %s", port);
    server.listen(port);
    tests = {};
    tests['posting user'] = function(next) {
      return request('POST', '/user', {
        data: {
          type: "user",
          attributes: {
            name: name
          }
        }
      }, function(json) {
        return next();
      });
    };
    tests['requesting users'] = function(next) {
      return request('GET', '/user', false, function(json) {
        console.dir(json);
        if (json.data[0].attributes.name !== name) {
          error("name not found");
        }
        return next();
      });
    };
    tests['tests done'] = function(next) {
      console.log("OK");
      return process.exit(0);
    };
    return async.series(tests);
  });

}).call(this);