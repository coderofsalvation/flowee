fetch = require 'node-fetch'
async = require 'async'
flowee = require './../index.coffee'
model  = require './model.coffee'
name = "foo-"+new Date()

error = (msg) -> 
  console.error "ERROR: name not found"
  process.exit(1)
  
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
    console.dir err
    res.json()
  .then (json,err) ->
    console.log JSON.stringify( json,null,2 ) if process.env.DEBUG
    cb(json)

flowee.start model, (server) ->
  port = process.env.PORT || 1337
  console.log "starting flowee at port %s",port
  server.listen port

  tests = {}

  tests['posting user'] = (next) ->
    request 'POST', '/user', 
      data:
        type: "user"
        attributes:
          name: name 
    , (json) ->
      next()

  tests['requesting users'] = (next) ->      
    request 'GET', '/user', false, (json) ->
      console.dir json
      if json.data[0].attributes.name != name 
        error "name not found"
      next()

  tests['tests done'] = (next) ->
    console.log "OK"
    process.exit 0

  async.series tests
