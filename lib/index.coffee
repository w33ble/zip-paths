glob = require 'glob'
async = require 'async'
archiver = require 'archiver'
extend = require 'lodash.assign'
fs = require 'fs'

module.exports = do ->
  options     = level: 9
  initialized = false
  type        = 'zip'
  zip         = undefined
  zipPath     = undefined
  fileList    = []
  fileStack   = []
  initialize = ->
    zip = archiver type, options
    initialized = true

  return {
    reset: ->
      zip = archiver type, options
      fileList = []
      fileStack = []

    setOptions: (opt) ->
      extend(options, opt)

    setType: (type='zip') ->
      type = type

    setOutput: (path) ->
      zipPath = path

    add: (path, options={}, callback=->) ->
      if not initialized
        initialize()

      if typeof options is 'function'
        callback = options
        options = {}

      cwd = options.cwd || ''

      glob path, options, (err, files) ->
        callback err if err
        files.forEach (file, i) ->
          fs.stat "#{cwd}/#{file}", (err, stats) ->
            if stats.isFile()
              do (file) ->
                fileList.push file
                fileStack.push (cb) ->
                  zip.append(fs.createReadStream("#{cwd}/#{file}"), name: file, cb)

            if i is files.length-1
              callback()

    getFiles: ->
      return fileList

    compress: (callback=->) ->
      if not initialized
        initialize()

      out = fs.createWriteStream zipPath
      out.on 'close', reset

      zip.pipe out

      async.parallel fileStack, (err) ->
        zip.finalize callback
  }