flowee = require './index.coffee'
nedb   = require 'fortune-nedb'
model  = require('./test/model.coffee')

flowee.init_store model # let fortunejs take care of db-stuff
flowee.start model,(server,router) ->
  port = process.env.PORT || 1337
  console.log "starting flowee at port %s",port

  router.get '/foo', (req,res,next) ->
    res.end("Hello foo")

  server.listen port
