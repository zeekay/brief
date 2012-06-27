path = require 'path'
fs   = require 'fs'

# The location of exists/existsSync changed in node v0.8.0.
{existsSync} = if fs.existsSync then fs else path

# This is a bit of a hack, if `../src` exists then assume we're being required
# from the git repo. To make development a bit easier we'll require the
# uncompiled version of the project. In normal production use `../src` will
# be missing since it's in `.npmignore`.
modName = path.basename path.resolve __dirname + '/..'
if existsSync __dirname + '/../src'
  require 'coffee-script'
  mod = require "../src/#{modName}"
else
  mod = require "./#{modName}"

# Borrow version information from `package.json`.
mod.version = require('../package.json').version

module.exports = mod
