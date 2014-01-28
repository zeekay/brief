program = require 'jade/node_modules/commander'
version = require('../package.json').version
brief   = require './index'

program
  .version(version)
  .usage('-c <content> -o <output> -t <template>')
  .option('-c, --content <file>', 'markdown file to use as content')
  .option('-o, --output <file>', 'where to output rendered content')
  .option('-t, --template <file>', 'jade template to use')
  .parse(process.argv)

help = ->
  console.log program.helpInformation()
  process.exit()

brief.update
  content:  program.content
  output:   program.output
  template: program.template
