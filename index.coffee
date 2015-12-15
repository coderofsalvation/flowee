module.exports = ( () =>

  http        = require('http')
  fortune     = require 'fortune'
  jsonapi     = require 'fortune-json-api'
  http_router = require 'http-router'
  verbosity   = 1
  me          = @
  @response    = { "jsonapi": { "version": "1.0" }, errors:[] }

  @model      = false
  @store      = false
  @router     = false 
  @middleware = []

  @clone      = (o) -> JSON.parse JSON.stringify o

  ###
  # setup middleware iterator
  ###

  @use = (cb) -> 
    @middleware.push cb

  @process = (req,res) ->
    i=0
    next = (err) ->
      if me.middleware[++i]? and not err?
        me.middleware[i](req,res,next)
      else 
        if err
          obj = me.clone me.response 
          obj.errors.push 
            "title":err.toString()
            "code": (if err.status? then err.status else 1) 
          res.end JSON.stringify(obj)
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
      req.url = req.url.replace(/^\/collections$/,'/')
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

  @init = (opts) ->
    if opts.model? 
      @model = opts.model
      @init_router opts.model
      @init_store opts.model if opts.store
    else throw new Error("NO_FLOWEE_MODEL_GIVEN")


  @start = (cb) ->
    me = @
    _start = () ->
      server = http.createServer (req,res) -> me.process.apply({},arguments)
      cb(server,me.router)
    if me.store
      me.store.connect().then _start
    else 
      _start()
  
  @[func] = @[func].bind(@) for func,v of @ when typeof v is 'function'

  @

).apply({})

