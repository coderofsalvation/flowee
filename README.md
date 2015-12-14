# Flowee

![](http://coderofsalvation.github.io/flowee/img/flowee.png)

a __very lightweight__ way to __create api's__ using _nodejs_:

## Getting started

    $ npm install flowee

Create `server.js`:

    var flowee = require('flowee')
    var model = require('./model.js');
  
    flowee.start(model, function(server, router) {
      return server.listen(1337);
    });

See [model.js here](https://github.com/coderofsalvation/flowee/blob/master/test/model.js)

    $ node server.js

## Architecture

![](http://coderofsalvation.github.io/flowee/img/diagram.png)

click <A href="http://coderofsalvation.github.io/flowee/img/diagram.png" target="_blank">here</a> to see the fullscreen architecture

* built on the shoulders of [fortunejs](http://fortunejs.com/) for automatic model<->relational database mapping
* [DDA](http://www.slideshare.net/apigee/i-love-apis-2015-create-designdriven-apis-with-nodejs-and-swagger): design-driven api by using a json model 
* SWAGGER v2 compatible json model
* [JSONAPI v1](http://jsonapi.org/) compatible
* middleware compatible: connect [express](http://expressjs.com) and [restify](http://restify.com) middleware modules from npm

## Why 

Take a look at [loopback](http://blog.jeffdouglas.com/2015/07/07/roll-your-own-api-vs-loopback), [meteor](http://meteor.com), [cleverstack](http://cleverstack.io). 
Now imagine lightweight.
Flowee likes to focus on:

* lightweight
* json driven instead of frameworkspecific (file)conventions
* http framework agnostic
* allow re-usage of middleware from http frameworks like express/restify etc
* no cli tools, just code: build and understand your own cli tools
