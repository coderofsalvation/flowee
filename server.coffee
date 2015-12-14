flowee = require './index.coffee'
model  = require './test/model.coffee'

flowee.start model,(server,router) ->
  port = process.env.PORT || 1337
  console.log "starting flowee at port %s",port

  router.get '/foo', (req,res,next) ->
    res.end("Hello foo")

  server.listen port
