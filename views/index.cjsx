fs = require 'fs-extra'
glob = require 'glob'
{React, ReactDOM, ReactBootstrap, $, ROOT, APPDATA_PATH, __, translate} = window
{Tabs, Tab, Label} = ReactBootstrap
path = require 'path-extra'
{log, warn, error} = require path.join(ROOT, 'lib/utils')
# AkashicRecordTab = require './item-info-table-area'
# AkashicRecordContent = require './item-info-checkbox-area'
AkashicLog = require './akashic-records-log'
AkashicResourceLog = require './akashic-resource-log'
AkashicAdvancedModule = require './akashic-advanced-module'

$('#font-awesome')?.setAttribute 'href', "#{ROOT}/components/font-awesome/css/font-awesome.min.css"

judgeIfDemage = (nowHp, beforeHp) ->
  DemageFlag = false
  for hp, i in nowHp
    if hp < beforeHp[i]
      notDemageFlag = true
  notDemageFlag

judgeDanger = (nowHp, deckShipId, _ships) ->
  dangerInfo = ""
  dangerFlag = false
  for id, i in deckShipId
    if id is -1
      continue
    if nowHp[i] / _ships[id].api_maxhp < 0.250001
      if dangerFlag
        dangerInfo = "#{dangerInfo} & "
      dangerInfo = "#{dangerInfo}#{_ships[id].api_name}"
      dangerFlag = true
  console.log "战斗结束后剩余HP：#{JSON.stringify nowHp}" if process.env.DEBUG?
  if dangerFlag
    dangerInfo
  else
    "无"

timeToBString = (time) ->
  date = new Date(time)
  "#{date.getFullYear()}#{date.getMonth()}#{date.getDate()}#{date.getHours()}"

attackTableTabEn = ['No.', 'Time', 'World', "Node", "Sortie Type",
                  "Battle Result", "Enemy Encounters", "Drop",
                  "Heavily Damaged", "Flagship",
                  "Flagship (Second Fleet)", 'MVP',
                  "MVP (Second Fleet)"]
missionTableTabEn = ['No.', "Time", "Type", "Result", "Fuel",
                  "Ammo", "Steel", "Bauxite", "Item 1",
                   "Number", "Item 2", "Number"]
createItemTableTabEn = ['No.', "Time", "Result", "Development Item",
                      "Type", "Fuel", "Ammo", "Steel",
                      "Bauxite", "Flagship", "Headquarters Level"]
createShipTableTabEn = ['No.', "Time", "Type", "Ship", "Ship Type",
                      "Fuel", "Ammo", "Steel", "Bauxite",
                       "Development Material", "Empty Docks", "Flagship",
                       "Headquarters Level"]
resourceTableTabEn = ['No.', "Time", "Fuel", "Ammo", "Steel",
                    "Bauxite", "Fast Build Item", "Instant Repair Item",
                     "Development Material", "Improvement Materials"]

attackTableTab = attackTableTabEn.map (tab) ->
  __(tab)

missionTableTab = missionTableTabEn.map (tab) ->
  __(tab)

createItemTableTab =createItemTableTabEn.map (tab) ->
  __(tab)

createShipTableTab = createShipTableTabEn.map (tab) ->
  __(tab)

resourceTableTab = resourceTableTabEn.map (tab) ->
  __(tab)


# getUseItem: (id)->
#   switch id
#     when 10
#       "家具箱（小）"
#     when 11
#       "家具箱（中）"
#     when 12
#       "家具箱（大）"
#     when 50
#       "応急修理要員"
#     when 51
#       "応急修理女神"
#     when 54
#       "給糧艦「間宮」"
#     when 56
#       "艦娘からのチョコ"
#     when 57
#       "勲章"
#     when 59
#       "給糧艦「伊良湖」"
#     when 62
#       "菱餅"
#     else
#       "特殊的东西"

AkashicRecordsArea = React.createClass
  getInitialState: ->
    attackData: []
    missionData: []
    createItemData: []
    createShipData: []
    resourceData: []
    mapShowFlag: false
    selectedKey: 0
    dataVersion: [0, 0, 0, 0, 0]
    memberId: 0
    warning: ''
  nowDate: 0
  enableRecord: false
  nickNameId: 0
  isStart: true
  _deck: []
  _ships: []
  $useitems: []
  $ships: []
  $shiptypes: []
  $slotitems: []
  timeString: ""
  mapLv: []

  # 建造
  createShipFlag: false   #注意！之后要用config处理关于建造中正好猫了导致log数据遗失的问题！
  largeFlag: false
  material: []
  kdockId: 0
  getDataAccordingToNameId: (id, type) ->
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
  getLogFromFile: (id, type) ->
    switch type
      when 0
        {attackData, dataVersion} = @state
        attackData = @getDataAccordingToNameId id, "attack"
        console.log "get attackData from file" if process.env.DEBUG?
        dataVersion[type] += 1
        @setState
          attackData: attackData
          dataVersion: dataVersion
      when 1
        {missionData, dataVersion} = @state
        missionData = @getDataAccordingToNameId id, "mission"
        console.log "get missionData from file" if process.env.DEBUG?
        dataVersion[type] += 1
        @setState
          missionData: missionData
          dataVersion: dataVersion
      when 2
        {createItemData, dataVersion} = @state
        createItemData = @getDataAccordingToNameId id, "createitem"
        console.log "get createItemData from file" if process.env.DEBUG?
        dataVersion[type] += 1
        @setState
          createItemData: createItemData
          dataVersion: dataVersion
      when 3
        {createShipData, dataVersion} = @state
        createShipData = @getDataAccordingToNameId id, "createship"
        console.log "get createShipData from file" if process.env.DEBUG?
        dataVersion[type] += 1
        @setState
          createShipData: createShipData
          dataVersion: dataVersion
      when 4
        {resourceData, dataVersion} = @state
        resourceData = @getDataAccordingToNameId id, "resource"
        console.log "get resourceData from file" if process.env.DEBUG?
        dataVersion[type] += 1
        if resourceData.length > 0
          @timeString = timeToBString resourceData[0][0]
        else
          @timeString = ""
        @setState
          resourceData: resourceData
          dataVersion: dataVersion
  getAttackData: (id) ->
    @getLogFromFile id, 0
  getMissionData: (id) ->
    @getLogFromFile id, 1
  getCreateItemData: (id) ->
    @getLogFromFile id, 2
  getCreateShipData: (id) ->
    @getLogFromFile id, 3
  getResourceData: (id) ->
    @getLogFromFile id, 4

  setDataHandler: (type, data) ->
    {dataVersion} = @state
    if type isnt -1
      dataVersion[type] += 1
    dataVersion: dataVersion
    switch type
      when 0
        @setState
          attackData: data
      when 1
        @setState
          missionData: data
      when 2
        @setState
          createItemData: data
      when 3
        @setState
          createShipData: data
      when 4
        @setState
          resourceData: data

  saveLog: (type, log) ->
    fs.ensureDirSync(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), type))
    if type is "attack"
      date = new Date(log[0])
      year = date.getFullYear()
      month = date.getMonth() + 1
      if month < 10
        month = "0#{month}"
      day = date.getDate()
      if day < 10
        day = "0#{day}"
      fs.appendFile(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), type, "#{year}#{month}#{day}"), "#{log.join(',')}\n", 'utf8', (err)->
        error "Write attack-log file error!" if err)
    else
      fs.appendFile(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), type, "data"), "#{log.join(',')}\n", 'utf8', (err)->
        error "Write #{type}-log file error!" if err)
  saveAttackLog: (alog) ->
    console.log "save one Attack-log" if process.env.DEBUG?
    @saveLog "attack", alog
  saveMissionLog: (alog) ->
    console.log "save one Mission-log" if process.env.DEBUG?
    @saveLog "mission", alog
  saveCreateItemLog: (alog) ->
    console.log "save one CreateItem-log" if process.env.DEBUG?
    @saveLog "createitem", alog
  saveCreateShipLog: (alog) ->
    console.log "save one CreateShip-log" if process.env.DEBUG?
    @saveLog "createship", alog
  saveResourceLog: (alog) ->
    console.log "save one Resource-log" if process.env.DEBUG?
    @saveLog "resource", alog
  handleResponse: (e) ->
    {method, body, postBody} = e.detail
    urlpath = e.detail.path
    switch urlpath
      when '/kcsapi/api_get_member/basic'
        if @nickNameId isnt window._nickNameId
          @nickNameId = window._nickNameId
          if @nickNameId isnt 0 or not @nickNameId?
            config.set 'plugin.Akashic.nickNameId', @nickNameId
            @getAttackData @nickNameId
            @getMissionData @nickNameId
            @getCreateItemData @nickNameId
            @getCreateShipData @nickNameId
            @getResourceData @nickNameId
        @setState
          memberId: body.api_member_id
      # Map selected rank
      when '/kcsapi/api_get_member/mapinfo'
        for map in body
          @mapLv[map.api_id] = 0
          if map.api_eventmap?
            @mapLv[map.api_id] = map.api_eventmap.api_selected_rank
      # Eventmap select report
      when '/kcsapi/api_req_map/select_eventmap_rank'
        @mapLv[parseInt(postBody.api_maparea_id) * 10 + parseInt(postBody.api_map_no)] = parseInt(postBody.api_rank)
      when '/kcsapi/api_req_map/start'
        @_ships = window._ships
        @isStart = true
      when '/kcsapi/api_req_map/next', \
      '/kcsapi/api_req_sortie/battle', \
      '/kcsapi/api_req_battle_midnight/sp_midnight', \
      '/kcsapi/api_req_sortie/airbattle', \
      '/kcsapi/api_req_battle_midnight/battle', \
      '/kcsapi/api_req_combined_battle/airbattle', \
      '/kcsapi/api_req_combined_battle/battle', \
      '/kcsapi/api_req_combined_battle/midnight_battle', \
      '/kcsapi/api_req_combined_battle/sp_midnight', \
      '/kcsapi/api_req_combined_battle/battle_water'
        @_ships = window._ships
        @nowDate = new Date().getTime()

      # 远征
      when '/kcsapi/api_req_mission/result'
        if not @enableRecord
          break
        {$useitems} = window
        dataItem = []
        nowDate = new Date()
        dataItem.push nowDate.getTime()
        dataItem.push body.api_quest_name
        switch body.api_clear_result
          when 0
            dataItem.push "失敗"
          when 1
            dataItem.push "成功"
          when 2
            dataItem.push "大成功"
          else
            dataItem.push "奇怪的结果"
        if body.api_clear_result is 0
          dataItem.push 0, 0, 0, 0
        else
          dataItem.push body.api_get_material[0]
          dataItem.push body.api_get_material[1]
          dataItem.push body.api_get_material[2]
          dataItem.push body.api_get_material[3]
        useItemFlag = body.api_useitem_flag
        if useItemFlag[0] > 0
          if body.api_get_item1.api_useitem_id <= 0
            useItemId = useItemFlag[0]
          else
            useItemId = body.api_get_item1.api_useitem_id;
          dataItem.push $useitems[useItemId].api_name
          dataItem.push body.api_get_item1.api_useitem_count
        else
          dataItem.push "", ""
        if useItemFlag[1] > 0
          if body.api_get_item2.api_useitem_id <= 0
            useItemId = useItemFlag[1]
          else
            useItemId = body.api_get_item2.api_useitem_id;
          dataItem.push $useitems[useItemId].api_name
          dataItem.push body.api_get_item2.api_useitem_count
        else
          dataItem.push "", ""
        {missionData} = @state
        missionData.unshift dataItem
        @saveMissionLog dataItem
        {dataVersion} = @state
        dataVersion[1] += 1
        @setState
          missionData: missionData
          dataVersion: dataVersion

      # 开发
      when '/kcsapi/api_req_kousyou/createitem'
        if not @enableRecord
          break
        {$slotitems, $slotitemTypes} = window
        dataItem = []
        nowDate = new Date()
        dataItem.push nowDate.getTime()
        if body.api_create_flag is 0
          dataItem.push "失敗"
          itemId = parseInt(body.api_fdata.split(",")[1])
          dataItem.push $slotitems[itemId].api_name
          dataItem.push $slotitemTypes[$slotitems[itemId].api_type[2]].api_name
        else
          dataItem.push "成功"
          dataItem.push $slotitems[body.api_slot_item.api_slotitem_id].api_name
          dataItem.push $slotitemTypes[body.api_type3].api_name
        dataItem.push postBody.api_item1, postBody.api_item2, postBody.api_item3, postBody.api_item4
        @_ships = window._ships
        @_decks = window._decks
        dataItem.push "#{@_ships[@_decks[0].api_ship[0]].api_name}(Lv.#{@_ships[@_decks[0].api_ship[0]].api_lv})"
        dataItem.push window._teitokuLv
        {createItemData} = @state
        createItemData.unshift dataItem
        @saveCreateItemLog dataItem
        {dataVersion} = @state
        dataVersion[2] += 1
        @setState
          createItemData: createItemData
          dataVersion: dataVersion

      # 建造
      when '/kcsapi/api_req_kousyou/createship'
        if not @enableRecord
          break
        if body.api_result is 1
          @largeFlag = (postBody.api_large_flag is "1")
          @material = [parseInt(postBody.api_item1), parseInt(postBody.api_item2), parseInt(postBody.api_item3), parseInt(postBody.api_item4), parseInt(postBody.api_item5)]
          @kdockId = parseInt(postBody.api_kdock_id)
          @createShipFlag = true
      when '/kcsapi/api_get_member/kdock'
        if @createShipFlag and @enableRecord
          @_ships = window._ships
          @_decks = window._decks
          @$ships = window.$ships
          @$shiptypes = window.$shipTypes
          apiData = body[@kdockId-1]
          dataItem = []
          nowDate = new Date()
          dataItem.push nowDate.getTime()
          if @largeFlag
            dataItem.push "大型建造"
          else
            dataItem.push "普通建造"
          dataItem.push @$ships[apiData.api_created_ship_id].api_name
          dataItem.push @$shiptypes[@$ships[apiData.api_created_ship_id].api_stype].api_name
          dataItem = dataItem.concat @material
          remainNum = 0
          for kdock in body
            if kdock.api_state is 0
              remainNum = remainNum + 1
          dataItem.push remainNum
          dataItem.push "#{@_ships[@_decks[0].api_ship[0]].api_name}(Lv.#{@_ships[@_decks[0].api_ship[0]].api_lv})"
          dataItem.push window._teitokuLv
          {createShipData} = @state
          createShipData.unshift dataItem
          @saveCreateShipLog dataItem
          {dataVersion} = @state
          dataVersion[3] += 1
          @setState
            createShipData: createShipData
            dataVersion: dataVersion
          @createShipFlag = false

      # 资源
      when '/kcsapi/api_port/port'
        @enableRecord = true
        dataItem = []
        nowDate = new Date()
        @deckCombinedFlag = body.api_combined_flag
        if @timeString isnt timeToBString(nowDate.getTime())
          @timeString = timeToBString(nowDate.getTime())
          dataItem = []
          dataItem.push nowDate.getTime()
          dataItem.push item.api_value for item in body.api_material
          {resourceData} = @state
          resourceData.unshift dataItem
          @saveResourceLog dataItem
          {dataVersion} = @state
          dataVersion[4] += 1
          @setState
            resourceData: resourceData
            dataVersion: dataVersion

  handleBattleResultResponse: (e) ->
    {map, quest, boss, mapCell, rank, deckHp, deckShipId, enemy, dropItem, dropShipId, combined, mvp} = e.detail
    if not @enableRecord
      return
    if not combined?
      @setState
        warning: "Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release."
      return
    dataItem = []
    dataItem.push @nowDate
    switch @mapLv[map]
      when 0
        selectedRank = ""
      when 1
        selectedRank = " 丙"
      when 2
        selectedRank = " 乙"
      when 3
        selectedRank = " 甲"
      else
        selectedRank = ""
    dataItem.push "#{quest}(#{map // 10}-#{map % 10}#{selectedRank})"
    if boss
      dataItem.push "#{mapCell}(Boss点)"
    else dataItem.push "#{mapCell}(道中)"
    if @isStart
      dataItem.push "出撃"
    else dataItem.push "進撃"
    @isStart = false
    beforeHp = deckShipId.map (id) =>
      if id isnt -1
        @_ships[id].api_nowhp
      else
        -1
    switch rank
      when 'S'
        # need fix
        if judgeIfDemage deckHp, beforeHp
          dataItem.push '勝利S'
        else dataItem.push '完全勝利!!!S'
      when 'A'
        dataItem.push '勝利A'
      when 'B'
        dataItem.push '戦術的勝利B'
      when 'C'
        dataItem.push '戦術的敗北C'
      when 'D'
        dataItem.push '敗北D'
      when 'E'
        dataItem.push '敗北E'
      else
        dataItem.push "奇怪的战果？#{rank}"
    dataItem.push enemy

    if dropShipId isnt -1
      dropData = window.$ships[dropShipId].api_name
    else
      dropData = ""
    if window.$useitems[dropItem?.api_useitem_id]?.api_name
      if dropData isnt ""
        dropData = "#{dropData} & "
      dropData = "#{dropData}#{window.$useitems[dropItem?.api_useitem_id]?.api_name}"
    dataItem.push dropData
    dataItem.push judgeDanger deckHp, deckShipId, @_ships
    tmp = ['', '', '', '']
    tmp[0] = "#{@_ships[deckShipId[0]].api_name}(Lv.#{@_ships[deckShipId[0]].api_lv})"
    tmp[2] = "#{@_ships[deckShipId[mvp[0]]].api_name}(Lv.#{@_ships[deckShipId[mvp[0]]].api_lv})"
    if combined
      tmp[1] = "#{@_ships[deckShipId[6]].api_name}(Lv.#{@_ships[deckShipId[6]].api_lv})"
      tmp[3] = "#{@_ships[deckShipId[6 + mvp[1]]].api_name}(Lv.#{@_ships[deckShipId[6 + mvp[1]]].api_lv})"
    dataItem = dataItem.concat tmp
    {attackData} = @state
    attackData.unshift dataItem
    # log "save and show new data"
    @saveAttackLog dataItem
    {dataVersion} = @state
    dataVersion[0] += 1
    @setState
      attackData: attackData
      dataVersion: dataVersion

  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
    window.addEventListener 'battle.result', @handleBattleResultResponse
  componentWillMount: ->
    @nickNameId = window._nickNameId
    if @nickNameId is 0 or not @nickNameId?
      @nickNameId = config.get 'plugin.Akashic.nickNameId', 0
    if @nickNameId isnt 0
      @getAttackData @nickNameId
      @getMissionData @nickNameId
      @getCreateItemData @nickNameId
      @getCreateShipData @nickNameId
      @getResourceData @nickNameId

  handleSelectTab: (selectedKey)->
    if selectedKey is 4
      @setState
        mapShowFlag: true
        selectedKey: selectedKey
    else
      @setState
        mapShowFlag: false
        selectedKey: selectedKey

  render: ->
    <div>
      <div  style={'fontSize': 18}>
        <Label bsStyle="danger">{@state.warning}</Label>
      </div>
      <Tabs activeKey={@state.selectedKey} animation={false} onSelect={@handleSelectTab}>
        <Tab eventKey={0} title={__ "Sortie"} ><AkashicLog indexKey={0} selectedKey={@state.selectedKey} data={@state.attackData} dataVersion={@state.dataVersion[0]} tableTab={attackTableTab} contentType={'attack'}/></Tab>
        <Tab eventKey={1} title={__ "Expedition"} ><AkashicLog indexKey={1} selectedKey={@state.selectedKey} data={@state.missionData} dataVersion={@state.dataVersion[1]} tableTab={missionTableTab} contentType={'mission'}/></Tab>
        <Tab eventKey={2} title={__ "Construction"} ><AkashicLog indexKey={2} selectedKey={@state.selectedKey} data={@state.createShipData} dataVersion={@state.dataVersion[3]} tableTab={createShipTableTab} contentType={'createShip'}/></Tab>
        <Tab eventKey={3} title={__ "Development"} ><AkashicLog indexKey={3} selectedKey={@state.selectedKey} data={@state.createItemData} dataVersion={@state.dataVersion[2]} tableTab={createItemTableTab} contentType={'createItem'}/></Tab>
        <Tab eventKey={4} title={__ "Resource"} ><AkashicResourceLog indexKey={4} selectedKey={@state.selectedKey} data={@state.resourceData} dataVersion={@state.dataVersion[4]} tableTab={resourceTableTab} mapShowFlag={@state.mapShowFlag} contentType={'resource'}/></Tab>
        <Tab eventKey={5} title={__ "Others"} >
          <AkashicAdvancedModule
            tableTab={
              'attack': attackTableTabEn
              'mission': missionTableTabEn
              'createItem': createItemTableTabEn
              'createShip': createShipTableTabEn
              'resource': resourceTableTabEn
            }
            attackData={@state.attackData}
            missionData={@state.missionData}
            createItemData={@state.createItemData}
            createShipData={@state.createShipData}
            resourceData={@state.resourceData}
            setDataHandler={@setDataHandler}/>
        </Tab>
      </Tabs>
    </div>

ReactDOM.render <AkashicRecordsArea />, $('akashic-records')
