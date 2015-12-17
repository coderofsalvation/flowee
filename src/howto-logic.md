## Data logic 

Database access can be supervised by introducing [fortunejs transformers](http://fortunejs.com/api/):

    const errors = fortune.errors

    store.transformOutput(type, (context, record) => {
      if (context.request.meta['Authorization'] !== 'secret')
        throw new errors.UnauthorizedError('Not allowed to view this resource.')

      return record
    })

Another way is using man-in-the-middleware (see [middleware](howto-middleware.html) for request handling.
