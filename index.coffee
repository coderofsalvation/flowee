module.exports = ( () =>

  http        = require('http')
  fortune     = require 'fortune'
  jsonapi     = require 'fortune-json-api'
  nedb        = require 'fortune-nedb'
  http_router = require 'http-router'
  verbosity   = 1
  me          = @

  @store      = false
  @router     = false 
  @middleware = []

  ###
  # setup middleware iterator
  ###

  @use = (cb) -> 
    @middleware.push cb

  @process = (req,res) ->
    i=0
    next = () ->
      if me.middleware[++i]?
        me.middleware[i](req,res,next)
      else 
        res.end()
    me.middleware[i](req,res,next)

  ###
  # setup fortunejs store (serializers and adapter)
  ###

  @init_store = (model) ->
    serializer.type = require serializer.type for serializer in model.fortunejs.serializers
    model.fortunejs.adapter.type = require model.fortunejs.adapter.type
    @store = fortune.create model.fortunejs
    @store.defineType entityname, entity for entityname,entity of model.definitions

    listener = fortune.net.http( @store, { endResponse: false })
    @middleware.push (req, res, next) ->
      req.url = req.url.replace(/\/api/,'')
      return listener(req, res).then (response) ->
        res.write response.payload
        res.end()
        next() // save the response somewhere, then call next
      .catch(next)
    @store

  @init_router = (model) ->
    @router = http_router.createRouter()
    for resource,methods of model.paths
      @router[method]( resource, obj.func ) for method,obj of methods
    @middleware.push (req,res,next) ->
      next() if not me.router.route(req, res)

  @start = (model,cb) ->
    me = @
    @init_router model
    store = @init_store(model)
    store.connect().then () ->
      server = http.createServer (req,res) -> me.process.apply({},arguments)
      cb(server,me.router)
  
  @[func] = @[func].bind(@) for func,v of @ when typeof v is 'function'

  @

).apply({})

