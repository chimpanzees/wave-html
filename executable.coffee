#!/usr/bin/env node

fs = require 'fs'
path = require 'path'
wave = require './wave'

Parser = require('argparse').ArgumentParser

path = __dirname + '/package.json'
data = JSON.parse(fs.readFileSync(path, 'utf8'));

parser = new Parser
  version: 'Wave Compiler v' + data['version'],
  addHelp: true,
  description: 'Wave Compiler'

parser.addArgument(
  ['input'],
    help: 'Location of the input file'
)

parser.addArgument(
  ['output'],
    help: 'Location of the output file'
)

args = parser.parseArgs()
input = path.resolve process.cwd(), args.input
output = path.resolve process.cwd(), args.output

callback = () -> console.log 'Done.'

wave(path, output, callback)
