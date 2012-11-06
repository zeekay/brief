fs     = require 'fs'
jade   = require 'jade'
marked = require 'marked'
{exec} = require 'child_process'
hljs   = require 'highlight.js'

marked.setOptions
  gfm: true
  highlight: (code, lang) ->
    if lang
      try
        hljs.highlight(lang, code).value
      catch err
        throw new Error "Unable to highlight #{lang}"
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

    updateMaster: (template=CWD+'/index.jade', output=CWD+'/index.html', readme='README.md') ->
      content = @compile fs.readFileSync(template, 'utf8'), fs.readFileSync(readme, 'utf8')
      fs.writeFileSync output, content, 'utf8'
      run "git add #{output}", ->
        run 'git commit -m "Update generated content"', ->
          run 'git push -f'

    updateGithubPages: (template=CWD+'/index.jade', output=CWD+'/index.html', readme='README.md') ->
      content = @compile fs.readFileSync(template, 'utf8'), readme
      fs.writeFileSync output, content, 'utf8'
      run 'git checkout gh-pages', ->
        run 'git reset --hard master', ->
          run "git add #{output}", ->
            run 'git commit -m "Update generated content"', ->
              run 'git push -f origin gh-pages'
