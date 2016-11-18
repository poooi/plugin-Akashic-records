import { combineReducers } from 'redux'
import logContent from './log-content'

const typeList = ['attack', 'mission', 'createship',
                  'createitem', 'resource', 'retirement']

export default combineReducers(typeList.reduce((obj, key) => {
  obj[key] = logContent(key)
  return obj
}, {}))
