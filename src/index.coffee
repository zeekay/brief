fs     = require 'fs'
jade   = require 'jade'
marked = require 'marked'

module.exports = brief =
  compile: (template, input) ->
    if typeof input is 'string'
      jade.compile(template)(marked input)
    else
      md = {}
      for k,v of input
        md[k] = marked v
      jade.compile(template)(md)

  render: (template, input, callback) ->
    fs.readFile template, 'utf8', (err, template) ->
      fs.readFile input, 'utf8', (err, input) ->
        throw err if err
        callback null, brief.compile template, input

  renderFile: (template, input, output) ->
    brief.render template, input, (err, content) ->
      fs.writeFile output, content, 'utf8', (err) ->
        throw err if err
