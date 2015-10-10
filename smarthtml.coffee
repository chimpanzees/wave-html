
fs = require 'fs'

vars = {}
output = []

commands =
  variableName: /#(\w+)/i,
  declareVariable: /<!-- #(.)+( )(.)+ -->/i

# Needs REFACTORING
stopWith = (error) ->
  console.log 'Stopped with error: ' + error
  process.exit()

detectDeclareVariable = (line) ->
  if commands.declareVariable.test(line)
    rows = line.match(commands.declareVariable)[0]
    name = rows.match(commands.variableName)[1]
    data = rows.substring(6 + name.length, rows.length - 3).trim()
    vars[name] = data

formatLine = (line) ->
  detectDeclareVariable line

compileFile = (file) ->
  fs.readFile file, 'utf-8', (error, data) ->
    for line in data.split(/\r?\n/i)
      formatLine line
    console.log vars
    
compileFolder = (folder) -> console.log 'compile F: ' + folder

path = 'error.error'
process.argv.forEach (val, index, array) -> path = val if index == 2

fs.lstat path, (error, stats) ->
  stopWith error if error
  compileFile path if stats.isFile()
  compileFolder path if stats.isDirectory()
