#!/usr/bin/env node
mod =  if parseInt process.version.substring 3,4 > 6 then 'fs' else 'path'
{existsSync} = require mod

if existsSync __dirname + '/../src'
  require 'coffee-script'
  module.exports = require '../src/brief'
else
  module.exports = require './brief'
