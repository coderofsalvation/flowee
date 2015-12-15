## Data logic / Permissions / Authentication 

Database access can be supervised by introducing [fortunejs transformers](http://fortunejs.com/api/):

    const errors = fortune.errors

    store.transformOutput(type, (context, record) => {
      if (context.request.meta['Authorization'] !== 'secret')
        throw new errors.UnauthorizedError('Not allowed to view this resource.')

      return record
    })

In a similar way this can be done with custom endpoints by introducing authentication middleware __before__ flowee 
is started.
For example using [rest-auth](https://www.npmjs.com/package/rest-auth):

    var auth = require('rest-auth');
 
    // Tell the auth module how to authenticate a user 
    auth.authenticateUser(function(username, password, callback) {
        /* TODO: use nedb in example, not mongodb */
        User.findOne({ username: username }, function(err, user) {
            if (err) {
                return callback(err);
            }
            if (! user) {
                return callback(null, false, 'User does not exists');
            }
            if (hash(password) !== user.password) {
                return callback(null, false, 'Invalid password');
            }
            // The username and password should be given here 
            callback(null, {
                username: username,
                password: user.password
            });
        });
    });:

    flowee.use(auth.authenticate({
        expires: '2 hours',
        authRoute: 'auth-token',
        authTokenHash: {
            algorithm: 'sha256',
            salt: 'saltiness'
        }
    });
  
    flowee.start(model, function(server, router) {
      ..

