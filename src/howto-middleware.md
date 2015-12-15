## Middleware 

Flowee supports express/loopback/restify compatible middleware, using the familiar `.use()` function:

    flowee.use( yourmiddleware );

    flowee.start(....){}

Basically anything which looks like:

    function (req,res,next){

    }

#### Ratelimiting

try [ratelimit-middleware](https://www.npmjs.com/package/ratelimit-middleware)

