## Howto: Database entities & relations

The `definitions` field in the __SWAGGER__ jsonmodel defines the entities and their relationships:

      }
    },
    definitions: {          <-- here the database entities are defined
      user: {               <-- name of the entity, this translates to api endpoint '/user' and '/user:id'
        name: {             <-- attribute 
          type: String      <-- type of the attribute
    ...

It uses the __fortunejs__ `defineType` format: see docs at [fortunejs](http://fortunejs.com/)

