###
  Command line tool for wave compiler
###

# Require libs
fs = require('fs')
path = require('path')
wave = require('./wave')
winston = require('winston')

# Parse command line arguments
ARGs = require('minimist')(process.argv.slice(2))
commands = ARGs['_']

# Check for version command
if (ARGs['version'] or ARGs['v'])
  data = JSON.parse(fs.readFileSync('../../package.json', 'utf8'))
  winston.info('Wave v1.1.2')
  process.exit()

# Check if input and output is provided
if (commands.length != 2)
  winston.error('Invalid number of arguments!')
  process.exit()

# Fetch input and output
input = path.resolve(process.cwd(), commands[0])
output = path.resolve(process.cwd(), commands[1])

# Start compilation process
wave input, output, () -> winston.info('Compilation successful.')
