test = require 'tape'
fs = require 'fs'
path = require 'path'
async = require 'async'
zipPaths = require '../'

zipFilePath = path.resolve __dirname, 'tmp', 'output.zip'
files = ['00_create.coffee', 'runner.coffee', 'zz_cleanup.coffee']

zip = new zipPaths zipFilePath

test 'queued files use relative paths', (t) ->
  t.plan 4

  stack = []
  files.forEach (file) ->
    do (file) ->
      stack.push (cb) ->
        zip.add file,
          cwd: __dirname
        , (err) ->
          t.error err, "#{file} added to the queue"
          cb()

  async.parallel stack, (err) ->
    t.equals zip.getFiles().length, 3, '3 files queued for compression'
    t.end()
