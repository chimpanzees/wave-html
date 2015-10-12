#!/usr/bin/env node

wave = require './wave'
pathlib = require 'path'

path = undefined
output = undefined

process.argv.forEach (val, index, array) ->
  path = val if index == 2
  output = val if index == 3

path = pathlib.resolve process.cwd(), path
output = pathlib.resolve process.cwd(), output

callback = () -> console.log 'Done.'

wave(path, output, callback)
