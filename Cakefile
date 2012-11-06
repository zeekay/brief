{exec} = require 'child_process'

run = (cmd, callback) ->
  exec cmd, (err, stderr, stdout) ->
    if stderr
      console.error stderr
    if stdout
      console.log stdout
    if typeof cb == 'function'
      callback err, stderr, stdout

task 'build', 'Build project', ->
  run './node_modules/.bin/coffee -bc -o lib/ src/'

task 'publish', 'Publish current version to NPM', ->
  run './node_modules/.bin/coffee -bc -o lib/ src/', ->
    run 'git push', ->
      run 'npm publish'
