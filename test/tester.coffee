t = {}
t.errors = 0
t.error = (msg) -> 
  t.errors++
  console.error "ERROR: "+msg 
  process.exit(1) if process.env.HALT?
t.tests = []
t.test  = (description,cb) -> t.tests.push {description:description, cb:cb}
t.run = () ->
  i=0 ; 
  next = () -> 
    if t.tests[++i]?
      console.log "\n::: ▶▶▶ running test #"+i+" '"+ t.tests[i].description + "'"
      t.tests[i].cb(next) 
  t.tests[i].cb(next)


module.exports = t
