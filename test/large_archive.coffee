test = require 'tape'
Faker = require 'Faker'
fs = require 'fs-extra'
path = require 'path'
zip = require '../'

tmpPath = path.resolve __dirname, 'tmp'
zipFilePath = path.resolve tmpPath, 'output.zip'
dirs = ['', 'one', 'two/three-ohhhh', 'four/five 67/eight-8']

test 'create files with faker', (t) ->
  # create all the data
  dirs.forEach (dir) ->
    contents = ''
    [1..30].forEach (file) ->
      dirPath = path.resolve tmpPath, dir
      filename = Faker.Internet.userName()
      contents += Faker.Lorem.paragraphs()
      fs.outputFileSync "#{dirPath}/#{filename}", contents

  # check that the dirs exist
  dirs.forEach (dir) ->
    t.true fs.existsSync(path.resolve(tmpPath, dir)), "path '#{dir}' exists"

  t.end()

test 'create zip from fake files', (t) ->
  zip.setOutput zipFilePath

  zip.add tmpPath, (err) ->
    t.error err, 'files queued up for archiving'
    zip.compress (err, bytes) ->
      t.error err, 'archive is created'
      t.true (bytes > 0), 'archive has content'
      t.end()