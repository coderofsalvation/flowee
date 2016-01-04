module.exports =
  'swagger': '2.0'
  'info':
    'version': '1.0.0'
    'title': 'Swagger fortunejs Example'
    'description': 'A sample API that uses a petstore as an example to demonstrate features in the swagger-2.0 specification'
    'termsOfService': 'http://swagger.io/terms/'
    'contact': 'name': 'Swagger API Team'
    'license': 'name': 'MIT'
  'host': 'petstore.swagger.io'
  'basePath': '/api'
  'schemes': [ 'http' ]
  'consumes': [ 'application/vnd.api+json', 'application/json' ]
  'produces': [ 'application/vnd.api+json', 'application/json' ]
  flowee:
    model:
      write: true 
      file: "/model.generated.json"
    dataPath: '.'
    fortunejs:
      serializers: [{ 
        type: 'fortune-json-api'
        options: {}
      }]
  paths:
    '/foo': 
      'get':
        public: true
        'description': 'Returns all owners from the system that the user has access to'
        'produces': [ 'application/json' ]
        'responses': '200':
          'description': 'A list of owners.'
          'schema':
            'type': 'array'
            'items': '$ref': '#/definitions/user'
        func: (req,res,next) ->
          res.json {"msg":"Hello world"}
          next()
    '/model':
      'get':
        public: true
        'description': 'Returns flowee (generated) model for backup or documentation purposes'
        'produces': [ 'application/json' ]
        'responses': '200':
          'description': 'The flowee json model'
          'schema':
            'type': 'object'
        func: (req,res,next) ->
          res.end JSON.stringify req.flowee.model,null,2
          next() 
  definitions: 
    user:
      schema:
        name:
          type: String
        username:
          type: String
        password:
          type: String
        apitoken:
          type: String
        following:
          link: 'user'
          inverse: 'followers'
          isArray: true
        followers:
          link: 'user'
          inverse: 'following'
          isArray: true
        roles:
          link: 'role'
          inverse: 'user'
          isArray: true
    role: 
      schema:
        message: 
          type: String
        user:
          link: 'user'
          inverse: 'roles'
