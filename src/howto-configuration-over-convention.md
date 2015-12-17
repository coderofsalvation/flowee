## Howto: Configuration over Convention 

__Flowee__ is based on x principles:

## configure and monkeypatch

To put it bluntly, there are 3 types of frameworks :

.1 framework which use conventions on how to write classes. functions and filenames.
.1 frameworks which come with massive configurationfiles (modeldriven).
.1 frameworks which do both

__Flowee__ reads its configuration from a popular jsonformat called __SWAGGER__ (the jsonmodel).
This json model is being monkeypatched / decorated with flowee-specific data.

## Where's the monkeypatched result

When __flowee__ starts, it reads your model, which gets monkeypatched during `init()`.
After that __flowee__ :

* exposes a REST-call `GET /model` which serves the generated model
* writes the generated model to `./model.generated.json`

You can inspect that, and copy/paste/modify generated settings into your own model.

## Extensions 

Extensions don't assume you know how to configure them, so they'll automatically monkeypatch your model.
For example [flowee-auth](https://npmjs.org/flowee-auth) will monkeypatch your model with default passport-configurations.
