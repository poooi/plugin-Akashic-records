import { LogContentAction, LogContentState, logContent } from './log-content'
import { DataType } from './tab'
import { filterSelectors, resolveLogContent, resourceFilter } from '../selectors'
import { getCachedFcdMap, PoiStoreLike } from '../utils/map-cell'

/**
 * poi passes its own root state to plugin reducers as a third argument, which
 * redux's `Reducer` type does not describe.
 */
export type LogContentReducer = (
  state: LogContentState | undefined,
  action: LogContentAction,
  store?: PoiStoreLike
) => LogContentState

function boundActivePageNum(state: LogContentState, dataType: DataType, store?: PoiStoreLike) {
  // poi is expected to hand us its root state; falling back to the map the view
  // last used keeps the page count from ever disagreeing with the table.
  const fcdMap = store?.fcd?.map ?? getCachedFcdMap()
  const logLength =
    dataType === 'resource' ? resourceFilter(state).length
      : filterSelectors[dataType](resolveLogContent(state, dataType, fcdMap)).length
  let { activePage } = state
  activePage = Math.min(activePage, Math.ceil(logLength/state.showAmount))
  activePage = Math.max(activePage, 1)
  if (activePage !== state.activePage)
    return {...state, activePage }
  return state
}

export default function (type: DataType) {
  const reducer: LogContentReducer = (state, action, store) => {
    if (action.dataType === type) {
      const ret = logContent(state, action)
      if (['@@poi-plugin-akashic-records/INITIALIZE_LOGS', '@@poi-plugin-akashic-records/SET_FILTER_KEY',
        '@@poi-plugin-akashic-records/SET_SHOW_AMOUNT', '@@poi-plugin-akashic-records/SET_ACTIVE_PAGE',
        '@@poi-plugin-akashic-records/SET_TIME_SCALE'].includes(action.type))
        return boundActivePageNum(ret, type, store)
      return ret
    } else if (state == null) {
      return logContent(state, {
        type: '@@poi-plugin-akashic-records/NONE',
        dataType: type,
      })
    } else
      return state
  }
  return reducer
}
