#!/usr/bin/env node


/*
  Command line tool for wave compiler
 */

(function() {
  var ARGs, commands, data, fs, input, output, path, wave, winston;

  fs = require('fs');

  path = require('path');

  wave = require('./wave');

  winston = require('winston');

  ARGs = require('minimist')(process.argv.slice(2));

  commands = ARGs['_'];

  if (ARGs['version'] || ARGs['v']) {
    data = JSON.parse(fs.readFileSync('../../package.json', 'utf8'));
    winston.info('Wave v1.1.2');
    process.exit();
  }

  if (commands.length !== 2) {
    winston.error('Invalid number of arguments!');
    process.exit();
  }

  input = path.resolve(process.cwd(), commands[0]);

  output = path.resolve(process.cwd(), commands[1]);

  wave(input, output, function() {
    return winston.info('Compilation successful.');
  });

}).call(this);
