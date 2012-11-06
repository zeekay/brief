fs     = require 'fs'
jade   = require 'jade'
marked = require 'marked'
{exec} = require 'child_process'
hljs   = require 'highlight.js'

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
  jade.compile(template) ctx

module.exports =
  update: (options) ->
    QUIET = options.quiet or false
    cwd = process.cwd()

    options.branch   ?= 'gh-pages'
    options.remote   ?= 'origin'
    options.content  ?= cwd + '/README.md'
    options.output   ?= cwd + '/index.html'
    options.push     ?= true
    options.template ?= cwd + '/index.jade'
    options.ctx      ?= {}

    {branch, remote, ctx, output, push} = options
    content  = fs.readFileSync options.content, 'utf8'
    template = fs.readFileSync options.template, 'utf8'

    exec "git log -1 --pretty=%B", (err, stdout, stderr) ->
      # get last commit message
      message = stdout.trim()

      if branch == 'master'
        fs.writeFileSync output, compile(template, content, ctx), 'utf8'
        run "git add #{output}", ->
          run 'git commit --amend -C HEAD', ->
            if push
              run "git push -f #{remote} #{branch}"
      else
        run 'git checkout gh-pages', ->
          run 'git reset --hard master', ->
            fs.writeFileSync output, @compile(template, ctx), 'utf8'
            run "git add #{output}", ->
              run 'git commit --amend -C HEAD', ->
                if push
                  run "git push -f #{remote} #{branch}"
