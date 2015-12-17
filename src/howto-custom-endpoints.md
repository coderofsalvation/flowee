## Howto: custom endpoints

This can be done using the app object:


      var app = flowee.init({model: model, store:true })
        
      app.get( '/', function(req,res,next){
        res.json({foo:true});
        // res.json(null, [ new Error("foo happened") ] );
        next()
      })

      flowee.start(...)

Or directly using `definitions` field in the [jsonmodel](https://github.com/coderofsalvation/flowee/blob/master/test/model.js) defines the entities and their relationships:

      }
    },
    paths: {
      '/': {                                                   <-- endpoint path 
        'get': {
          'public':true,
          'description': 'returns hello world', 
          'produces': ['application/json'],
          'responses': {
            '200': {
              'description': 'A list of owners.',              <-- useful for generated
              'schema': {                                      <-- documentation
                'type': 'object',                              <--
                'properties':{
                  'msg': {'type':"string"}
                }
              }
            }
          },
          func: function(req, res, next) {                     <-- endpoint function
            res.write('{"msg":"Hello world"}');
            res.end();
            return next();

