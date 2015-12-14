# Flowee

![](http://coderofsalvation.github.io/flowee/img/flowee.png)

a __lightweight__ way to _create JSONAPI-compatible api's__ using _nodejs_:

## Getting started

    $ npm install flowee
    $ cp node_modules/flowee/test/model.js .

#### Create `server.js`:

    var flowee = require('flowee')
    var model = require('./model.js');
  
    flowee.start(model, function(server, router) {
      return server.listen(1337);
    });

( See [model.js here](https://github.com/coderofsalvation/flowee/blob/master/test/model.js) )

    $ node server.js

> Voila! Now you have a server running with automatically mapped database entities (incl. __many to many__ relations OHMY).

## Architecture

![](http://coderofsalvation.github.io/flowee/img/diagram.png)

click <A href="http://coderofsalvation.github.io/flowee/img/diagram.png" target="_blank">here</a> to see the fullscreen architecture

* fast installation: core is +/- 10M
* built on the shoulders of [fortunejs](http://fortunejs.com/) for automatic __json 2 relational database__ mapping
* [DDA](http://www.slideshare.net/apigee/i-love-apis-2015-create-designdriven-apis-with-nodejs-and-swagger): design-driven api by using a json model 
* __SWAGGER v2__ compatible json model
* [JSONAPI v1](http://jsonapi.org/) compatible
* __middleware compatible__: connect [express](http://expressjs.com) and [restify](http://restify.com) middleware modules from npm
* by default *Flowee* runs out of the box using __NeDB__, a __mongodb__-ish disk-persistent memory db
* database adapter swappable with [MongoDB](https://www.npmjs.com/package/fortune-mongodb), [Postgres](https://www.npmjs.com/package/fortune-postgres), [Redis](https://www.npmjs.com/package/fortune-redis) adapter

## Howto: Database entities & relations

The `definitions` field in the __SWAGGER__ jsonmodel defines the entities and their relationships:

      }
    },
    definitions: {          <-- here the database entities are defined
      user: {               <-- name of the entity, this translates to api endpoint '/user' and '/user:id'
        name: {             <-- attribute 
          type: String      <-- type of the attribute
    ...

It uses the __fortunejs__ `defineType` format: see docs at [fortunejs](http://fortunejs.com/)

## Howto: custom endpoints

This can be done using the router object :


    flowee.start(model, function(server, router) {

      router.get('/foo', function(req, res, next) {          // <--
        return res.end('{"msg":"Hello foo"}');               // <--
      });                                                    // <--

      server.listen(port);

Or directly using `definitions` field in the __SWAGGER__ jsonmodel defines the entities and their relationships:

      }
    },
    paths: {
      '/': {                                                   <-- endpoint path 
        'get': {
          'description': 'returns hellow world'               
          'produces': ['application/json'],
          'responses': {
            '200': {
              'description': 'A list of owners.',              <-- useful for generated
              'schema': {                                      <-- documentation
                'type': 'object',                              <--
                'properties':{
                  'msg': {'type':"string"}
                }
              }
            }
          },
          func: function(req, res, next) {                     <-- endpoint function
            res.write('{"msg":"Hello world"}');
            res.end();
            return next();

## Data logic / Permissions / Authentication 

Database access can be supervised by introducing [fortunejs transformers](http://fortunejs.com/api/):

    const errors = fortune.errors

    store.transformOutput(type, (context, record) => {
      if (context.request.meta['Authorization'] !== 'secret')
        throw new errors.UnauthorizedError('Not allowed to view this resource.')

      return record
    })

In a similar way this can be done with custom endpoints by introducing authentication middleware __before__ flowee 
is started.
For example using [rest-auth](https://www.npmjs.com/package/rest-auth):

    var auth = require('rest-auth');
 
    // Tell the auth module how to authenticate a user 
    auth.authenticateUser(function(username, password, callback) {
        /* TODO: use nedb in example, not mongodb */
        User.findOne({ username: username }, function(err, user) {
            if (err) {
                return callback(err);
            }
            if (! user) {
                return callback(null, false, 'User does not exists');
            }
            if (hash(password) !== user.password) {
                return callback(null, false, 'Invalid password');
            }
            // The username and password should be given here 
            callback(null, {
                username: username,
                password: user.password
            });
        });
    });:

    flowee.use(auth.authenticate({
        expires: '2 hours',
        authRoute: 'auth-token',
        authTokenHash: {
            algorithm: 'sha256',
            salt: 'saltiness'
        }
    });
  
    flowee.start(model, function(server, router) {
      ..

## Ratelimiting

try [ratelimit-middleware](https://www.npmjs.com/package/ratelimit-middleware)

## Why / Philosophy 

Take a look at [loopback](http://blog.jeffdouglas.com/2015/07/07/roll-your-own-api-vs-loopback), [meteor](http://meteor.com), [cleverstack](http://cleverstack.io). 
Now imagine lightweight.
Flowee likes to focus on:

* lightweight and fast to install
* json driven instead of frameworkspecific (file)conventions
* http framework agnostic
* allow re-usage of middleware from http frameworks like express/restify etc
* no cli tools, just code: build and understand your own cli tools
