"use strict"

log = (msg) ->
  console.log "[Akashic Records][Data Manager] #{msg}" if process.env.DEBUG is 1

typeList = ['attack', 'mission', 'createship', 'createitem', 'resource']

class DataManager
  constructor: ->
    @data = {}
    for type in typeList
      @data[type] = []
    @nickNameId = 0

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
        warn "Read and decode file:#{filePath} error!#{e.toString()}"
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
    log "get #{id}'s #{type} data from file"

  initializeData: (id) ->
    @nickNameId = id
    for type in typeList
      @data[type] = @_getDataAccordingToNameId @nickNameId, type

  
