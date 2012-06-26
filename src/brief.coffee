fs     = require 'fs'
jade   = require 'jade'
marked = require 'marked'
{exec} = require 'child_process'

CWD = process.cwd()

module.exports =
  compile: (template, input) ->
    if typeof input is 'string'
      jade.compile(template)(marked input)
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

  updateGithubPages: (template=CWD+'/index.jade', output=CWD+'/index.html', readme='README.md') ->
    exec "git show master:#{readme}", (err, stdout, stderr) ->
      content = brief.compile fs.readFileSync(template, 'utf8'), stdout
      fs.writeFileSync output, content, 'utf8'
      exec 'git add index.html', ->
        exec 'git commit -m "Updated gh-pages."', ->
          exec 'git push', ->
            exec 'git checkout master', ->
