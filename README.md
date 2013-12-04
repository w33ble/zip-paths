# zip-paths

[ ![Codeship Status for goansible/zip-paths](https://www.codeship.io/projects/2e303f70-3ed9-0131-d011-2edc1cbdfa84/status?branch=master)](https://www.codeship.io/projects/10418)

Node module to zip paths using file globbing.

This is basically a wrapper around [node-archiver](https://github.com/ctalkington/node-archiver) that uses [node-glob](https://github.com/isaacs/node-glob) to queue up files for compression.

The paths that match the globbing pattern are used in the resulting zip file.

## Installation

`npm install zip-paths`

## Usage

````
var zip = require('zip-paths');
zip.setOutput('out.zip');

zip.add('js/*.js', function(err) {
  if (err) { /* handle error */ }
  zip.compress(function(err, bytes) {
    console.log("wrote %s bytes", bytes)
  });
});
````

### zip.setType([type])

Set the type of the compression, `zip` or `tar`

### zip.setOptions([options])

Options to pass to node-archiver. In the case of `zip`, they get passed directly to node's [zlib](http://nodejs.org/api/zlib.html#zlib_options)

### zip.setOutput(path)

Set the resulting archive's path

### zip.add(pattern, callback(err){})

Add files to be zipped. Using globbing patters here (such as `path/*.ext`) is valid (see [node-glob](https://github.com/isaacs/node-glob) for more info).

### zip.compress(callback(err, bytes){})

Create the archive. Calls node-archive's [finalize](https://github.com/ctalkington/node-archiver#finalizecallbackerr-bytes) method directly and passes the callback along.