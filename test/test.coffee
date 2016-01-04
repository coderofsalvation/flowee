flowee       = require './../index.coffee'
model        = require './model.coffee'
responsetime = require 'response-time'
name         = "foo-"+new Date()
request      = require './util/requester.coffee'
t            = require './util/tester.coffee'

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
    t.error "collections not found" if not json.links.users? or not json.links.roles?
    next()

t.test 'router hello world', (next) ->
  request 'GET', '/', false, (json) ->
    t.error "hello world not found" if json.msg is not 'Hello world'
    next()

flowee.use responsetime()
app = flowee.init {model:model, store:true }
flowee.start (server) ->
  port = process.env.PORT || 1337
  console.log "starting flowee at port %s",port
  server.listen port
  t.run()
