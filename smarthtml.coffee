
fs = require 'fs'

commands:
  declareVariable: /<!-- #(.)+( )(.)+ -->/i

# Needs REFACTORING
stopWith = (error) ->
  console.log 'Stopped with error: ' + error
  process.exit()

compileFile = (file) -> console.log 'compile: ' + file
compileFolder = (folder) -> console.log 'compile F: ' + folder

path = 'error.error'
process.argv.forEach (val, index, array) -> path = val if index == 2

fs.lstat path, (error, stats) ->
  stopWith error if error
  compileFile path if stats.isFile()
  compileFolder path if stats.isDirectory()
