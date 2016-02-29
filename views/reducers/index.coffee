{combineReducers} = require 'redux'
logContent = require 'log-content'

module.exports = combineReducers
  attack: logContent('attack')
  mission: logContent('attack')
  createShip: logContent('createship')
  createItem: logContent('createitem')
  resource: logContent('resource')
