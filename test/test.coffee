fetch        = require 'node-fetch'
flowee       = require './../index.coffee'
model        = require './model.coffee'
nedb         = require 'fortune-nedb'
responsetime = require 'response-time'
name         = "foo-"+new Date()
t            = require './tester.coffee'

request = (method,resource,data,cb) ->
  console.log method+" "+resource+" "+JSON.stringify( data,null,2 ) if process.env.DEBUG
  options = 
    method: method 
    headers:
      "Content-Type": "application/vnd.api+json"
      "Accept": "application/vnd.api+json"
  options.body = JSON.stringify data if data
  fetch 'http://localhost:1337'+resource, options
  .then (res,err) -> 
    console.log "responsetime: "+res.headers.get 'x-response-time'
    console.dir err if err
    res.json()
  .then (json,err) ->
    console.log JSON.stringify( json,null,2 ) if process.env.DEBUG
    cb(json)
  

t.test 'posting user', (next) ->
  request 'POST', '/user', 
    data:
      type: "user"
      attributes:
        name: name 
  , (json) ->
    next()

t.test 'requesting users', (next) ->      
  request 'GET', '/user', false, (json) ->
    if json.data[0].attributes.name != name 
      t.error "name not found"
    next()

t.test 'fortune collections', (next) ->
  request 'GET', '/collections', false, (json) ->
    t.error "collections not found" if not json.links.users or not json.links.posts
    next()

t.test 'router hello world', (next) ->
  request 'GET', '/', false, (json) ->
    t.error "hello world not found" if json.msg is not 'Hello world'
    next()

t.test 'tests done', (next) ->
  if not t.errors
    console.log "\nOK\n"
    process.exit 0 
  else
    console.log "\nERROR: some tests failed\n"
    process.exit 1

flowee.use responsetime()
flowee.init {model:model, store:true }
flowee.start (server,router) ->
  port = process.env.PORT || 1337
  console.log "starting flowee at port %s",port
  server.listen port
  t.run()
