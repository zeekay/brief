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
    run 'rm .git/index', ->
      run "git pull https://github.com/#{template}", ->
        run "#{branch} initialized, #{content} configured as content for template"
