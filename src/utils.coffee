# simple logger to differentiate our messages from program stdout
exports.log = (msg) ->
  console.log "- #{msg}"


# run command and exit if anything bad happens
exports.run = (cmd, cb = ->) ->
  exec = (require 'executive').quiet

  console.log "> #{cmd}"

  exec cmd, (err, stdout = '', stderr = '') ->
    stderr = stderr.trim()
    stdout = stdout.trim()

    console.log stdout if stdout
    console.error stderr if stderr

    if err?
      return exec 'git checkout master', ->
        process.exit 1

    cb null

# make get request, return data
exports.request = (url, cb) ->
  http.get url, (res) ->
    data = ''

    res.on 'data', (chunk) ->
      data += chunk

    res.on 'end', ->
      cb null, data
