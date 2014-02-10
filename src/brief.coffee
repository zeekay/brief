exec   = (require 'executive').quiet
fs     = require 'fs'
hljs   = require 'highlight.js'
jade   = require 'jade'
marked = require 'marked'


marked.setOptions
  gfm: true
  tables: true
  smartLists: true
  highlight: (code, lang) ->
    if lang
      try
        hljs.highlight(lang, code).value
      catch err
        throw new Error "Unable to highlight #{lang}"
    else
      hljs.highlightAuto(code).value


compile = (template, content, ctx = {}) ->
  ctx.content ?= marked content
  jade.compile(template) ctx


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
    cwd = process.cwd()
    quiet = options.quiet ? false

    options.branch   ?= 'gh-pages'
    options.remote   ?= 'origin'
    options.content  ?= cwd + '/README.md'
    options.output   ?= cwd + '/index.html'
    options.push     ?= true
    options.template ?= cwd + '/index.jade'
    options.ctx      ?= {}

    {branch, remote, ctx, output, push} = options

    run = (cmd, cb = ->) ->
      console.log "> #{cmd}" unless quiet

      exec cmd, (err, stdout, stderr) ->
        return if quiet

        stderr = stderr.trim()
        stdout = stdout.trim()

        console.log stderr if stderr
        console.log stdout if stdout

        cb()

    # update github page in master branch
    updateMaster = ->
      content  = fs.readFileSync options.content, 'utf8'
      template = fs.readFileSync options.template, 'utf8'
      fs.writeFileSync output, compile(template, content, ctx), 'utf8'

      run "git add #{output}", ->
        run 'git commit --amend -C HEAD', ->
          if push
            run "git push -f #{remote} #{branch}"

    # upate github page in gh-pages branch
    updateBranch = ->
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

    if branch == 'master'
      updateMaster()
    else
      updateBranch()
