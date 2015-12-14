![](http://coderofsalvation.github.io/flowee/img/flowee.png)

## Flowee

Flowee is a very lightweight way to create api's:

* built on the shoulders of [fortunejs](http://fortunejs.com/) for automatic model<->relational database mapping
* [DDA](http://www.slideshare.net/apigee/i-love-apis-2015-create-designdriven-apis-with-nodejs-and-swagger): design-driven api by using a json model 
* SWAGGER v2 compatible json model
* [JSONAPI v1](http://jsonapi.org/) compatible
* middleware compatible: connect [express](http://expressjs.com) and [restify](http://restify.com) middleware modules from npm

## Architecture

![](http://coderofsalvation.github.io/flowee/img/diagram.png)

click <A href="http://coderofsalvation.github.io/flowee/img/diagram.png" target="_blank">here</a> to see the fullscreen architecture

## Why 

I took a look at [loopback](http://blog.jeffdouglas.com/2015/07/07/roll-your-own-api-vs-loopback), [meteor](http://meteor.com), [cleverstack](http://cleverstack.io). 
They all have their pros/cons, which is fine.
However, _rolling your own_ polylithic api isn't that hard given the myriad of npm modules. 
Flowee likes to focus on:

* lightweight
* jsonmodel driven
* no fileconventions
* http framework agnostic
* allow re-usage of middleware from http frameworks like express/restify etc
* no cli tools, just code: build and understand your own cli tools
