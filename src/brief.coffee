fs     = require 'fs'
jade   = require 'jade'
marked = require 'marked'
{exec} = require 'child_process'
hljs   = require 'highlight.js'
mote   = require 'mote'

QUIET = false

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

run = (cmd, cb) ->
  console.log "> #{cmd}" if not QUIET
  exec cmd, (err, stdout, stderr) ->
    if not QUIET
      if stderr.trim()
        console.log stderr.trim()
      if stdout.trim()
        console.log stdout.trim()
    cb() if typeof cb is 'function'

compile = (template, content, ctx = {}) ->
  ctx.content ?= marked content
  mote.compile(template) ctx

# in which our hero endeavours to uncover whether our template exists or not
checkTemplate = (template, output) ->
  if fs.existsSync template
    return template
  # template not found, only output
  if fs.existsSync output and path.basename ouput == 'index.html'
    # maybe this is a github pages template?
    return


module.exports =
  update: (options = {}) ->
    QUIET = options.quiet or false
    cwd = process.cwd()

    options.branch   ?= 'gh-pages'
    options.remote   ?= 'origin'
    options.content  ?= cwd + '/README.md'
    options.output   ?= cwd + '/index.html'
    options.push     ?= true
    options.template ?= cwd + '/layout.html'
    options.ctx      ?= {}
    options.compiler ?= compiler

    {branch, remote, ctx, output, push} = options

    if branch == 'master'
      content  = fs.readFileSync options.content, 'utf8'
      template = fs.readFileSync options.template, 'utf8'
      fs.writeFileSync output, compile(template, content, ctx), 'utf8'
      run "git add #{output}", ->
        run 'git commit --amend -C HEAD', ->
          if push
            run "git push -f #{remote} #{branch}"
    else
      content = options.content.replace(cwd, '').replace /^\//, ''
      run "git checkout #{branch}", ->
        template = fs.readFileSync options.template, 'utf8'
        exec "git show master:#{content}", (err, content) ->
          throw err if err
          fs.writeFileSync output, compile(template, content, ctx), 'utf8'
          run "git add #{output}", ->
            run 'git commit -m "Updating generated content"', ->
              if push
                run "git push -f #{remote} #{branch}", ->
                  run "git checkout master"
              else
                run "git checkout master"
