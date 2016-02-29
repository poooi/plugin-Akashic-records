{combineReducers} = require 'redux'

data = require './data'
{tabs, language, tabVisibility} = require './tab'
{activePage, showAmount} = require './page'
{configList, configListChecked, checkboxVisible, statisticsVisible}  = require './view-control'
searchRules = require './search-rules'
statisticsRules = require './statistics-rules'
filterKeys = require './filter-keys'

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
  filterKeys
}


module.exports = (type) =>
  (state, action) =>
    if action.type is 'SET_LANGUAGE'
      logContent state, action
    else if action.dataType is type
      logContent state, action
    else
      logContent state,
        type: 'NONE'
        dataType: dataType
