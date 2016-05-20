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

  @json2text  = (json,prefix="") -> JSON.stringify(json,null,2).replace(/[{}\]\["']+/g,'').trim().replace(/^/gm,prefix)

  ###
  # setup middleware iterator
  ###

  @use = (cb) -> 
    @middleware.push cb

  @process = (req,res) ->
    i=0
    req.originalUrl = req.url
    req.flowee = @
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
  # setup middleware: fortunejs store (serializers and adapter) 
  ###

  @init_db = (model) ->
    if model.flowee.fortunejs.adapter?
      console.log "db> adapter configuration found in model" if @verbosity > 0
    else
      console.log "db> adapter not configured in model..detecting adapter" if @verbosity > 0
      done = (name,notes) -> 
        console.log "db> "+name+" found, injecting default config to `model.flowee.fortunejs.adapter` :"
        console.log me.json2text( model.flowee.fortunejs.adapter, "db> " ) if me.verbosity > 0
        #console.log "db> NOTE: "+notes if notes?
      try
        require 'fortune-nedb'
        model.flowee.fortunejs.adapter =
          type: "fortune-nedb"
          options:
            dbPath: ( process.env.DATA_DIR || @model.flowee.dataPath+"/db" )
        return done("nedb")
      catch e
        console.log "db> no nedb detected"

      try
        require 'fortune-mongodb'
        model.flowee.fortunejs.adapter =
          type: "fortune-mongodb"
          options:
            url: 'mongodb>//localhost:27017/test'
        return done("mongodb")
      catch
        console.log "db> no mongodb detected"
      
      try
        require 'fortune-postgres'
        model.flowee.fortunejs.adapter =
          type: "fortune-postgres"
          options:
            url: "postgres://test:pass@localhost:3360/testdb"
        return done("postgres")
      catch
        console.log "db> no postgres detected"
      
      try
        require 'fortune-redis'
        model.flowee.fortunejs.adapter =
          type: "fortune-redis"
        return done("redis")
      catch
        console.log "db> no redis detected"

      console.log "db> no database adapter installed, defaulting to memory"


  @init_store = (model) ->
    @init_db model
    serializer.type = require serializer.type for serializer in model.flowee.fortunejs.serializers
    model.flowee.fortunejs.adapter.type = require model.flowee.fortunejs.adapter.type if model.flowee.fortunejs.adapter?
    @store = @fortune model.flowee.fortunejs
    @store.defineType entityname, entity.schema for entityname,entity of model.definitions

    listener = fortune.net.http( @store, { endResponse: false })
    @middleware.push (req, res, next) ->
      console.log "middleware> fortunejs" if me.verbosity > 1
      req.url = req.url.replace(/^\/collections$/,'/')
      return listener(req, res).then (response) ->
        res.write response.payload
        res.end()
        next() // save the response somewhere, then call next
      .catch(next)
    @store
  
  ###
  # setup middleware: http router 
  ###

  @init_router = (model) ->
    @router = http_router.createRouter()
    for resource,methods of model.paths
      @router[method]( resource, obj.func ) for method,obj of methods
    @middleware.push (req,res,next) ->
      console.log "middleware> http-router" if me.verbosity > 1
      next() if not me.router.route(req, res)

  @init = (opts) ->
    if opts.model? 
      @model = opts.model
      @init_router opts.model
      @init_store opts.model if opts.store
    else throw new Error("NO_FLOWEE_MODEL_GIVEN")
    @emit 'init', @
    @router

  @export_swagger = (model) ->
    for entityname,entity of model.definitions
      properties = {}
      for propertyname,property of entity.schema
        p = properties[propertyname] = {}
        p.type = "string" if property.type is String
        if property.isArray? and property.isArray
          p.type = "array" 

      path = {}
      model.paths[ "/"+entityname ] = path
      path.get =
        'description': 'Returns a collection of '+entityname+' objects from the database'
        'produces': [ 'application/vnd.api+json' ]
        'responses': '200':
          'description': 'A collection of '+entityname+' objects'
          'schema':
            'type': 'array'
            items: [ { type: "object", properties:properties } ]
      
      path.post =
        'description': 'Creates a '+entityname+' object'
        'produces': [ 'application/vnd.api+json' ]
        'responses': '200':
          'description': 'A '+entityname+' object'
          'schema': { type: "object", properties:properties }

      
      path = {}
      model.paths[ "/"+entityname+"/:id" ] = path 
      path.get =
        'description': 'Returns a '+entityname+' object from the database'
        'produces': [ 'application/vnd.api+json' ]
        'responses': '200':
          'description': 'A '+entityname+' object'
          'schema': { type: "object", properties:properties }

      path.post =
        'description': 'Updates a '+entityname+' object'
        'produces': [ 'application/vnd.api+json' ]
        'responses': '200':
          'description': 'A '+entityname+' object'
          'schema':
            'type': 'object'
            properties: properties

    if model.flowee.model.write 
      console.log "writing generated model to `"+model.flowee.dataPath+model.flowee.model.file+"`"
      require("fs").writeFileSync model.flowee.dataPath+model.flowee.model.file, JSON.stringify(model,null,2)

  @start = (cb) ->
    me = @
    _start = () ->
      me.export_swagger(me.model)
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
