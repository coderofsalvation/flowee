t = {}
t.errors = 0
t.error = (msg) -> 
  t.errors++
  console.error "ERROR: "+msg 
  process.exit(1) if process.env.HALT?
t.tests = []
t.test  = (description,cb) -> t.tests.push {description:description, cb:cb}
t.run = () ->
  t.done()
  i=0 ; 
  next = () -> 
    if t.tests[++i]?
      console.log "\n>>> RUNNING TEST #"+i+" '"+ t.tests[i].description + "'"
      t.tests[i].cb(next) 
  t.tests[i].cb(next)

t.done = () ->
  t.test 'tests done', (next) ->
    if not t.errors
      console.log "\nOK\n"
      process.exit 0 
    else
      console.log "\nERROR: some tests failed\n"
      process.exit 1

module.exports = t
