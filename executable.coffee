
wave = require './wave'

path = undefined
output = undefined

process.argv.forEach (val, index, array) ->
  path = val if index == 2
  output = val if index == 3
wave(path, output)
