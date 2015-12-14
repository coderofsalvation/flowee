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
  'consumes': [ 'application/vnd.api+json' ]
  'produces': [ 'application/vnd.api+json' ]
  fortunejs:
    serializers: [{ 
      type: 'fortune-json-api'
      options: {}
    }]
    adapter: { 
      type: 'fortune-nedb'
      options:
        dbPath: __dirname+"/db"
    }
  paths:
    '/': 
      'get':
        'description': 'Returns all owners from the system that the user has access to'
        'produces': [ 'application/json' ]
        'responses': '200':
          'description': 'A list of owners.'
          'schema':
            'type': 'array'
            'items': '$ref': '#/definitions/user'
        func: (req,res,next) ->
          res.write('Hello world')
          res.end()
          next()
  definitions: 
    user:
      name:
        type: String
      following:
        link: 'user'
        inverse: 'followers'
        isArray: true
      followers:
        link: 'user'
        inverse: 'following'
        isArray: true
      posts:
        link: 'post'
        inverse: 'author'
        isArray: true
    post: 
      message: 
        type: String
      author:
        link: 'user'
        inverse: 'posts'
