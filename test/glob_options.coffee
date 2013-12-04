test = require 'tape'
fs = require 'fs'
path = require 'path'
async = require 'async'
zip = require '../'

zipFilePath = path.resolve __dirname, 'tmp', 'output.zip'
files = ['00_create.coffee', 'runner.coffee', 'zz_cleanup.coffee']

test 'queued files use relative paths', (t) ->
  t.plan 4

  zip.setOutput zipFilePath

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
