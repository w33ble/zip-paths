glob = require 'glob'
async = require 'async'
archiver = require 'archiver'
assign = require 'lodash.assign'
fs = require 'fs'

class zipPaths
  constructor: (@zipPath, options) ->
    @fileList = []
    @asyncStack = []
    @options = assign {
      level: 9
      archiveType: 'zip'
    }, options

    @archiver = new archiver @options.archiveType, @options

  getFiles: ->
    return @fileList

  reset: ->
    @fileList = []
    @asyncStack = []
    @archiver = new archiver @options.archiveType, @options

  add: (path, globOptions, callback=->) ->
    if typeof globOptions is 'function'
      callback = globOptions
      globOptions = {}

    cwd = globOptions.cwd || ''

    glob path, globOptions, (err, files) =>
      return callback err if err
      files.forEach (file, i) =>
        fs.stat "#{cwd}/#{file}", (err, stats) =>
          if stats.isFile()
            do (file) =>
              @fileList.push file
              @asyncStack.push (cb) =>
                @archiver.append(fs.createReadStream("#{cwd}/#{file}"), name: file, cb)

          if i is files.length-1
            callback()

  compress: (callback=->) ->
    out = fs.createWriteStream @zipPath
    out.on 'close', =>
      @reset

    @archiver.pipe out

    async.parallel @asyncStack, (err) =>
      @archiver.finalize callback


module.exports = zipPaths
