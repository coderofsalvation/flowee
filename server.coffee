flowee = require './index.coffee'
nedb      = require 'fortune-nedb'
ratelimit = require('ratelimit-middleware');

flowee.use ratelimit
    burst: 10  # Max 10 concurrent requests (if tokens) 
    rate: 0.5  # Steady state: 1 request / 2 seconds 
    ip: true,  # throttle per IP
    #overrides: 
    #  '192.168.1.1':
    #    burst: 0
    #    rate: 0   # unlimite

flowee.init {model: require('./test/model.coffee'), store:true }
flowee.start (server,router) ->
  port = process.env.PORT || 1337
  console.log "starting flowee at port %s",port

  router.get '/foo', (req,res,next) ->
    res.end("Hello foo")

  server.listen port
