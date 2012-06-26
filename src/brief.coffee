fs     = require 'fs'
jade   = require 'jade'
marked = require 'marked'
{exec} = require 'child_process'
hljs   = require 'highlight.js'

marked.setOptions
  gfm: true
  highlight: (code, lang) ->
    if lang
      hljs.highlight(lang, code).value
    else
      hljs.highlightAuto(code).value

CWD = process.cwd()
QUIET = false

run = (cmd, cb) ->
  console.log "> #{cmd}" if not QUIET
  exec cmd, (err, stdout, stderr) ->
    if not QUIET
      if stderr.trim()
        console.log stderr.trim()
      if stdout.trim()
        console.log stdout.trim()
    cb() if typeof cb is 'function'

module.exports = ({quiet}) ->
  QUIET = quiet
  brief =
    compile: (template, input) ->
      if typeof input is 'string'
        jade.compile(template)(content: marked input)
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

    updateGithubPages: (template=CWD+'/index.jade', output=CWD+'/index.html', readme='README.md') ->
      run 'git checkout gh-pages', ->
        exec "git show master:#{readme}", (err, stdout, stderr) ->
          console.log "brief: Compiling #{template} using #{readme}"
          content = brief.compile fs.readFileSync(template, 'utf8'), stdout
          fs.writeFileSync output, content, 'utf8'
          run "git add #{output}", ->
            run 'git commit -m "Updated gh-pages."', ->
              run 'git push', ->
                run 'git checkout master'
