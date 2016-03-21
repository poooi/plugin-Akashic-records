{React, ReactBootstrap, ROOT, FontAwesome, __, translate, CONST} = window
{Grid, Row, Col, Input, Button, OverlayTrigger, Popover, Input} = ReactBootstrap

fs = require 'fs-extra'
iconv = require 'iconv-lite'

jschardet = require 'jschardet'
jschardet.Constants.MINIMUM_THRESHOLD = 0.10

path = require 'path-extra'

remote = require 'remote'
dialog = remote.require 'dialog'

{openExternal} = require 'shell'

{oriTableTab} = require '../reducers/tab'

dateCmp = (a, b)->
  if isNaN a[0]
    a[0] = (new Date(a[0])).getTime()
  if isNaN b[0]
    b[0] = (new Date(b[0])).getTime()
  b[0] - a[0]

duplicateRemoval = (arr) ->
  arr.sort dateCmp
  @lastTmp = 0
  arr.filter (log) =>
    flag = true
    tmpDate = new Date(log[0])
    tmp = "#{tmpDate.getFullYear()}/#{tmpDate.getMonth()}/#{tmpDate.getDate()}/#{tmpDate.getHours()}/#{tmpDate.getMinutes()}/#{tmpDate.getSeconds()}"
    if tmp is @lastTmp
      flag = false
    else
      @lastTmp = tmp
    flag

duplicateResourceRemoval = (arr) ->
  arr.sort dateCmp
  @lastTmp = 0
  arr.filter (log) =>
    flag = true
    tmpDate = new Date(log[0])
    tmp = "#{tmpDate.getFullYear()}/#{tmpDate.getMonth()}/#{tmpDate.getDate()}/#{tmpDate.getHours()}"
    if tmp is @lastTmp
      flag = false
    else
      @lastTmp = tmp
    flag

toDateLabel = (datetime) ->
  date = new Date(datetime)
  month = date.getMonth()+1
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

translateTableTab = (tableTabEn, locale) ->
  tableTab = {}
  for key, tabs of tableTabEn
    tableTab[key] = tabs.map (tab) ->
      translate locale, tab
  tableTab

resolveFile = (fileContent, tableTabEn)->
  tableTabEn = oriTableTab
  tableTab = {}
  tableTab['en-US'] = Object.clone tableTabEn
  for key in ['ja-JP', 'zh-CN', 'zh-TW']
    tableTab[key] = translateTableTab tableTabEn, key
  for key, tabs of tableTab
    for type, t of tabs
      tableTab[key][type] = t.slice(1).join(',')
  logs = fileContent.split "\n"
  logs[0] = logs[0].trim()
  switch logs[0]
    when tableTab['en-US'][CONST.typeList.attack], \
    tableTab['ja-JP'][CONST.typeList.attack], \
    tableTab['zh-CN'][CONST.typeList.attack], \
    tableTab['zh-TW'][CONST.typeList.attack]
      logType = CONST.typeList.attack
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 12
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 12
    when tableTab['en-US'][CONST.typeList.mission], \
    tableTab['ja-JP'][CONST.typeList.mission], \
    tableTab['zh-CN'][CONST.typeList.mission], \
    tableTab['zh-TW'][CONST.typeList.mission]
      logType = CONST.typeList.mission
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 11
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 11
    when tableTab['en-US'][CONST.typeList.createShip], \
    tableTab['ja-JP'][CONST.typeList.createShip], \
    tableTab['zh-CN'][CONST.typeList.createShip], \
    tableTab['zh-TW'][CONST.typeList.createShip]
      logType = CONST.typeList.createShip
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 12
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 12
    when tableTab['en-US'][CONST.typeList.createItem], \
    tableTab['ja-JP'][CONST.typeList.createItem], \
    tableTab['zh-CN'][CONST.typeList.createItem], \
    tableTab['zh-TW'][CONST.typeList.createItem]
      logType = CONST.typeList.createItem
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 10
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 10
    when tableTab['en-US'][CONST.typeList.retirement], \
    tableTab['ja-JP'][CONST.typeList.retirement], \
    tableTab['zh-CN'][CONST.typeList.retirement], \
    tableTab['zh-TW'][CONST.typeList.retirement]
      logType = CONST.typeList.retirement
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 4
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 4
    when tableTab['en-US'][CONST.typeList.resource], \
    tableTab['ja-JP'][CONST.typeList.resource], \
    tableTab['zh-CN'][CONST.typeList.resource], \
    tableTab['zh-TW'][CONST.typeList.resource]
      logType = CONST.typeList.resource
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 9
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 9

    # 航海日志扩张版
    when "No.,日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)"
      logType = CONST.typeList.attack
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 14
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        tmpArray = logItem[3].match(/:\d+(-\d+)?/g)
        retData.push "#{logItem[2]}(#{tmpArray[0].substring(1)})"
        if logItem[4] is "ボス"
          tmp = "Boss点"
        else
          tmp = "道中"
        retData.push "#{tmpArray[1].substring(1)}(#{tmp})"
        if logItem[4] is "出撃"
          tmp = "出撃"
        else
          tmp = "進撃"
        retData.push tmp
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[8]
        if logItem[9] is ""
          tmp = "无"
        else
          tmp = "有"
        retData.push tmp
        retData.push logItem[10]
        retData.push logItem[11]
        retData.push logItem[12]
        retData.push logItem[13]
        retData
      data = data.filter (log) ->
        log.length is 12
    when "日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)"
      logType = CONST.typeList.attack
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 13
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        tmpArray = logItem[2].match(/:\d+(-\d+)?/g)
        retData.push "#{logItem[1]}(#{tmpArray[0].substring(1)})"
        if logItem[3] is "ボス"
          tmp = "Boss点"
        else
          tmp = "道中"
        retData.push "#{tmpArray[1].substring(1)}(#{tmp})"
        if logItem[3] is "出撃"
          tmp = "出撃"
        else
          tmp = "出撃"
        retData.push tmp
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[7]
        if logItem[8] is ""
          tmp = "无"
        else
          tmp = "有"
        retData.push tmp
        retData.push logItem[9]
        retData.push logItem[10]
        retData.push logItem[11]
        retData.push logItem[12]
        retData
      data = data.filter (log) ->
        log.length is 12
    when "No.,日付,結果,遠征,燃料,弾薬,鋼材,ボーキ,アイテム1,個数,アイテム2,個数"
      logType = CONST.typeList.mission
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 12
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        retData.push logItem[3]
        retData.push logItem[2]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData.push logItem[10]
        retData.push logItem[11]
        retData
      data = data.filter (log) ->
        log.length is 11
    when "日付,結果,遠征,燃料,弾薬,鋼材,ボーキ,アイテム1,個数,アイテム2,個数"
      logType = CONST.typeList.mission
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 11
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        retData.push logItem[2]
        retData.push logItem[1]
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData.push logItem[10]
        retData
      data = data.filter (log) ->
        log.length is 11
    when "No.,日付,種類,名前,艦種,燃料,弾薬,鋼材,ボーキ,開発資材,空きドック,秘書艦,司令部Lv"
      logType = CONST.typeList.createShip
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 13
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        if logItem[2] is "通常艦建造"
          tmp = "普通建造"
        else
          tmp = "大型建造"
        retData.push tmp
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData.push logItem[10]
        retData.push logItem[11]
        retData.push logItem[12]
        retData
      data = data.filter (log) ->
        log.length is 12
    when "日付,種類,名前,艦種,燃料,弾薬,鋼材,ボーキ,開発資材,空きドック,秘書艦,司令部Lv"
      logType = CONST.typeList.createShip
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 12
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        if logItem[1] is "通常艦建造"
          tmp = "普通建造"
        else
          tmp = "大型建造"
        retData.push tmp
        retData.push logItem[2]
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData.push logItem[10]
        retData.push logItem[11]
        retData
      data = data.filter (log) ->
        log.length is 12
    when "No.,日付,開発装備,種別,燃料,弾薬,鋼材,ボーキ,秘書艦,司令部Lv"
      logType = CONST.typeList.createItem
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 10
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        if logItem[2] is "失敗"
          retData.push "失败"
          retData.push ""
          retData.push ""
        else
          retData.push "成功"
          retData.push logItem[2]
          retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData
      data = data.filter (log) ->
        log.length is 10
    when "日付,開発装備,種別,燃料,弾薬,鋼材,ボーキ,秘書艦,司令部Lv"
      logType = CONST.typeList.createItem
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 9
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        if logItem[1] is "失敗"
          retData.push "失败"
          retData.push ""
          retData.push ""
        else
          retData.push "成功"
          retData.push logItem[1]
          retData.push logItem[2]
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData
      data = data.filter (log) ->
        log.length is 10
    when "日付,直前のイベント,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材,改修資材"
      logType = CONST.typeList.resource
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 10 and logItem.length isnt 12
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        retData.push logItem[2]
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[7]
        retData.push logItem[6]
        retData.push logItem[8]
        retData.push logItem[9]
        retData
      data = data.filter (log) ->
        log.length is 9
    when "日付,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材,改修資材"
      logType = CONST.typeList.resource
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 9 and logItem.length isnt 11
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        retData.push logItem[1]
        retData.push logItem[2]
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[6]
        retData.push logItem[5]
        retData.push logItem[7]
        retData.push logItem[8]
        retData
      data = data.filter (log) ->
        log.length is 9
    when "日付,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材"
      logType = CONST.typeList.resource
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 8
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        retData.push logItem[1]
        retData.push logItem[2]
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[6]
        retData.push logItem[5]
        retData.push logItem[7]
        retData.push "0"
        retData
      data = data.filter (log) ->
        log.length is 9

    # KCV yuyuvn版
    when "Date,Result,Operation,Enemy Fleet,Rank"
      logType = CONST.typeList.attack
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 6
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        retData.push logItem[2]
        retData.push ''
        retData.push ''
        retData.push logItem[4]
        retData.push logItem[3]
        retData.push logItem[1]
        retData.push ''
        retData.push ''
        retData.push ''
        retData.push ''
        retData.push ''
        retData
      data = data.filter (log) ->
        log.length is 12
    when "Date,Result,Secretary,Secretary level,Fuel,Ammo,Steel,Bauxite"
      logType = CONST.typeList.createItem
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 9
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        if logItem[1] is "Penguin"
          retData.push "失败"
          retData.push ""
          retData.push ""
        else
          retData.push "成功"
          retData.push logItem[1]
          retData.push ""
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push "#{logItem[2]}(Lv.#{logItem[3]})"
        retData.push ""
        retData
      data = data.filter (log) ->
        log.length is 10
    when "Date,Result,Secretary,Secretary level,Fuel,Ammo,Steel,Bauxite,# of Build Materials"
      logType = CONST.typeList.createShip
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 10
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        if logItem[4] < 1000
          tmp = "普通建造"
        else
          tmp = "大型建造"
        retData.push tmp
        retData.push logItem[1]
        retData.push ''
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push ""
        retData.push "#{logItem[2]}(Lv.#{logItem[3]})"
        retData.push ""
        retData
      data = data.filter (log) ->
        log.length is 12
    when "Date,Fuel,Ammunition,Steel,Bauxite,DevKits,Buckets,Flamethrowers"
      logType = CONST.typeList.resource
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 9
          return []
        retData = []
        retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
        retData.push logItem[1]
        retData.push logItem[2]
        retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[7]
        retData.push logItem[6]
        retData.push logItem[5]
        retData.push "0"
        retData
      data = data.filter (log) ->
        log.length is 9
    else
      e = new Error()
      e.message = __ "The encoding or file is not supported"
      throw e
  ret =
    logType: logType
    data: data
    message: ""

AttackLog = React.createClass
  getInitialState: ->
    typeChoosed: '出击'
    forceMinimize: false
  componentWillMount: ->
    forceMinimize = config.get "plugin.Akashic.forceMinimize", false
    @setState
      forceMinimize: forceMinimize
  handleClickCheckbox: ->
    config.set "plugin.Akashic.forceMinimize", not @state.forceMinimize
    @setState
      forceMinimize: not @state.forceMinimize
  handleSetType: ->
    @setState
      typeChoosed: @refs.type.getValue()
  showMessage: (message)->
    dialog.showMessageBox
      type: 'info'
      buttons: ['OK']
      title: 'Warning'
      message: message
  saveLogHandle: ->
    nickNameId = window._nickNameId
    if nickNameId and nickNameId isnt 0
      switch @state.typeChoosed
        when '出击'
          logType = CONST.typeList.attack
          data = @props.attackData.toArray()
        when '远征'
          logType = CONST.typeList.mission
          data = @props.missionData.toArray()
        when '建造'
          logType = CONST.typeList.createShip
          data = @props.createShipData.toArray()
        when '开发'
          logType = CONST.typeList.createItem
          data = @props.createItemData.toArray()
        when '除籍'
          logType = CONST.typeList.retirement
          data = @props.retirementData.toArray()
        when '资源'
          logType = CONST.typeList.resource
          data = @props.resourceData.toArray()
        else
          @showMessage '发生错误！请报告开发者'
          return
      if process.platform is 'win32'
        if window.language is 'ja-JP'
          codeType = 'shiftjis'
        else if window.language is 'zh-CN' or window.language is 'zh-TW'
          codeType = 'GB2312'
        else
          codeType = 'utf8'
      else
        codeType = 'utf8'
      filename = dialog.showSaveDialog
        title: "保存#{@state.typeChoosed}记录"
        defaultPath: "#{nickNameId}-#{logType}.csv"
      if filename?
        saveTableTab = @props.tableTab[logType].toArray().map (tab) ->
          __ tab
        saveData = "#{saveTableTab.slice(1).join(',')}\n"
        for item in data
          saveData = "#{saveData}#{toDateLabel item[0]},#{item.slice(1).join(',')}\n"
        if codeType is 'GB2312'
          saveData = iconv.encode saveData, 'GB2312'
        fs.writeFile filename, saveData, (err)->
          if err
            console.log "err! Save data error"
    else
      @showMessage '未找到相应的提督！是不是还没登录？'
  importLogHandle: ->
    nickNameId = window._nickNameId
    if nickNameId and nickNameId isnt 0
      filename = dialog.showOpenDialog
        title: "导入#{@state.typeChoosed}记录"
        filters: [
          {
            name: "csv file"
            extensions: ['csv']
          }
        ]
        properties: ['openFile']
      if filename?[0]?
        try
          fs.accessSync(filename[0], fs.R_OK)
          fileContentBuffer = fs.readFileSync filename[0]
          codeType = jschardet.detect(fileContentBuffer).encoding
          switch codeType
            when 'UTF-8'
              fileContent = fileContentBuffer.toString()
            when 'GB2312', 'GB18030', 'GBK'
              fileContent = iconv.decode fileContentBuffer, 'GBK'
            when 'SHIFT_JIS'
              fileContent = iconv.decode fileContentBuffer, 'shiftjis'
            else
              fileContent = iconv.decode fileContentBuffer, 'shiftjis'
          {logType, data} = resolveFile fileContent
          saveType = -1
          switch logType
            when CONST.typeList.attack
              hint = '出击'
              oldData = duplicateRemoval @props.attackData.toArray()
            when CONST.typeList.mission
              hint = '远征'
              oldData = duplicateRemoval @props.missionData.toArray()
            when CONST.typeList.createShip
              hint = '建造'
              oldData = duplicateRemoval @props.createShipData.toArray()
            when CONST.typeList.createItem
              hint = '开发'
              oldData = duplicateRemoval @props.createItemData.toArray()
            when CONST.typeList.retirement
              hint = '除籍'
              oldData = duplicateRemoval @props.retirementData.toArray()
            when CONST.typeList.resource
              hint = '资源'
              oldData = duplicateRemoval @props.resourceData.toArray()
            else
              throw "Type Error!"
          # oldData = duplicateRemoval dataManager.getRawData logType
          oldLength = oldData.length
          newData = oldData.concat data
          if logType is CONST.typeList.resource
            newData = duplicateResourceRemoval newData
          else
            newData = duplicateRemoval newData
          newLength = newData.length
          fs.emptyDirSync path.join(APPDATA_PATH, 'akashic-records', "tmp")
          saveData = ""
          for item in newData
            saveData = "#{saveData}#{item.join(',')}\n"
          fs.writeFile path.join(APPDATA_PATH, 'akashic-records', "tmp", "data"), saveData
          fs.emptyDirSync path.join(APPDATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase())
          fs.writeFile path.join(APPDATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase(), "data"), saveData
          @props.onLogsReset newData, logType
          @showMessage "新导入#{newLength - oldLength}条#{hint}记录！"
        catch e
          @showMessage e.message
          throw e
    else
      @showMessage '请先登录再导入数据！'


    # console.log "import log"

  render: ->
    <div className="advancedmodule">
      <Grid>
        <Row className="title">
          <Col xs={12}>
            <span style={{fontSize: "24px"}}>{__ "Importing/Exporting"}</span>
            <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
              <Popover id="about-message" title={__ "About"}>
                <h5>{__ "Exporting"}</h5>
                <ul>
                  <li>{__ "Choose the data you want to export"}</li>
                  <li>{__ "The file's encoding is determined by the OS. Win -> GB2312, Others -> utf8"}</li>
                </ul>
                <h5>{__ "Importing"}</h5>
                <ul>
                  <li>{__ "Support List"}
                    <ul>
                      <li>阿克夏记录</li>
                      <li>航海日誌 拡張版 (某些版本)</li>
                      <li>KCV-yuyuvn</li>
                    </ul>
                  </li>
                </ul>
                <h5>{__ "Need more?"}</h5>
                <ul>
                  <li>
                    <a onClick={openExternal.bind(this, "https://github.com/poooi/plugin-Akashic-records/issues/new")}>{__ "open a new issue on github"}</a>
                  </li>
                  <li style={"whiteSpace": "nowrap"}>{__ "or email"} jenningswu@gmail.com </li>
                </ul>
              </Popover>
              }>
              <Button id='question-btn' bsStyle='default' bsSize='large'>
                <FontAwesome name='question-circle' className="fa-fw" />
              </Button>
            </OverlayTrigger>
          </Col>
        </Row>
        <Row>
          <Col xs={4}>
            <Input type="select" ref="type" value={@state.typeChoosed} onChange={@handleSetType}>
              <option key={0} value={'出击'}>{__ "Sortie"}</option>
              <option key={1} value={'远征'}>{__ "Expedition"}</option>
              <option key={2} value={'建造'}>{__ "Construction"}</option>
              <option key={3} value={'开发'}>{__ "Development"}</option>
              <option key={4} value={'除籍'}>{__ "Retirement"}</option>
              <option key={5} value={'资源'}>{__ "Resource"}</option>
            </Input>
          </Col>
          <Col xs={4}>
             <Button bsStyle='primary' style={width: '100%'} onClick={@saveLogHandle}>{__ "Export"}</Button>
          </Col>
          <Col xs={4}>
             <Button bsStyle='primary' style={width: '100%'} onClick={@importLogHandle}>{__ "Import"}</Button>
          </Col>
        </Row>
        <Row style={marginTop:"10px"}>
          <Col xs={12}>
            <a style={marginLeft: "30px"} onClick={openExternal.bind(this, "https://github.com/yudachi/plugin-Akashic-records")}>{__ "Bug Report & Suggestion"}</a>
          </Col>
        </Row>
      </Grid>
    </div>


module.exports = AttackLog
