test = require 'tape'
fs = require 'fs-extra'
path = require 'path'

tmpPath = path.resolve __dirname, 'tmp'

test 'remove tmp path', (t) ->
  fs.remove tmpPath, (err) ->
    t.error err, 'tmp dir is removed'
    t.end()
