## Flowee

a __lightweight__ way to __create JSONAPI__-compatible api's using _nodejs_:

![Build Status](https://travis-ci.org/coderofsalvation/flowee.svg?branch=master)

## Getting started

    $ npm install flowee
    $ cp node_modules/flowee/test/model.js .

__Create `server.js`:__

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

## Docs

* [Configuring database objects (and relations)](http://flowee.isvery.ninja/doc/howto-database.html)
* [Configuring custom endpoints](http://flowee.isvery.ninja/doc/howto-custom-endpoints.html)
* [Implementing logic](http://flowee.isvery.ninja/doc/howto-logic.html)
* [Middleware](http://flowee.isvery.ninja/doc/howto-middleware.html)

## Features

* fast installation: core is +/- 10M
* built on the shoulders of [fortunejs](http://fortunejs.com/) for automatic __json 2 relational database__ mapping
* [DDA](http://www.slideshare.net/apigee/i-love-apis-2015-create-designdriven-apis-with-nodejs-and-swagger): design-driven api by using a json model 
* __SWAGGER v2__ compatible json model
* [JSONAPI v1](http://jsonapi.org/) compatible
* __middleware compatible__: connect [express](http://expressjs.com) and [restify](http://restify.com) middleware modules from npm
* by default *Flowee* runs out of the box using __NeDB__, a __mongodb__-ish disk-persistent memory db
* database adapter swappable with [MongoDB](https://www.npmjs.com/package/fortune-mongodb), [Postgres](https://www.npmjs.com/package/fortune-postgres), [Redis](https://www.npmjs.com/package/fortune-redis) adapter


## Why / Philosophy 

Take a look at [loopback](http://blog.jeffdouglas.com/2015/07/07/roll-your-own-api-vs-loopback), [meteor](http://meteor.com), [cleverstack](http://cleverstack.io). 
Now imagine lightweight.
Flowee likes to focus on:

* lightweight and fast to install
* json driven instead of frameworkspecific (file)conventions
* http framework agnostic
* allow re-usage of middleware from http frameworks like express/restify etc
* no cli tools, just code: build and understand your own cli tools






