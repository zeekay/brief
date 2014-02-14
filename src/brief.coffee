exec   = (require 'executive').quiet
fs     = require 'fs'
hljs   = require 'highlight.js'
jade   = require 'jade'
marked = require 'marked'


class Brief
  constructor: (options = {}) ->
    @templateFile = options.template ? 'index.jade'
    @outputFile   = options.output   ? 'index.html'
    @ctx          = options.ctx      ? {}
    @branch       = options.branch   ? 'gh-pages'
    @remote       = options.remote   ? 'origin'
    @push         = options.push     ? true
    @quiet        = options.quiet    ? false

  # convert markdown to html
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
            throw new Error "Unable to highlight #{lang}"
        else
          hljs.highlightAuto(code).value
    marked content

  # find all content
  findFiles: (template) ->
    readRe = /read\([']([^']+)[']\)|read\(["]([^"]+)["]\)/g

    matches = []
    while (match = readRe.exec template)?
      matches.push match[1]
    matches

  # compile template with appropriate context
  compile: (template, cb) ->
    ctx = JSON.parse JSON.stringify @ctx

    for filename in @findFiles template
      replace = Math.random().toString().replace '0.', '_'
      pattern = new RegExp "read\\(['\"]#{filename}['\"]\\)"
      content = fs.readFileSync filename, 'utf8'

      @log "using #{filename} as content"

      if /\.md$|\.markdown/.test filename
        try
          content = @markdown content
        catch err
          console.error err
          throw err

      ctx[replace] = content
      template = template.replace pattern, replace

    cb null, (jade.compile template, pretty: true) ctx

  log: (message) ->
    console.log "- #{message}" unless @quiet

  # run command and exit if anything bad happens
  run: (cmd, cb = ->) ->
    console.log "> #{cmd}" unless @quiet

    exec cmd, (err, stdout, stderr) ->
      unless @quiet
        stderr = stderr.trim()
        stdout = stdout.trim()

        console.log stdout if stdout
        console.error stderr if stderr

      if err?
        return exec 'git checkout master', ->
          process.exit 1

      cb null

  # perform gh-pages update.
  update: (options = {}) ->
    @templateFile ?= options.template
    @outputFile   ?= options.output
    @ctx          ?= options.ctx
    @branch       ?= options.branch
    @remote       ?= options.remote
    @push         ?= options.push
    @quiet        ?= options.quiet
    @markdedOpts  ?= options.marked

    if @branch == 'master'
      @updateMaster()
    else
      @updateGhPages()

  # update github page in master branch
  updateMaster: ->
    @run 'git checkout master', =>
      @log "using #{@templateFile} as template"

      template = fs.readFileSync @templateFile, 'utf8'
      @compile template, (err, output) =>

        @log "writing #{@outputFile}"
        fs.writeFileSync @outputFile, output, 'utf8'

        @run "git add #{@outputFile}", =>
          @run 'git commit --amend -C HEAD', =>
            @run "git push -f #{@remote} master" if @push

  # upate github page in gh-pages branch
  updateGhPages: ->
    @run 'git checkout gh-pages', =>
      @log "using #{@templateFile} as template"
      template = fs.readFileSync @templateFile, 'utf8'

      @run 'git checkout master', =>
        @compile template, (err, output) =>

          @run 'git checkout gh-pages', =>
            @log "writing #{@outputFile}"
            fs.writeFileSync @outputFile, output, 'utf8'

            @run "git add #{@outputFile}", =>
              @run 'git commit -m "Updating generated content"', =>
                @run 'git checkout master', =>
                  @run "git push -f #{@remote} gh-pages" if @push


module.exports = Brief
