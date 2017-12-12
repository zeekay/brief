import fs   from 'fs'
import path from 'path'

import hljs   from 'brief-highlightjs'
import marked from 'marked'
import pug    from 'pug'


compilers =
  pug: (template) ->
    pug.compile template, pretty: true

  markdown: (content) ->
    marked.setOptions
      gfm:        true
      tables:     true
      smartLists: true
      highlight:  (code, lang) ->
        if lang
          try
            hljs.highlight(lang, code).value
          catch err
            console.error err
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

    cb null, (compilers.pug template) ctx


module.exports =
  markdown: markdown
  compile:  compile
