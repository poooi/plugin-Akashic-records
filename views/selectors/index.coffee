{createSelector,} = require 'reselect'
{APPDATA_PATH, CONST, config, Immutable} = window

dateToString = (date)->
  month = date.getMonth() + 1
  if month < 10
    month = "0#{month}"
  day = date.getDate()
  if day < 10
    day = "0#{day}"
  hour = date.getHours()
  if hour < 10
    hour = "0#{hour}"
  minute = date.getMinutes()
  if minute < 10
    minute = "0#{minute}"
  second = date.getSeconds()
  if second < 10
    second = "0#{second}"
  "#{date.getFullYear()}/#{month}/#{day} #{hour}:#{minute}:#{second}"

filterRegWindex = (data, index, reg)->
  data.filter (row)=>
    if index is 0
      reg.test dateToString(new Date(row[0]))
    else
      reg.test "#{row[index]}"
filterStringWIndex = (data, index, keyword)->
  data.filter (row)=>
    if index is 0
      dateToString(new Date(row[0])).toLowerCase().trim().indexOf(keyword) >= 0
    else
      "#{row[index]}".toLowerCase().trim().indexOf(keyword) >= 0

filterWithIndex = (logs, filterKeys) ->
  retData = logs
  for key, index in filterKeys
    if key isnt ''
      regFlag = false
      res = key.match /^\/(.+)\/([gim]*)$/
      if res?
        try
          reg = new RegExp res[1], res[2]
          regFlag = true
        catch e
          consoleError "Failed to resolve RegExp #{key}."
      if regFlag
        retData = filterRegWindex retData, index, reg
      else
        retData = filterStringWIndex retData, index, key.toLowerCase().trim()
  retData

filterWNindex = (logs, keyword) ->
  if keyword is ''
      Immutable.List()
    else
      regFlag = false
      res = keyword.match /^\/(.+)\/([gim]*)$/
      if res?
        try
          reg = new RegExp res[1], res[2]
          regFlag = true
        catch e
          regFlag = false
        finally
          if regFlag
            keyword = reg
      logs.filter (log) =>
        match = false
        for item, i in log
          searchText = item
          if i is 0
            searchText = dateToString(new Date(searchText))
          else if not regFlag
            searchText = "#{searchText}".toLowerCase().trim()
          if regFlag
            match = keyword.test searchText
          else
            match = searchText.indexOf(keyword.toLowerCase().trim()) >= 0
          if match
            return match
        match

logSelectorFactory = () ->
  getLogs = (state) -> state.data
  getFilterKeys = (state) ->
    if state.configListChecked.get(1) or state.configListChecked.get(2)
      state.filterKeys.toArray()
    else
      []
  createSelector [getLogs, getFilterKeys], filterWithIndex

logSearchSelectorBaseFactory = (old, num) ->
  getLogs = (logsRes, searchRule)-> logsRes[searchRule.baseOn]
  getSearchKey = (logsRes, searchRule) -> searchRule.content
  [0...num].map (index) =>
    old[index] or createSelector [getLogs, getSearchKey], filterWNindex

logSearchSelectorFactory = () ->
  do () ->
    selector = null
    lastLogs = null
    (logs, filteredLogs, searchRules) ->
      if not selector or lastLogs isnt logs
        selector = logSearchSelectorBaseFactory([], searchRules.size)
      if selector.length isnt searchRules.size
        selector = logSearchSelectorBaseFactory(selector, searchRules.size)
      logsRes = [logs, filteredLogs]
      for searchRule, i in searchRules.toJS()
        logsRes[CONST.search.indexBase+i+1] = selector[i] logsRes, searchRule
      logsRes.map (logs) ->
        logs.size

module.exports =
  filterSelectors:
    attack: logSelectorFactory()
    mission: logSelectorFactory()
    createship: logSelectorFactory()
    createitem: logSelectorFactory()
    resource: logSelectorFactory()
  searchSelectors:
    attack: logSearchSelectorFactory()
    mission: logSearchSelectorFactory()
    createship: logSearchSelectorFactory()
    createitem: logSearchSelectorFactory()
    resource: logSearchSelectorFactory()
