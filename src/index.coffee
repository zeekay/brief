Brief = require './brief'
init  = require './init'

brief       = new Brief()
brief.Brief = Brief
brief.init  = init

module.exports = brief
