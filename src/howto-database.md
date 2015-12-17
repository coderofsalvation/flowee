## Howto: Database entities & relations

> Powered by __fortunejs__, we don't need to worry about ORM-stuff by simply defining database entities in the [jsonmodel](https://github.com/coderofsalvation/flowee/blob/master/test/model.js).

Flowee runs in memory by default, and automatically detects databases when installed.

## Database structure

The `definitions` field in the [jsonmodel](https://github.com/coderofsalvation/flowee/blob/master/test/model.js) allows you to define entities and their relationships:

    ...

    definitions: {          <-- here the database entities are defined
      user: {               <-- name of the entity, this translates to api endpoint '/user' and '/user:id'
        name: {             <-- attribute 
          type: String      <-- type of the attribute

    ...

It uses the __fortunejs__ `defineType` format: see docs at [fortunejs](http://fortunejs.com/)

Each entity will automatically expose the following REST-endpoints during `flowee.init()` :

* GET /user
* POST /user
* GET /user/:id
* PUT /user:id
* DELETE /user:id
  
Just look at `./model.generated.json` in the `/path`-field after running flowee.
Or do a `GET /model` request.

> Important: make sure to do request with the `Content-Type: application/vnd.api+json` http header.

## Want memory to persist on disk?

    npm install fortune-nedb 
    
## Prefer a noSQL db?

    npm install fortune-mongodb 
    
or 
    npm install fortune-redis 

## Or a spoon of relational db?

    npm install fortune-postgres

## Configuration 

Databases are automatically configured by monkeypatching the generated model with default settings.

> Just look at `./model.generated.json` in the `adapter`-field after running flowee.
> Or do a `GET /model` request.

Copy/paste/modify the `adapter`-settings into your model.
