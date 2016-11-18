"use strict"

import fs from 'fs-extra'
import glob from 'glob'
import path from 'path-extra'

{APPDATA_PATH, CONST, config} = window

DATA_PATH = config.get "plugin.Akashic.dataPath", APPDATA_PATH

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
  console.log "[Akashic Records][Data CoManager] #{msg}" if process.env.DEBUG?

consoleWarn = (msg) ->
  console.warn "[Akashic Records][Data CoManager] #{msg}" if process.env.DEBUG?

consoleError = (msg) ->
  console.error "[Akashic Records][Data CoManager] #{msg}" if process.env.DEBUG?

typeList = CONST.typeList
eventList = CONST.eventList

RAW_DATA_INDEX = CONST.search.rawDataIndex
FILTER_DATA_INDEX = CONST.search.filteredDataIndex
INDEX_BASE = CONST.search.indexBase

class DataCoManager
  constructor: ->
    @nickNameId = 0

  _getDataAccordingToNameId: (id, type) ->
    testNum = /^[1-9]+[0-9]*$/
    datalogs = glob.sync(path.join(DATA_PATH, 'akashic-records', @nickNameId.toString(), type, '*'))
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

  initializeData: (id) ->
    @nickNameId = id
    data = []
    for key, type of CONST.typeList
      data[type] = @_getDataAccordingToNameId @nickNameId, type
    data

  saveLog: (type, log) ->
    fs.ensureDirSync(path.join(DATA_PATH, 'akashic-records', @nickNameId.toString(), type))
    if type is 'attack'
      date = new Date(log[0])
      year = date.getFullYear()
      month = date.getMonth() + 1
      if month < 10
        month = "0#{month}"
      day = date.getDate()
      if day < 10
        day = "0#{day}"
      fs.appendFile(path.join(DATA_PATH, 'akashic-records', @nickNameId.toString(), type, "#{year}#{month}#{day}"), "#{log.join(',')}\n", 'utf8', (err)->
        consoleError "Write attack-log file error!" if err)
    else
      fs.appendFile(path.join(DATA_PATH, 'akashic-records', @nickNameId.toString(), type, "data"), "#{log.join(',')}\n", 'utf8', (err)->
        consoleError "Write #{type}-log file error!" if err)
    consoleLog "save one #{type} log"

module.exports = new DataCoManager()
