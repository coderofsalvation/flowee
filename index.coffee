fortune = require('fortune')
http         = require('http')
http_router  = require 'http-router'
EventEmitter = require('events')

module.exports = ( () ->

  verbosity   = 1
  me          = @
  @verbosity  = parseInt process.env.DEBUG || 1 
  @fortune    = require('fortune')

  @jsonapi     = require 'fortune-json-api'
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
    req.originalUrl = req.url
    res[k] = helper.bind(res) for k,helper of me.helpers.res
    next = (err) ->
      if me.middleware[++i]? and not err?
        me.middleware[i](req,res,next)
      else 
        if err
          res.json null, [ err ]
        else
          res.end()
    me.middleware[i](req,res,next)

  @helpers = 
    res:
      json: (data,errors) ->
        errors = errors || []
        obj = me.clone me.response 
        obj.data = data if data? and data
        for error in errors 
          obj.errors.push 
            "title":error.toString()
            "detail": ( if error.stack? and process.env.DEBUG then error.stack else ":[" )
            "code": (if error.status? then error.status else 1)
        @.end JSON.stringify(obj)
      redirect: (url) ->
        @writeHead 302,
          'Location': url
        @end()

  ###
  # setup fortunejs store (serializers and adapter)
  ###

  @init_store = (model) ->
    serializer.type = require serializer.type for serializer in model.fortunejs.serializers
    model.fortunejs.adapter.type = require model.fortunejs.adapter.type
    @store = @fortune model.fortunejs
    @store.defineType entityname, entity.schema for entityname,entity of model.definitions

    listener = fortune.net.http( @store, { endResponse: false })
    @middleware.push (req, res, next) ->
      console.log "middleware:fortunejs" if me.verbosity > 1
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
      console.log "middleware:http-router" if me.verbosity > 1
      next() if not me.router.route(req, res)

  @init = (opts) ->
    if opts.model? 
      @model = opts.model
      @init_router opts.model
      @init_store opts.model if opts.store
    else throw new Error("NO_FLOWEE_MODEL_GIVEN")
    @emit 'init', @
    @router


  @start = (cb) ->
    me = @
    _start = () ->
      server = http.createServer (req,res) -> me.process.apply({},arguments)
      cb(server)
      me.emit 'start', me
    if me.store
      me.store.connect().then _start
    else 
      _start()
  
  @[func] = @[func].bind(@) for func,v of @ when typeof v is 'function'

  @request = (method, opts) ->
    throw "NO_OPTS_GIVEN" if not opts?
    opts.method = fortune.methods[ method ]
    @store.request opts

  @

).apply( Object.create(EventEmitter.prototype) )
