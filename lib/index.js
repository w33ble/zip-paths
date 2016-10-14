var fs = require('fs');
var glob = require('glob');
var async = require('async');
var archiver = require('archiver');
var assign = require('lodash.assign');

function reset() {
  this.fileList = [];
  this.asyncStack = [];
  return this.archiver = new archiver(this.options.archiveType, this.options);
};

function zipPaths(zipPath, options) {
  this.zipPath = zipPath;
  this.fileList = [];
  this.asyncStack = [];
  this.options = assign({
    level: 9,
    archiveType: 'zip'
  }, options);
  this.archiver = new archiver(this.options.archiveType, this.options);
}

zipPaths.prototype.getFiles = function() {
  return this.fileList;
};

zipPaths.prototype.add = function(path, globOptions, callback) {
  var cwd;
  if (callback == null) {
    callback = function() {};
  }
  if (typeof globOptions === 'function') {
    callback = globOptions;
    globOptions = {};
  }
  cwd = globOptions.cwd || '';
  return glob(path, globOptions, (function(_this) {
    return function(err, files) {
      if (err) {
        return callback(err);
      }
      return files.forEach(function(file, i) {
        return fs.stat(cwd + "/" + file, function(err, stats) {
          if (err) {
            return callback(err);
          }
          if (stats.isFile()) {
            (function(file) {
              _this.fileList.push(file);
              return _this.asyncStack.push(function(cb) {
                return _this.archiver.append(fs.createReadStream(cwd + "/" + file), {
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
    };
  })(this));
};

zipPaths.prototype.compress = function(callback) {
  var out;
  if (callback == null) {
    callback = function() {};
  }
  out = fs.createWriteStream(this.zipPath);
  this.archiver.pipe(out);
  return async.parallel([
    (function(_this) {
      return function(cb) {
        return async.parallel(_this.asyncStack, function(err) {
          return _this.archiver.finalize(cb);
        });
      };
    })(this), (function(_this) {
      return function(cb) {
        return out.once('close', function() {
          reset.call(_this);
          return cb();
        });
      };
    })(this)
  ], function(err, results) {
    return callback(err, results[0]);
  });
};


module.exports = zipPaths;