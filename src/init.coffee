exec = require 'executive'
fs   = require 'fs'

log = (message) ->
  console.log "- #{message}"

# run command and exit if anything bad happens
run = (cmd, cb = ->) ->
  console.log "> #{cmd}"

  exec cmd, (err, stdout, stderr) ->
    stderr = stderr.trim()
    stdout = stdout.trim()

    console.log stdout if stdout
    console.error stderr if stderr

    if err?
      return exec 'git checkout master', ->
        process.exit 1

    cb null

module.exports = (options = {}) ->
  branch   = options.branch   ? 'gh-pages'
  content  = options.content  ? 'README.md'
  template = options.template ? 'zeekay/brief-minimal'

  run "git symbolic-ref HEAD refs/heads/#{branch}", ->
    exec "git status", (err, out) ->
      newFileRe = /new file:/
      files = []

      for line in out.split '\n'
        if newFileRe.test line
          [_, filename] = line.split ':'
          filename = filename.trim()
          files.push filename

      done = 0
      todo = files.length

      while files.length > 0
        fs.unlink files.pop(), (err) ->
          done++
          throw err if err?

          if done == todo
            run 'rm .git/index', ->
              run "git pull https://github.com/#{template}", ->
                run "#{branch} initialized, #{content} configured as content for template"
