fs = require 'fs'

module.exports = (Grunt) ->

  Grunt.initConfig
    coffee:
      compile:
        files:
          'bin/executable.js': 'bin/executable.coffee',
          'lib/wave.js': 'lib/wave.coffee'

  Grunt.loadNpmTasks('grunt-contrib-coffee');

  Grunt.registerTask 'prepare-executable', () ->
    exeLoc = __dirname + '/bin/executable.js'
    data = fs.readFileSync(exeLoc)
    fd = fs.openSync exeLoc, 'w+'
    buffer = new Buffer '#!/usr/bin/env node\n\n'
    fs.writeSync(fd, buffer, 0, buffer.length)
    fs.writeSync(fd, data, 0, data.length)
    fs.close(fd)

  Grunt.registerTask 'build', ['coffee', 'prepare-executable']
