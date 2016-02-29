{combineReducers} = require 'redux'

data = require './data'
{tab, language, tabVisibility} = require './tab'
{activePage, showAmount} = require './page'
{configList, checkboxVisible, statisticsVisible}  = require './view-control'
searchRules = require './search-rules'
statisticsRules = require './statistics-rules'
filterKeys = require './filter-keys'

logContent = combineReducers {
  data,
  tab,
  language,
  tabVisibility,
  activePage,
  showAmount,
  configList,
  checkboxVisible,
  statisticsVisible,
  searchRules,
  statisticsRules,
  filterKeys
}


module.exports = (type) =>
  (state, action) =>
    if action.dataType is type
      logContent state, action
    else
      logContent state,
        type: 'NONE'
        dataType: dataType
