program = require 'jade/node_modules/commander'

program
  .version(require('../package').version)

program
  .command('init')
  .option('-t, --template <repo>', 'template repo to use')
  .action (opts) ->
    (require './init') opts

program
  .command('publish')
  .option('-o, --output <file>', 'where to output rendered content')
  .option('-t, --template <file>', 'jade template to use')
  .action (opts) ->
    (require './index').update opts

help = ->
  console.log program.helpInformation()
  process.exit()

program.parse process.argv

unless program.args.length
  process.argv.splice 2, 0, 'publish'
  program.parse process.argv
