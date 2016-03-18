{combineReducers} = require 'redux'

data = require './data'
{tabs, language, tabVisibility} = require './tab'
{activePage, showAmount} = require './page'
{configList, configListChecked, checkboxVisible, statisticsVisible, showTimeScale}  = require './view-control'
searchRules = require './search-rules'
statisticsRules = require './statistics-rules'
filterKeys = require './filter-keys'

{filterSelectors, resourceFilter} = require '../selectors'

logContent = combineReducers {
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
  showTimeScale
}

boundActivePageNum = (state, dataType) ->
  if dataType isnt 'resource'
    logLength = filterSelectors[dataType](state).size
  else
    logLength = resourceFilter(state).size
  activePage = state.activePage
  activePage = Math.min activePage, Math.ceil(logLength/state.showAmount)
  activePage = Math.max activePage, 1
  state.activePage = activePage
  state

module.exports = (type) ->
  (state, action) ->
    if action.type is 'SET_LANGUAGE'
      logContent state, action
    else if action.dataType is type
      state = logContent state, action
      switch action.type
        when 'INITIALIZE_LOGS', 'SET_FILTER_KEY',\
             'SET_SHOW_AMOUNT', 'SET_ACTIVE_PAGE', 'SET_TIME_SCALE'
          boundActivePageNum state, type
        else
          state
    else if not state?
      logContent state,
        type: 'NONE'
        dataType: type
    else
      state
