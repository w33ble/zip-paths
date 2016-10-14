var fs = require('fs');
var glob = require('glob');
var archiver = require('archiver');
var assign = require('lodash.assign');

function createArchiver(type, options) {
  return new archiver(type, options);
}

function reset() {
  this.fileList = [];
  return this.archiver = createArchiver(this.options.archiveType, this.options);
};

function zipPaths(zipPath, options) {
  this.zipPath = zipPath;
  this.fileList = [];
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

  glob(path, globOptions, function(err, files) {
    if (err) return callback(err);

    files.forEach(function(file, i) {
      fs.stat(cwd + "/" + file, function(err, stats) {
        if (err) return callback(err);

        if (stats.isFile()) {
          (function(file) {
            self.fileList.push({
              cwd: cwd,
              name: file,
            });
          })(file);
        }
        if (i === files.length - 1) {
          callback();
        }
      });
    });
  });
};

zipPaths.prototype.compress = function(callback) {
  if (callback == null) callback = function() {};

  var self = this;
  var out = fs.createWriteStream(self.zipPath);
  self.archiver.pipe(out);

  out.once('close', function () {
    out.removeAllListeners();
    var bytes = archive.pointer();
    reset.call(self);
    callback(null, bytes);
  })

  out.once('error', function (err) {
    out.removeAllListeners();
    reset.call(self);
    callback(err);
  })

  var archive = this.fileList.reduce(function (archive, file) {
    return archive.append(fs.createReadStream(file.cwd + "/" + file.name), {
      name: file.name
    })
  }, this.archiver);

  archive.finalize();
};

module.exports = zipPaths;