
fs = require 'fs'
pathlib = require 'path'
callsite = require 'callsite'

fixUI = require('js-beautify').html

vars = {}

commands =
  callVariable: /<!-- \.(\w+) -->/i,
  includeFile: /<!-- \.include (.+) -->/i,
  notincludeFile: /<!-- \.notinclude (.+) -->/i,
  startOfLoop: /<!-- .loop ([0-9]+):([0-9]+) -->/i,
  endOfLoop: /<!-- .endloop -->/i,
  fetchDeclaredVariableName: /<!-- ~(\w+)/i,
  declareVariableCommand: /<!-- ~(.)+( )(.)+ -->/i

class HTMLSource

  constructor: (@path) ->
    @lines = []
    @loops = []
    @startValueForLoop = 0
    @endValueForLoop = 0
    @isLooping = false

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

  detectNotincludeFile: (line) ->
    line = "" if commands.notincludeFile.test(line)
    line

  detectStartOfLoop: (line) ->
    if commands.startOfLoop.test(line)
      @isLooping = true
      elements = line.match(commands.startOfLoop)
      @startValueForLoop = elements[1]
      @endValueForLoop = elements[2]
      line = ''
    line

  detectEndOfLoop: (line) ->
    return commands.endOfLoop.test(line)

  formatLine: (line) ->
    if @isLooping
      if @detectEndOfLoop line
        @isLooping = false
        for num in [@startValueForLoop .. @endValueForLoop]
          for subline in @loops
            @lines.push subline
        @loops = []
        @startValueForLoop = 0
        @endValueForLoop = 0
      else
        @loops.push line
    else
      line = @detectDeclareVariable line
      line = @detectCallVariable line
      line = @detectIncludeFile line
      line = @detectNotincludeFile line
      line = @detectStartOfLoop line
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
