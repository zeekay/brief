import program   from 'commander'

import init      from './init'
import brief     from './'
import {version} from '../package.json'

program.version(version)

program
  .command('init')
  .option('-t, --template <repo>', 'template repo to use')
  .action init

program
  .command('publish')
  .option('-o, --output <file>', 'where to output rendered content')
  .option('-t, --template <file>', 'pug template to use')
  .action (opts) -> brief.update opts

help = ->
  console.log program.helpInformation()
  process.exit()

program.parse process.argv

unless program.args.length
  process.argv.splice 2, 0, 'publish'
  program.parse process.argv
