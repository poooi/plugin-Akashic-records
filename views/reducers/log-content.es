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

const boundActivePageNum = (state, dataType) => {
  const logLength =
    dataType === 'resource' ? resourceFilter(state).size
                            : filterSelectors[dataType](state).size
  let { activePage } = state
  activePage = Math.min(activePage, Math.ceil(logLength/state.showAmount))
  activePage = Math.max(activePage, 1)
  if (activePage !== state.activePage)
    return {...state, activePage }
  return state
}

export default function (type) {
  return (state, action) => {
    if (action.type === 'SET_LANGUAGE')
      return logContent(state, action)
    else if (action.dataType === type) {
      const state = logContent(state, action)
      if (['INITIALIZE_LOGS', 'SET_FILTER_KEY',
           'SET_SHOW_AMOUNT', 'SET_ACTIVE_PAGE',
           'SET_TIME_SCALE'].includes(action.type))
        return boundActivePageNum(state, type)
      return state
    } else if (!state) {
      return logContent(state, {
        ...type,
        dataType: type,
      })
    } else
      return state
  }
}
