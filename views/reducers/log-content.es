import { combineReducers } from 'redux'

import data from './data'
import { tabs, language, tabVisibility } from './tab'
import { activePage, showAmount } from './page'
import {
  configList,
  configListChecked,
  checkboxVisible,
  statisticsVisible,
  showTimeScale,
} from './view-control'
import searchRules from './search-rules'
import statisticsRules from './statistics-rules'
import filterKeys from './filter-keys'

import { filterSelectors, resourceFilter } from '../selectors'

const logContent = combineReducers({
  data,
  tabs,
  language,
  tabVisibility,
  activePage,
  showAmount,
  configList,
  configListChecked,
  checkboxVisible,
  statisticsVisible,
  searchRules,
  statisticsRules,
  filterKeys,
  showTimeScale,
})

function boundActivePageNum(state, dataType) {
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

export default function (type) {
  return (state, action) => {
    if (action.type === '@@poi-plugin-akashic-records/SET_LANGUAGE')
      return logContent(state, action)
    else if (action.dataType === type) {
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
}
