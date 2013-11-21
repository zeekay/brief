exec = require 'executive'

task 'build', 'Build project', ->
  exec './node_modules/.bin/coffee -bcm -o lib/ src/'

task 'gh-pages', 'Generate gh-pages', ->
  brief = require 'brief'
  brief.update()

task 'publish', 'Publish project', ->
  exec ['git push', 'npm publish'], ->
    invoke 'gh-pages'

task 'test', 'Run tests', ->
  console.log 'todo'
