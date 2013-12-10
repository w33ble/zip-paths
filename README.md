# zip-paths

[ ![Codeship Status for goansible/zip-paths](https://www.codeship.io/projects/2e303f70-3ed9-0131-d011-2edc1cbdfa84/status?branch=master)](https://www.codeship.io/projects/10418)

Node module to zip paths using file globbing.

This is basically a wrapper around [node-archiver](https://github.com/ctalkington/node-archiver) that uses [node-glob](https://github.com/isaacs/node-glob) to queue up files for compression.

The paths that match the globbing pattern are used in the resulting zip file.

## Installation

`npm install zip-paths`

## Usage

````
var zipPaths = require('zip-paths');
zip = new zipPaths('out.zip');

zip.add('js/*.js', function(err) {
  if (err) { /* handle error */ }
  zip.compress(function(err, bytes) {
    console.log("wrote %s bytes", bytes)
  });
});
````

### Initialization

`new zipPaths('path/to/zipfile.zip', [options])`

The first parameter is the desired file path of the resulting archive.

`options` is pased to node-archiver. In the case of `zip`, they get passed directly to node's [zlib](http://nodejs.org/api/zlib.html#zlib_options). Default `level` is 9.

#### Options:

refer to [zlib](http://nodejs.org/api/zlib.html#zlib_options) for zip options. Additional options include:

- `archiveType`: Type of archive to create, `zip` or `tar` - default `zip`

### zip.add(pattern, [options], callback(err){})

Add files to be zipped. Using globbing patters here (such as `path/*.ext`) is valid (see [node-glob](https://github.com/isaacs/node-glob) for more info).

You can optionally pass in an options opbject that will be passed directly to `node-glob`. Passing in `cwd` will adjust the paths in the resulting archive as well.

### zip.getFiles()

Return an array of all files queued for archiving.

### zip.compress(callback(err, bytes){})

Create the archive. Calls node-archive's [finalize](https://github.com/ctalkington/node-archiver#finalizecallbackerr-bytes) method directly and passes the callback along.
