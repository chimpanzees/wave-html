fs = require 'fs'

module.exports = (Grunt) ->

  Grunt.registerTask 'prepare-executable', () ->
    exeLoc = __dirname + '/bin/executable.js'
    data = fs.readFileSync(exeLoc)
    fd = fs.openSync exeLoc, 'w+'
    buffer = new Buffer '#!/usr/bin/env node\n\n'
    fs.writeSync(fd, buffer, 0, buffer.length)
    fs.writeSync(fd, data, 0, data.length)
    fs.close(fd)
