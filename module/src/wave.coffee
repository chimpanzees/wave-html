###
  File that compiles the wave html source code to
  an html file, with all code correctly replaced.
###

# Require libraries
fs = require 'fs'
pathlib = require 'path'
beautify = require('js-beautify').html

# Store variables from source file
vars = {}

# Store expressions to recognize Wave syntax
commands = {
  callVariable: /<!-- \.(\w+) -->/i
  includeFile: /<!-- \.include (.+) -->/i
  notincludeFile: /<!-- \.notinclude (.+) -->/i
  startOfLoop: /<!-- .loop ([0-9]+):([0-9]+) -->/i
  endOfLoop: /<!-- .endloop -->/i
  fetchDeclaredVariableName: /<!-- ~(\w+)/i
  declareVariableCommand: /<!-- ~(.)+( )(.)+ -->/i
}

# Class that represents HTMLSource, that can
# be called recursively (for includes)
class HTMLSource

  # Create new HTMLSource with path (of file)
  constructor: (@path) ->
    [@lines, @loops, @startValueForLoop, @endValueForLoop] = [[], [], 0, 0]
    @isLooping = false

  # Detect a variable declaration, if it is
  # a declaration, store the value in var dict
  detectDeclareVariable: (line) ->
    if commands.declareVariableCommand.test(line)
      cmnd = line.match(commands.declareVariableCommand)[0]
      name = cmnd.match(commands.fetchDeclaredVariableName)[1]
      data = cmnd.substring(6 + name.length, cmnd.length - 3).trim()
      vars[name] = data
      line = line.replace(commands.declareVariableCommand, '')
    return line

  # Detect a called variable and replace it with the
  # value with the value in the vars dict
  detectCallVariable: (line) ->
    if commands.callVariable.test(line)
      name = line.match(commands.callVariable)[1]
      line = line.replace(commands.callVariable, vars[name])
    return line

  # Detect include of file, if so, replace with the content
  # of the file on the given location
  detectIncludeFile: (line) ->
    if commands.includeFile.test(line)
      source = line.match(commands.includeFile)[1]
      component = new HTMLSource pathlib.dirname(@path) + '/' + source
      component.parse()
      @lines.push line for line in component.lines
    return line

  # Detect notinclude to remove it form the source
  detectNotincludeFile: (line) ->
    return line = "" if commands.notincludeFile.test(line)
    return line

  # Detect the start of loop, enable loop mode with
  # the configuration loop variables
  detectStartOfLoop: (line) ->
    if commands.startOfLoop.test(line)
      @isLooping = true
      elements = line.match(commands.startOfLoop)
      @startValueForLoop = elements[1]
      @endValueForLoop = elements[2]
      line = ''
    return line

  # Detect end of loop
  detectEndOfLoop: (line) ->
    return commands.endOfLoop.test(line)

  # Format given line with all checkers
  # written above
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

  # Parse the complete html file on given path
  parse: () ->
    data = fs.readFileSync @path, 'utf-8'
    @formatLine line for line in data.split(/\r?\n/i)

# Stops process with error
stopWith = (error) ->
  console.log 'Stopped with error: ' + error
  process.exit()

# Save output buffer to the output file
saveOutput = (output) ->
  buffer = ''
  output.forEach (str) -> buffer += str + '\n' if str != ''
  buffer = fixUI(buffer, { indent_size: 2, end_with_newline: true })
  fs.writeFile outputPath, buffer, () -> mainCallback() if mainCallback?

# Compile file and write output
compileFile = (file) ->
  html = new HTMLSource file
  html.parse()
  saveOutput html.lines

path = 'error.error'
outputPath = 'output.html'
mainCallback = null

# Convert to absolute path
completePathFrom = (path) ->
  return path if pathlib.isAbsolute path
  pathlib.resolve(process.cwd(), path)

# Main compilation function
wave = (input, output = 'output.html', callback = null) ->
  path = completePathFrom input
  outputPath = completePathFrom output
  mainCallback = callback
  fs.lstat path, (error, stats) ->
    stopWith error if error
    compileFile path if stats.isFile()

module.exports = wave
