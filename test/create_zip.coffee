test = require 'tape'
fs = require 'fs'
path = require 'path'
async = require 'async'
zip = require '../'

zipFile = path.resolve __dirname, 'tmp', 'output.zip'
files = ['00_create.coffee', 'runner.coffee', 'zz_cleanup.coffee']

files = files.map (f) ->
  path.resolve __dirname, f

test 'queues files for compression', (t) ->
  t.plan 4

  zip.setOutput zipFile

  stack = []

  files.forEach (file) ->
    do (file) ->
      stack.push (cb) ->
        zip.add file, (err) ->
          t.error err, 'Files are added to the queue'
          cb()

  async.parallel stack, (err) ->
    t.assert zip.getFiles().length, 3, '3 files queued for compression'
    t.end()

test 'creates zip file', (t) ->
  t.false fs.existsSync(zipFile), 'zip file is not created'

  t.end()