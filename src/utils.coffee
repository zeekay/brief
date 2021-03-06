import exec from 'executive'

# simple logger to differentiate our messages from program stdout
export log = (msg) ->
  console.log "- #{msg}"


# run command and exit if anything bad happens
export run = (cmd, cb = ->) ->
  console.log "> #{cmd}"

  exec.quiet cmd, (err, stdout = '', stderr = '') ->
    stderr = stderr.trim()
    stdout = stdout.trim()

    console.log stdout if stdout
    console.error stderr if stderr

    if err?
      return exec.quiet 'git checkout master', ->
        process.exit 1

    cb null

# make get request, return data
export request = (url, cb) ->
  http.get url, (res) ->
    data = ''

    res.on 'data', (chunk) ->
      data += chunk

    res.on 'end', ->
      cb null, data
