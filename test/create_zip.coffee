test = require 'tape'
fs = require 'fs'
path = require 'path'
async = require 'async'
zip = require '../'
exec = require('child_process').exec

zipFilePath = path.resolve __dirname, 'tmp', 'output.zip'
files = ['00_create.coffee', 'runner.coffee', 'zz_cleanup.coffee']

files = files.map (f) ->
  path.resolve __dirname, f

test 'queues files for compression', (t) ->
  t.plan 4

  zip.setOutput zipFilePath

  stack = []
  files.forEach (file) ->
    do (file) ->
      stack.push (cb) ->
        zip.add file, (err) ->
          t.error err, "#{file} added to the queue"
          cb()

  async.parallel stack, (err) ->
    t.assert zip.getFiles().length, 3, '3 files queued for compression'
    t.end()

test 'creates zip file', (t) ->
  t.false fs.existsSync(zipFilePath), 'zip file is not created'

  zip.compress (err, bytes) ->
    t.error err, 'zip is created'
    t.true fs.existsSync(zipFilePath), 'zip file is created'
    t.true (bytes > 0), 'file has contents'
    t.end()

test 'zip file is valid', (t) ->
  exec 'which unzip', (err, stdout, stderr) ->
    if not err
      t.pass 'unzip command exists'

      exec "unzip -l #{zipFilePath}", (err, stdout, stderr) ->
        t.true stdout.match('3 files'), 'zip contains 3 files'
        files.forEach (file) ->
          [i..., filename] = file.split path.sep
          t.true stdout.match(filename), "zip contains #{filename}"
        t.end()