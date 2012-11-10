{exec} = require 'child_process'

run = (cmd, callback) ->
  exec cmd, (err, stderr, stdout) ->
    if stderr
      console.error stderr.trim()
    if stdout
      console.log stdout.trim()

    if typeof callback == 'function'
      callback err, stderr, stdout

task 'build', 'Build project', ->
  run './node_modules/.bin/coffee -bc -o lib/ src/'

task 'gh-pages', 'Generate gh-pages', ->
  brief = require 'brief'
  brief.update()

task 'publish', 'Publish project', ->
  run './node_modules/.bin/coffee -bc -o lib/ src/', ->
    run 'git push', ->
      run 'npm publish', ->
        invoke 'gh-pages'
