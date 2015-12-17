request      = require './util/requester.coffee'
t            = require './util/tester.coffee'
  
flowee   = require './../index.coffee'
require('flowee-auth')(flowee)
model    = require('./model.coffee')

t.test 'starting server', (next) ->

  flowee.init {model: model, store:true }
  flowee.start (server,app) ->
    port = process.env.PORT || 1337
    console.log "starting flowee at port %s",port
    
    # lets make some urls public
    flowee.auth.ignore "/"
    flowee.auth.ignore "/foo"

    app.get '/', (req,res,next) ->
      res.json {foo:true}
    
    app.post '/secure', (req, res, next) ->
      res.json {title:"congrats! logged in!",code:0, user:req.user} # userfield for debugging reasons only :)

    server.listen port
    next()

t.test 'adding user', (next) ->
  flowee.request "create", 
    type:'user'
    payload:
      name: "John Doe"
      username: "john"
      password: "doe"
      apitoken: (process.env.APITOKEN = "jdjd")
  .then () ->
    next()

t.test 'posting to /secure', (next) ->
  request 'POST', "/secure", {}, () ->
    next()

t.test 'getting /foo to check session', (next) ->
  request 'GET', "/foo", {}, () ->
    next()
t.run()
