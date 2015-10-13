fs = require 'fs'

module.exports = (Grunt) ->

  Grunt.initConfig
    coffee:
      compile:
        files:
          'bin/executable.js': 'bin/executable.coffee',
          'test/WaveTests.js': 'test/WaveTests.coffee',
          'lib/wave.js': 'lib/wave.coffee'
    mochaTest:
      test:
        src: ['test/*.js']

  Grunt.loadNpmTasks('grunt-mocha-test')
  Grunt.loadNpmTasks('grunt-contrib-coffee')

  Grunt.registerTask 'prepare-executable', () ->
    exeLoc = __dirname + '/bin/executable.js'
    data = fs.readFileSync(exeLoc)
    fd = fs.openSync exeLoc, 'w+'
    buffer = new Buffer '#!/usr/bin/env node\n\n'
    fs.writeSync(fd, buffer, 0, buffer.length)
    fs.writeSync(fd, data, 0, data.length)
    fs.close(fd)

  Grunt.registerTask 'test', 'mochaTest'
  Grunt.registerTask 'compile', ['coffee', 'prepare-executable']

  Grunt.registerTask 'build', ['compile', 'test']
