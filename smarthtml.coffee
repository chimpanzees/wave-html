
commands:
  declareVariable: /<!-- #(.)+( )(.)+ -->/i

path = 'error.error'
process.argv.forEach (val, index, array) -> path = val if index == 2
