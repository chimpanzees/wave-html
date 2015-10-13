#!/usr/bin/env node

(function() {
  var Parser, args, callback, data, fs, input, location, output, parser, path, wave;

  fs = require('fs');

  path = require('path');

  wave = require(__dirname + '/wave');

  Parser = require('argparse').ArgumentParser;

  location = __dirname + '/../package.json';

  data = JSON.parse(fs.readFileSync(location, 'utf8'));

  parser = new Parser({
    version: 'Wave Compiler v' + data['version'],
    addHelp: true,
    description: 'Wave Compiler'
  });

  parser.addArgument(['input'], {
    help: 'Location of the input file'
  });

  parser.addArgument(['output'], {
    help: 'Location of the output file'
  });

  args = parser.parseArgs();

  input = path.resolve(process.cwd(), args.input);

  output = path.resolve(process.cwd(), args.output);

  callback = function() {
    return console.log('Done.');
  };

  wave(input, output, callback);

}).call(this);
