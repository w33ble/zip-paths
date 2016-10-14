glob = require 'glob'
path = require 'path'

testFiles = path.resolve(__dirname, '*.coffee')

glob testFiles, (err, files) ->
  files.forEach (file) ->
    if not file.match __filename
      require file
