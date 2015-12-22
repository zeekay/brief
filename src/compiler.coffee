fs   = require 'fs'
path = require 'path'


compilers =
  jade: (template) ->
    jade = require 'jade'

    jade.compile template, pretty: true

  markdown: (content) ->
    hljs   = require 'brief-highlight.js'
    marked = require 'marked'

    marked.setOptions
      gfm:        true
      tables:     true
      smartLists: true
      highlight:  (code, lang) ->
        if lang
          try
            hljs.highlight(lang, code).value
          catch err
            throw new Error "Unable to highlight #{lang}"
        else
          hljs.highlightAuto(code).value
    marked content


# compile template with appropriate context
compile = (templateFile, ctx, cb) ->
  fs.readFile templateFile, 'utf8', (err, template) ->
    if /\.md$|\.markdown/.test filename
      try
        content = markdown content
      catch err
        console.error err
        throw err

      ctx[replace] = content
      template = template.replace pattern, replace

    cb null, (jade.compile template, pretty: true) ctx


module.exports =
  markdown: markdown
  compile: compile
