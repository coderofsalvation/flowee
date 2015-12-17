flowee   = require './../../index.coffee'
model    = require('./../model.coffee')
passport = require 'passport' 
TokenStrategy = require('passport-accesstoken').Strategy

public_urls = ["/foo","/"]

getuser = (opts) ->
  if not opts? or (opts.username? and opts.username is "anonymous")
    return {id:-1, username:"anonymous",roles:["can_edit_bar"]}
  else
    return {id:1, username:"foo",roles:["can_edit_bar"]}

passport.use new TokenStrategy
  tokenHeader: 'x-custom-token'
  tokenField:  'custom-token'
, ( token, done ) ->
  done null, getuser({id:1})

passport.serializeUser (user, done) ->
  console.log "serialize user"
  done null, user.id
  return

passport.deserializeUser (id, done) ->
  console.log "trying to get userid "+id
  done null, getuser({id:id})

flowee.use require('cookie-parser')({secret:"something secret", cookie:{secure:false} })
flowee.use require('session-middleware').middleware( "encryptionKey", "cookieName" )
flowee.use passport.initialize() 
flowee.use passport.session() 
flowee.use (req,res,next) -> 
  # bypass token authentication for public urls 
  if req.url in public_urls
    req.user = getuser()
    next() 
  else (passport.authenticate 'token')(req,res,next) 

flowee.init {model: model, store:true }
flowee.start (server,app) ->
  port = process.env.PORT || 1337
  console.log "starting flowee at port %s",port

  app.get '/', (req,res,next) ->
    res.json {foo:true}
  
  app.post '/secure', (req, res, next) ->
    res.json {title:"congrats! logged in!",code:0, user:req.user}

  server.listen port
