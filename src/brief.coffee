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

# find all content
findFiles = (template) ->
  readRe = /read\([']([^']+)[']\)|read\(["]([^"]+)["]\)/g

  matches = []
  while (match = readRe.exec template)?
    matches.push match[1]
  matches

# compile jade template with appropriate context
compile = (template, ctx, quiet, cb) ->
  for filename in findFiles template
    replace = Math.random().toString().replace '0.', '_'
    pattern = new RegExp "read\\(['\"]#{filename}['\"]\\)"
    content = fs.readFileSync filename, 'utf8'

    console.log "- using #{filename} as content" unless quiet

    if /\.md$|\.markdown/.test filename
      try
        content = marked content
      catch err
        console.error err
        throw err

    ctx[replace] = content
    template = template.replace pattern, replace

  cb null, (jade.compile template, pretty: true) ctx

module.exports =
  update: (options = {}) ->
    templateFile = options.template ? 'index.jade'
    outputFile   = options.output   ? 'index.html'
    ctx          = options.ctx      ? {}
    branch       = options.branch   ? 'gh-pages'
    remote       = options.remote   ? 'origin'
    push         = options.push     ? true
    quiet        = options.quiet    ? false

    # run command and exit if anything bad happens
    run = (cmd, cb = ->) ->
      console.log "> #{cmd}" unless quiet

      exec cmd, (err, stdout, stderr) ->
        unless quiet
          stderr = stderr.trim()
          stdout = stdout.trim()

          console.log stdout if stdout
          console.error stderr if stderr

        if err?
          exec 'git checkout master', ->
            process.exit 1
        else
          cb null

    # update github page in master branch
    updateMaster = ->
      run 'git checkout master', ->
        console.log "- using #{templateFile} as template" unless quiet

        template = fs.readFileSync templateFile, 'utf8'
        compile template, ctx, quiet, (err, output) ->

          console.log "- writing #{outputFile}" unless quiet
          fs.writeFileSync outputFile, output, 'utf8'

          run "git add #{outputFile}", ->
            run 'git commit --amend -C HEAD', ->

              if push
                run "git push -f #{remote} master"

    # upate github page in gh-pages branch
    updateGhPages = ->
      run 'git checkout gh-pages', ->
        console.log "- using #{templateFile} as template" unless quiet
        template = fs.readFileSync templateFile, 'utf8'

        run 'git checkout master', ->
          compile template, ctx, quiet, (err, output) ->

            run 'git checkout gh-pages', ->
              console.log "- writing #{outputFile}" unless quiet
              fs.writeFileSync outputFile, output, 'utf8'

              run "git add #{outputFile}", ->
                run 'git commit -m "Updating generated content"', ->

                  if push
                    run "git push -f #{remote} gh-pages", ->
                      run 'git checkout master'
                  else
                    run 'git checkout master'

    if branch == 'master'
      updateMaster()
    else
      updateGhPages()
