import LogContentFactory from './log-content-factory'
import { DataType } from './tab'
import { LogContentAction, LogContentState } from './log-content'
import { PoiStoreLike } from '../utils/map-cell'

const typeList: DataType[] = ['attack', 'mission', 'createship',
  'createitem', 'resource', 'retirement']

const entries = typeList.map((type) => [type, LogContentFactory(type)] as const)

export type PluginState = Record<DataType, LogContentState>

/**
 * Combined by hand rather than with redux's `combineReducers`, which drops
 * extra arguments: poi hands plugin reducers its own root state as a third
 * argument, and that is the only way to read it from a reducer, since
 * `window.getStore` is locked to the slice being reduced while reducers run.
 */
export const reducer = (
  state: PluginState | undefined,
  action: LogContentAction,
  store?: PoiStoreLike
): PluginState => {
  let hasChanged = state == null
  const nextState = {} as PluginState
  for (const [type, logContentReducer] of entries) {
    const previous = state?.[type]
    const next = logContentReducer(previous, action, store)
    nextState[type] = next
    hasChanged = hasChanged || next !== previous
  }
  return hasChanged ? nextState : (state as PluginState)
}
