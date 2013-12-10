test = require 'tape'
Faker = require 'Faker'
fs = require 'fs-extra'
path = require 'path'
zipPaths = require '../'

tmpPath = path.resolve __dirname, 'tmp'
zipFilePath = path.resolve tmpPath, 'large_output.zip'
dirs = ['', 'one', 'two/three-ohhhh', 'four/five 67/eight-8']

zip = new zipPaths zipFilePath

test 'create files with faker', (t) ->
  # create all the data
  dirs.forEach (dir) ->
    contents = ''
    [1..30].forEach (file, i) ->
      dirPath = path.resolve tmpPath, dir
      filename = Faker.Internet.userName()
      contents += Faker.Lorem.paragraphs()
      fs.outputFileSync "#{dirPath}/#{i}-#{filename}", contents

  # check that the dirs exist
  dirs.forEach (dir) ->
    t.true fs.existsSync(path.resolve(tmpPath, dir)), "path '#{dir}' exists"

  t.end()

test 'create zip from fake files', (t) ->
  zip.add "**",
    cwd: tmpPath
  , (err) ->
    t.error err, 'files queued up for archiving'
    filelist = zip.getFiles()
    t.true (filelist.length >= 100), 'archive has more than 100 files'
    zip.compress (err, bytes) ->
      t.error err, 'archive is created'
      t.true (bytes > 200), 'archive is larger than 200 bytes'
      t.end()
