test = require 'tape'
fs = require 'fs-extra'
path = require 'path'

tmpPath = path.resolve __dirname, 'tmp'

test 'create tmp dir', (t) ->
  fs.mkdirs tmpPath, (err, dir) ->
    t.error err, 'create tmp'
    fs.stat tmpPath, (err, stat) ->
      t.error err, 'read tmp'
      t.true stat.isDirectory(), 'tmp is directory'
      t.end()