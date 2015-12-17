fetch        = require 'node-fetch'

module.exports = (method,resource,data,cb) ->
  console.log method+" "+resource+" "+JSON.stringify( data,null,2 ) if process.env.DEBUG
  options = 
    method: method 
    headers:
      "Content-Type": "application/vnd.api+json"
      "Accept": "application/vnd.api+json"
      "x-custom-token": process.env.APITOKEN || "123345"
  options.body = JSON.stringify data if data
  fetch 'http://localhost:1337'+resource, options
  .then (res,err) -> 
    console.log "responsetime: "+res.headers.get 'x-response-time' if res.headers.get 'x-response-time'
    console.dir err if err
    res.json()
  .then (json,err) ->
    console.log JSON.stringify( json,null,2 ) if process.env.DEBUG
    cb(json)
