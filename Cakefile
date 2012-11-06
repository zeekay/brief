{exec} = require 'child_process'

task 'build', 'Build project', ->
  exec './node_modules/.bin/coffee -bc -o lib/ src/', (err, stderr, stdout) ->
    if stderr
      console.error stderr
    if stdout
      console.log stdout

task 'publish', 'Publish current version to NPM', ->
  invoke 'build'
  exec 'git push', ->
    exec 'npm publish'
