glob = require 'glob'
path = require 'path'

glob path.resolve(__dirname, '*.coffee'), (err, files) ->
  files.forEach (file) ->
    if not file.match __filename
      require file
