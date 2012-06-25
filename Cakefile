{exec} = require 'child_process'

task 'build', 'Build project', ->
  console.log 'coffee: Compiling src/*.coffee -> lib/*.js'
  exec './node_modules/.bin/coffee -bc -o lib/ src/'

task 'publish', 'Publish current version to NPM', ->
  invoke 'build'
  exec 'npm publish'
