var fs = require('fs');
var glob = require('glob');
var async = require('async');
var archiver = require('archiver');
var assign = require('lodash.assign');

function createArchiver(type, options) {
  return new archiver(type, options);
}

function reset() {
  this.fileList = [];
  this.asyncStack = [];
  return this.archiver = createArchiver(this.options.archiveType, this.options);
};

function zipPaths(zipPath, options) {
  this.zipPath = zipPath;
  this.fileList = [];
  this.asyncStack = [];
  this.options = assign({
    level: 9,
    archiveType: 'zip'
  }, options);
  this.archiver = createArchiver(this.options.archiveType, this.options);
}

zipPaths.prototype.getFiles = function() {
  return this.fileList;
};

zipPaths.prototype.add = function(path, globOptions, callback) {
  if (callback == null) callback = function() {};

  if (typeof globOptions === 'function') {
    callback = globOptions;
    globOptions = {};
  }

  var self = this;
  var cwd = globOptions.cwd || '';

  return glob(path, globOptions, function(err, files) {
    if (err) return callback(err);

    return files.forEach(function(file, i) {
      return fs.stat(cwd + "/" + file, function(err, stats) {
        if (err) return callback(err);

        if (stats.isFile()) {
          (function(file) {
            self.fileList.push(file);
            return self.asyncStack.push(function(cb) {
              return self.archiver.append(fs.createReadStream(cwd + "/" + file), {
                name: file
              }, cb);
            });
          })(file);
        }
        if (i === files.length - 1) {
          return callback();
        }
      });
    });
  });
};

zipPaths.prototype.compress = function(callback) {
  if (callback == null) callback = function() {};

  var self = this;
  var out = fs.createWriteStream(this.zipPath);
  this.archiver.pipe(out);

  return async.parallel([
    function(cb) {
      return async.parallel(self.asyncStack, function(err) {
        return self.archiver.finalize(cb);
      });
    },
    function(cb) {
      return out.once('close', function() {
        reset.call(self);
        return cb();
      });
    }
  ], function(err, results) {
    return callback(err, results[0]);
  });
};

module.exports = zipPaths;