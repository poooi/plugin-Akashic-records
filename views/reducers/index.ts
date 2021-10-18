import { combineReducers } from 'redux'
import LogContentFactory from './log-content-factory'
import { DataType } from './tab'

const typeList: DataType[] = ['attack', 'mission', 'createship',
  'createitem', 'resource', 'retirement']

const entries = Object.fromEntries(new Map(typeList.map(type => [type, LogContentFactory(type)])))

export const reducer = combineReducers(entries)

export type PluginState = ReturnType<typeof reducer>
