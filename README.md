## Flowee

a __lightweight__ way to __create JSONAPI__-compatible api's for _nodejs_

![Build Status](https://travis-ci.org/coderofsalvation/flowee.svg?branch=master)

## Getting started

    $ npm install flowee
    $ cp node_modules/flowee/test/model.js .

__Create `server.js`:__

    var flowee = require('flowee')
  
    var app = flowee.init({ model: require('./model.js'), store: true });
    flowee.start( function(server) {
      return server.listen(1337);
    });

( See [model.js here](https://github.com/coderofsalvation/flowee/blob/master/test/model.js) )

    $ node server.js

> Voila! Now you have a server running with automatically mapped database entities (incl. __many to many__ relations OHMY).

## Architecture

![](http://coderofsalvation.github.io/flowee/img/diagram.png)

__Flowee__ promotes [configuration over convention](http://flowee.isvery.ninja/doc/howto-configuration-over-convention), click <A href="http://coderofsalvation.github.io/flowee/img/diagram.png" target="_blank">here</a> to see the fullscreen architecture

## Howtos

* [I want a database structure)](http://flowee.isvery.ninja/doc/howto-database.html)
* [I want custom endpoints](http://flowee.isvery.ninja/doc/howto-custom-endpoints.html)
* [I want to implementing logic](http://flowee.isvery.ninja/doc/howto-logic.html)
* [Middleware](http://flowee.isvery.ninja/doc/howto-middleware.html)

## Features

Built on the shoulders of [fortunejs](http://fortunejs.com/), which represents:

* fast installation: core is +/- 10M
* [configuration over convention](http://flowee.isvery.ninja/doc/howto-configuration-over-convention)
* a teaspoon of automatic database object relations mappings 
* 5 liters of [JSONAPI v1](http://jsonapi.org/) compatible REST responses 
* swappable database adapters like [MongoDB](https://www.npmjs.com/package/fortune-mongodb), [Postgres](https://www.npmjs.com/package/fortune-postgres), [Redis](https://www.npmjs.com/package/fortune-redis) adapter

Oh..and:

* [DDA](http://www.slideshare.net/apigee/i-love-apis-2015-create-designdriven-apis-with-nodejs-and-swagger): design-driven api by using a json __SWAGGER v2__ compatible model 
* __middleware compatible__: connect [express](http://expressjs.com) and [restify](http://restify.com) middleware modules from npm

## Extensions

<img alt="" src="https://github.com/coderofsalvation/flowee-doc/raw/master/.doc/apiexplorer.png" height="200px"/>
> [__flowee-doc__](https://npmjs.org/flowee-doc): automatic generating api

<img alt="" src="https://pbs.twimg.com/profile_images/599259952574693376/DMrPoJtc.png" height="200px"/>
> [__flowee-auth__](https://npmjs.org/flowee-auth): passport authentication

## Philosophy 

Take a look at [loopback](http://blog.jeffdouglas.com/2015/07/07/roll-your-own-api-vs-loopback), [meteor](http://meteor.com), [cleverstack](http://cleverstack.io). 
Now imagine lightweight.
Flowee likes to focus on:

* lightweight and fast to install
* json driven, declarative (monkeypatchable configuration over convention)
* http framework agnostic
* [configuration over convention](http://flowee.isvery.ninja/doc/howto-configuration-over-convention)
* allow re-usage of middleware from http frameworks like express/restify etc
* extend using npm installs: no cli tools, no learningcurve






