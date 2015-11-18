
fs = require 'fs'
pathlib = require 'path'
callsite = require 'callsite'

log4js = require 'log4js'
logger = log4js.getLogger()

fixUI = require('js-beautify').html

HTMLSource = require('./HTMLSource')

vars = {}

commands =
  callVariable: /<!-- \.(\w+) -->/i,
  includeFile: /<!-- \.include (.+) -->/i,
  notincludeFile: /<!-- \.notinclude (.+) -->/i,
  startOfLoop: /<!-- .loop ([0-9]+):([0-9]+) -->/i,
  endOfLoop: /<!-- .endloop -->/i,
  fetchDeclaredVariableName: /<!-- ~(\w+)/i,
  declareVariableCommand: /<!-- ~(.)+( )(.)+ -->/i

stopWith = (error) ->
  console.log 'Stopped with error: ' + error
  process.exit()

saveOutput = (output) ->
  buffer = ''
  output.forEach (str) -> buffer += str + '\n' if str != ''
  buffer = fixUI(buffer, { indent_size: 2, end_with_newline: true })
  fs.writeFile outputPath, buffer, () -> mainCallback() if mainCallback?

compileFile = (file) ->
  html = new HTMLSource file
  html.parse()
  saveOutput html.lines

path = 'error.error'
outputPath = 'output.html'
mainCallback = null

completePathFrom = (path) ->
  return path if pathlib.isAbsolute path
  caller = callsite()[2].getFileName()
  dir = pathlib.dirname(caller)
  pathlib.resolve dir, path

getFileExtension = (path) ->
  index = path.lastIndexOf('.')
  extension = path.substr(index).replace('.', '')

wave = (input, output = 'output.html', callback = null) ->
  extension = getFileExtension(input)
  if extension == "whtml"
    path = completePathFrom input
    outputPath = completePathFrom output
    mainCallback = callback
    fs.lstat path, (error, stats) ->
      stopWith error if error
      compileFile path if stats.isFile()
  else
    stopWith("The extension '." + extension + "' of the input file is not valid.")

module.exports = wave
