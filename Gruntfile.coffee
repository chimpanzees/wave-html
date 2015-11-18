###
  Basic Gruntfile for Wave-html
###

fs = require 'fs'

module.exports = (Grunt) ->

  Grunt.initConfig
    coffee:
      compile:
        files:
          'module/bin/executable.js': 'module/src/executable.coffee',
          'module/bin/wave.js': 'module/src/wave.coffee'
    mochaTest:
      test:
        src: ['bin/tests/*.js']

  Grunt.loadNpmTasks('grunt-contrib-coffee')

  Grunt.registerTask 'prepare-executable', () ->
    exeLoc = __dirname + '/module/bin/executable.js'
    data = fs.readFileSync(exeLoc)
    fd = fs.openSync exeLoc, 'w+'
    buffer = new Buffer '#!/usr/bin/env node\n\n'
    fs.writeSync(fd, buffer, 0, buffer.length)
    fs.writeSync(fd, data, 0, data.length)
    fs.close(fd)

  Grunt.registerTask 'compile', ['coffee', 'prepare-executable']
