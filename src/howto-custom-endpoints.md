## Howto: custom endpoints

This can be done using the router object :


    flowee.start(model, function(server, router) {

      router.get('/foo', function(req, res, next) {          // <--
        return res.end('{"msg":"Hello foo"}');               // <--
      });                                                    // <--

      server.listen(port);

Or directly using `definitions` field in the __SWAGGER__ jsonmodel defines the entities and their relationships:

      }
    },
    paths: {
      '/': {                                                   <-- endpoint path 
        'get': {
          'description': 'returns hellow world'               
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

