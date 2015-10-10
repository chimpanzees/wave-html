
fs = require 'fs'
pathlib = require 'path'

fixUI = require('js-beautify').html

vars = {}

commands =
  callVariable: /<!-- \.(\w+) -->/i,
  includeFile: /<!-- \.include (.+) -->/i,
  fetchDeclaredVariableName: /<!-- ~(\w+)/i,
  declareVariableCommand: /<!-- ~(.)+( )(.)+ -->/i

class HTMLSource

  constructor: (@path) -> @lines = []

  detectDeclareVariable: (line) ->
    if commands.declareVariableCommand.test(line)
      cmnd = line.match(commands.declareVariableCommand)[0]
      name = cmnd.match(commands.fetchDeclaredVariableName)[1]
      data = cmnd.substring(6 + name.length, cmnd.length - 3).trim()
      vars[name] = data
      line = line.replace(commands.declareVariableCommand, '')
    line

  detectCallVariable: (line) ->
    if commands.callVariable.test(line)
      name = line.match(commands.callVariable)[1]
      line = line.replace(commands.callVariable, vars[name])
    line

  detectIncludeFile: (line) ->
    if commands.includeFile.test(line)
      source = line.match(commands.includeFile)[1]
      component = new HTMLSource pathlib.dirname(@path) + '/' + source
      component.parse()
      @lines.push line for line in component.lines
    line

  formatLine: (line) ->
    line = @detectDeclareVariable line
    line = @detectCallVariable line
    line = @detectIncludeFile line
    @lines.push line

  parse: () ->
    data = fs.readFileSync @path, 'utf-8'
    @formatLine line for line in data.split(/\r?\n/i)

stopWith = (error) ->
  console.log 'Stopped with error: ' + error
  process.exit()

saveOutput = (output) ->
  buffer = ''
  output.forEach (str) -> buffer += str + '\n' if str != ''
  buffer = fixUI(buffer, { indent_size: 2 })
  outputFile = fs.createWriteStream outputPath
  outputFile.write buffer
  outputFile.end()

compileFile = (file) ->
  html = new HTMLSource file
  html.parse()
  saveOutput html.lines

path = 'error.error'
outputPath = 'output.html'

wave = (input, output = 'output.html') ->
  path = process.cwd() + '/' + input
  outputPath = process.cwd() + '/' + output
  fs.lstat path, (error, stats) ->
    stopWith error if error
    compileFile path if stats.isFile()

module.exports = wave
