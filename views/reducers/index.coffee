{combineReducers} = require 'redux'
logContent = require './log-content'

module.exports = combineReducers
  attack: logContent('attack')
  mission: logContent('mission')
  createship: logContent('createship')
  createitem: logContent('createitem')
  resource: logContent('resource')
