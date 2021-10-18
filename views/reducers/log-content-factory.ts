import { Reducer } from 'redux'
import { LogContentAction, LogContentState, logContent } from './log-content'
import { DataType } from './tab'
import { filterSelectors, resourceFilter } from '../selectors'

function boundActivePageNum(state: LogContentState, dataType: DataType) {
  const logLength =
    dataType === 'resource' ? resourceFilter(state).length
      : filterSelectors[dataType](state).length
  let { activePage } = state
  activePage = Math.min(activePage, Math.ceil(logLength/state.showAmount))
  activePage = Math.max(activePage, 1)
  if (activePage !== state.activePage)
    return {...state, activePage }
  return state
}

export default function (type: DataType) {
  const reducer: Reducer<LogContentState, LogContentAction> = (state, action) => {
    if (action.dataType === type) {
      const ret = logContent(state, action)
      if (['@@poi-plugin-akashic-records/INITIALIZE_LOGS', '@@poi-plugin-akashic-records/SET_FILTER_KEY',
        '@@poi-plugin-akashic-records/SET_SHOW_AMOUNT', '@@poi-plugin-akashic-records/SET_ACTIVE_PAGE',
        '@@poi-plugin-akashic-records/SET_TIME_SCALE'].includes(action.type))
        return boundActivePageNum(ret, type)
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
