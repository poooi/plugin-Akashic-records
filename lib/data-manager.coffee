"use strict"

fs = require 'fs-extra'
glob = require 'glob'
path = require 'path-extra'
_ = require 'underscore'

{APPDATA_PATH, CONST} = window

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

consoleLog = (msg) ->
  console.log "[Akashic Records][Data Manager] #{msg}" if process.env.DEBUG?

consoleWarn = (msg) ->
  console.warn "[Akashic Records][Data Manager] #{msg}" if process.env.DEBUG?

consoleError = (msg) ->
  console.error "[Akashic Records][Data Manager] #{msg}" if process.env.DEBUG?

typeList = CONST.typeList
eventList = CONST.eventList

RAW_DATA_INDEX = CONST.search.rawDataIndex
FILTER_DATA_INDEX = CONST.search.filteredDataIndex
INDEX_BASE = CONST.search.indexBase

filterReg = (data, index, reg)->
  data.filter (row)=>
    if index is 0
      reg.test dateToString(new Date(row[0]))
    else
      reg.test "#{row[index]}"
filterString = (data, index, keyword)->
  data.filter (row)=>
    if index is 0
      dateToString(new Date(row[0])).toLowerCase().trim().indexOf(keyword) >= 0
    else
      "#{row[index]}".toLowerCase().trim().indexOf(keyword) >= 0

class SearchBuffer
  constructor: (data = []) ->
    @data = data
    @key = {}

class DataManager
  constructor: ->
    @data =
      raw: {}
      afterFilter: {}
    @dataVersion =
      raw: {}
      afterFilter: {}
    for key, value of @data
      for typeKey, typeValue of CONST.typeList
        value[typeValue] = []
    for key, value of @dataVersion
      for typeKey, typeValue of CONST.typeList
        value[typeValue] = 0

    @nickNameId = 0

    @listeners = {}

    @filterKey = {}

    @searchBuffer = {}

    for key, type of CONST.typeList
      @filterKey[type] = []
      @searchBuffer[type] = []
      @searchBuffer[type][RAW_DATA_INDEX] = new SearchBuffer()
      @searchBuffer[type][FILTER_DATA_INDEX] = new SearchBuffer()
      @addListener type, CONST.eventList.dataChange, do (type) =>
        () =>
          @searchBuffer[type][RAW_DATA_INDEX] = new SearchBuffer(@data.raw[type])
          @dataVersion.raw[type]++
          if @dataVersion.raw[type] > 0xFFFFFFFF
            @dataVersion.raw[type] = 0
      @addListener type, CONST.eventList.filteredDataChange, do (type) =>
        () =>
          @searchBuffer[type][FILTER_DATA_INDEX] = new SearchBuffer(@data.afterFilter[type])
          @dataVersion.afterFilter[type]++
          if @dataVersion.afterFilter[type] > 0xFFFFFFFF
            @dataVersion.afterFilter[type] = 0

  getRawDataVersion: (type) ->
    @dataVersion.raw[type]

  getRawData: (type) ->
    @data.raw[type]

  getFilteredDataVersion: (type) ->
    @dataVersion.afterFilter[type]

  getFilteredData: (type) ->
    @data.afterFilter[type]

  setFilterKeys: (type, keys, lazyFlag = false) ->
    if @_checkTypeValid type
      if not _.isEqual @filterKey[type], keys
        @filterKey[type] = keys
        @_applyFilter type, lazyFlag

  getFilterKeys: (type) ->
    Object.clone @filterKey[type]

  _getDataAccordingToNameId: (id, type) ->
    testNum = /^[1-9]+[0-9]*$/
    datalogs = glob.sync(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), type, '*'))
    datalogs = datalogs.map (filePath) ->
      try
        fileContent = fs.readFileSync filePath, 'utf8'
        logs = fileContent.split "\n"
        logs = logs.map (logItem) ->
          logItem = logItem.split ','
          logItem[0] = parseInt logItem[0] if testNum.test(logItem[0])
          logItem
        logs.filter (log) ->
          log.length > 2
      catch e
        consoleWarn "Read and decode file:#{filePath} error!#{e.toString()}"
        return []
    data = []
    for datalog in datalogs
      data = data.concat datalog
    data.reverse()
    data.sort (a, b)->
      if isNaN a[0]
        a[0] = (new Date(a[0])).getTime()
      if isNaN b[0]
        b[0] = (new Date(b[0])).getTime()
      return b[0] - a[0]
    data

  initializeData: (id, lazyFlag) ->
    @nickNameId = id
    for key, type of CONST.typeList
      @data.raw[type] = @_getDataAccordingToNameId @nickNameId, type
      @_fireEvent(type, CONST.eventList.dataChange, lazyFlag)
      @_applyFilter(type)

  addListener: (type, eventType, method) ->
    if not @listeners[type]?
      @listeners[type] = {}
    if not @listeners[type][eventType]?
      @listeners[type][eventType] = []
    @listeners[type][eventType].push method
    method

  removeListener: (type, eventType, method) ->
    if not @listeners[type]?[eventType]?
      return
    index = @listeners[type][eventType].indexOf method
    if index > -1
      @listeners[type][eventType].splice index, 1

  _fireEvent: (type, eventType, lazyFlag = false) ->
    if @listeners[type]?[eventType]
      for method in @listeners[type][eventType]
        method.call(this, lazyFlag)

  saveLog: (type, log, lazyFlag) ->
    if @_checkTypeValid type
      @data.raw[type].unshift log
      fs.ensureDirSync(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), type))
      if type is 'attack'
        date = new Date(log[0])
        year = date.getFullYear()
        month = date.getMonth() + 1
        if month < 10
          month = "0#{month}"
        day = date.getDate()
        if day < 10
          day = "0#{day}"
        fs.appendFile(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), type, "#{year}#{month}#{day}"), "#{log.join(',')}\n", 'utf8', (err)->
          consoleError "Write attack-log file error!" if err)
      else
        fs.appendFile(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), type, "data"), "#{log.join(',')}\n", 'utf8', (err)->
          consoleError "Write #{type}-log file error!" if err)
      consoleLog "save one #{type} log"
      newLogs = @_filterOneLog type, log
      newLogsFlag = newLogs.length isnt 0 and type isnt CONST.typeList.resource
      @_fireEvent type, CONST.eventList.dataChange, newLogsFlag & lazyFlag
      if newLogsFlag
        if @data.raw[type] isnt @data.afterFilter[type]
          @data.afterFilter[type].unshift newLogs[0]
        @_fireEvent type, CONST.eventList.filteredDataChange
    else
      consoleError "saveLog arguments error!"

  _filter: (type, logs) ->
    retData = logs
    filterKey = @filterKey[type]
    for key, index in filterKey
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
          retData = filterReg retData, index, reg
        else
          retData = filterString retData, index, key.toLowerCase().trim()
    retData

  _applyFilter: (type, lazyFlag = false) ->
    if type is typeList.resource
      return
    @data.afterFilter[type] = @_filter type, @data.raw[type]
    @_fireEvent type, CONST.eventList.filteredDataChange, lazyFlag

  _filterOneLog: (type, log) ->
    if type is typeList.resource
      return []
    ret = [log]
    @_filter type, ret

  searchData: (type, index, base, keyword) ->
    changeFlag = false
    if not @searchBuffer[type][base]?
      data = []
      changeFlag = true
    else
      if @searchBuffer[type][base].key[keyword]?
        data = @searchBuffer[type][base].key[keyword]
      else
        data = @_search @searchBuffer[type][base].data, keyword
        @searchBuffer[type][base].key[keyword] = data
        changeFlag = true
    if changeFlag or not @searchBuffer[type][index]?
      @searchBuffer[type][index] = new SearchBuffer(data)
    data

  getSearchDataLength: (type, index) ->
    @searchBuffer[type][index]?.data.length

  _search: (data, keyword) ->
    if keyword is ''
      []
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
      data.filter (log) =>
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
  _checkTypeValid: (type) ->
    flag = false
    for key, value of CONST.typeList
      if value is type
        flag = true
        break
    flag

module.exports = new DataManager()
