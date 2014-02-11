program = require 'jade/node_modules/commander'
version = require('../package.json').version
brief   = require './index'

program
  .version(version)
  .usage('-t <template> -o <output>')
  .option('-o, --output <file>', 'where to output rendered content')
  .option('-t, --template <file>', 'jade template to use')
  .parse(process.argv)

help = ->
  console.log program.helpInformation()
  process.exit()

brief.update
  output:   program.output
  template: program.template
