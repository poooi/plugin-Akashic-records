fs = require 'fs-extra'
glob = require 'glob'
{React, ReactBootstrap, $, ROOT, APPDATA_PATH} = window
{TabbedArea, TabPane} = ReactBootstrap

path = require 'path-extra'

{log, warn, error} = require path.join(ROOT, 'lib/utils')
# AkashicRecordTab = require './item-info-table-area'
# AkashicRecordContent = require './item-info-checkbox-area'
AkashicLog = require './akashic-records-log'
AkashicResourceLog = require './akashic-resource-log'
AkashicAdvancedModule = require './akashic-advanced-module'
AkashicSenkaLog = require './akashic-senka-log'

getHp = (maxHps, nowHps)->
  maxHp = []
  nowHp = []
  for tmp, i in maxHps[1..6]
    maxHp.push tmp
    nowHp.push nowHps[i+1]
  [maxHp, nowHp]

koukuAttack = (afterHp, kouku) ->
  if kouku.api_fdam?
    for damage, i in kouku.api_fdam
      damage = Math.floor(damage)
      continue if damage <= 0
      afterHp[i - 1] -= damage
  afterHp

openAttack = (afterHp, openingAttack) ->
  if openingAttack.api_fdam?
    for damage, i in openingAttack.api_fdam
      damage = Math.floor(damage)
      continue if damage <= 0
      afterHp[i - 1] -= damage
  afterHp

hougekiAttack = (afterHp, hougeki) ->
  for damageFrom, i in hougeki.api_at_list
    continue if damageFrom == -1
    for damage, j in hougeki.api_damage[i]
      damage = Math.floor(damage)
      damageTo = hougeki.api_df_list[i][j]
      continue if damage <= 0 or damageTo >= 7
      afterHp[damageTo - 1] -= damage
  afterHp

raigekiAttack = (afterHp, raigeki) ->
  if raigeki.api_fdam?
    for damage, i in raigeki.api_fdam
      damage = Math.floor(damage)
      continue if damage <= 0
      afterHp[i - 1] -= damage
  afterHp

judgeFace = (nowHp, afterHp) ->
  notDemageFlag = true
  for hp, i in nowHp
    if afterHp < nowHp
      notDemageFlag = false
  notDemageFlag

judgeDanger = (afterHp, maxHp, _deck, _ships) ->
  dangerFlag = false
  dangerInfo = ""
  for hp, i in afterHp
    if hp / maxHp[i] < 0.250001
      if dangerFlag
        dangerInfo = "#{dangerInfo} & "
      dangerInfo = "#{dangerInfo}#{_ships[_deck.api_ship[i]].api_name}"
      dangerFlag = true
  console.log "战斗结束后剩余HP：#{JSON.stringify afterHp}" if process.env.DEBUG?
  [dangerFlag, dangerInfo]

timeToBString = (time) ->
  date = new Date(time)
  "#{date.getFullYear()}#{date.getMonth()}#{date.getDate()}#{date.getHours()}"

senkaDateToString = ->
  date = new Date()
  year = date.getFullYear()
  month = date.getMonth() + 1
  if month < 10
    month = "0#{month}"
  day = date.getDate()
  if day < 10
    day = "0#{day}"
  hour = date.getHours()
  if hour in [2..13]
    time = "02"
  else if hour in [14..23]
    time = "14"
  else
    day = day - 1
    time = "14"
  "#{year}#{month}#{day}#{time}"

attackTableTab = ['No.', '时间', '海域', '地图点', '状态', '战况', '敌舰队',
    '捞！', '大破舰', '旗舰', '旗舰（第二舰队）', 'MVP', 'MVP(第二舰队）']
missionTableTab = ['No.', '时间', '类型', '结果', '燃', '弹', '钢', '铝',
    '获得物品1', '数量', '获得物品2', '数量']
createItemTableTab = ['No.', '时间', '结果', '开发装备', '类别',
    '燃', '弹', '钢', '铝', '秘书舰', '司令部Lv']
createShipTableTab = ['No.', '时间', '种类', '船只', '舰种',
    '燃', '弹', '钢', '铝', '资材', '空渠数', '秘书舰', '司令部Lv']

resourceTableTab = ['No.', '时间', '燃料', '弹药', '钢材', '铝材',
  '高速建造', '高速修复', '开发资材', '改修螺丝']

senkaTableTab = ['顺位', 'Lv.', '提督名', '阶级', '时段累计经验', '战果', '勋章']

getUseItem: (id)->
  switch id
    when 10
      "家具箱（小）"
    when 11
      "家具箱（中）"
    when 12
      "家具箱（大）"
    when 50
      "応急修理要員"
    when 51
      "応急修理女神"
    when 54
      "給糧艦「間宮」"
    when 56
      "艦娘からのチョコ"
    when 57
      "勲章"
    when 59
      "給糧艦「伊良湖」"
    when 62
      "菱餅"
    else
      "特殊的东西"

AkashicRecordsArea = React.createClass
  getInitialState: ->
    attackData: []
    missionData: []
    createItemData: []
    createShipData: []
    resourceData: []
    mapShowFlag: false
    downloadFlag: false
    selectedKey: 0
    dataVersion: [0, 0, 0, 0, 0]
  nickNameId: 0
  memberId: 0
  serverId: 0
  mapAreaId: 0
  mapInfoNo: 0
  apiNo: 0
  BosscellNo: -1
  colorNo: 0
  dangerousShip: null
  flagShip: ['', '']
  isStart: true
  notDemageFlag: true
  _decks: []
  _deck: []
  _ships: []
  $useitems: []
  $ships: []
  $shiptypes: []
  $slotitems: []
  timeString: ""

  # 建造
  createShipFlag: false   #注意！之后要用config处理关于建造中正好猫了导致log数据遗失的问题！
  largeFlag: false
  material: []
  kdockId: 0
  getDataAccordingToNameId: (id, type) ->
    testNum = /^[1-9]+[0-9]*$/
    if type == "senkaList"
      serverId = config.get "plugin.Akashic.senka.serverId", 0
      if serverId > 0
        time = senkaDateToString()
        datalogs = glob.sync(path.join(APPDATA_PATH, 'akashic-records', id.toString(), type, "#{serverId}", '500', time))
        if datalogs.length isnt 0
          return @setState downloadFlag: false
        else
          return @setState downloadFlag: true
      else
        return @setState downloadFlag: false
    else
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
          a[0] = (Date(a[0])).getTime()
        if isNaN b[0]
          b[0] = (Date(b[0])).getTime()
        return b[0] - a[0]
  getLogFromFile: (id, type) ->
    switch type
      when 0
        {attackData, dataVersion} = @state
        attackData = @getDataAccordingToNameId id, "attack"
        console.log "get attackData from file" if process.env.DEBUG?
        dataVersion[0] += 1
        @setState
          attackData: attackData
          dataVersion: dataVersion
      when 1
        {missionData, dataVersion} = @state
        missionData = @getDataAccordingToNameId id, "mission"
        console.log "get missionData from file" if process.env.DEBUG?
        dataVersion[1] += 1
        @setState
          missionData: missionData
          dataVersion: dataVersion
      when 2
        {createItemData, dataVersion} = @state
        createItemData = @getDataAccordingToNameId id, "createitem"
        console.log "get createItemData from file" if process.env.DEBUG?
        dataVersion[2] += 1
        @setState
          createItemData: createItemData
          dataVersion: dataVersion
      when 3
        {createShipData, dataVersion} = @state
        createShipData = @getDataAccordingToNameId id, "createship"
        console.log "get createShipData from file" if process.env.DEBUG?
        dataVersion[3] += 1
        @setState
          createShipData: createShipData
          dataVersion: dataVersion
      when 4
        {resourceData, dataVersion} = @state
        resourceData = @getDataAccordingToNameId id, "resource"
        log "get resourceData from file" if process.env.DEBUG?
        dataVersion[4] += 1
        if resourceData.length > 0
          @timeString = timeToBString resourceData[0][0]
        @setState
          resourceData: resourceData
          dataVersion: dataVersion
      when 5
        {senkaData} = @state
        senkaData = @getDataAccordingToNameId id, "senkaList"
        log "check senkaData from file"
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
  checkSenkaData: (id) ->
    @getLogFromFile id, 5

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
    log "save one Attack-log"
    @saveLog "attack", alog
  saveMissionLog: (alog) ->
    log "save one Mission-log"
    @saveLog "mission", alog
  saveCreateItemLog: (alog) ->
    log "save one CreateItem-log"
    @saveLog "createitem", alog
  saveCreateShipLog: (alog) ->
    log "save one CreateShip-log"
    @saveLog "createship", alog
  saveResourceLog: (alog) ->
    log "save one Resource-log"
    @saveLog "resource", alog
  handleResponse: (e) ->
    {method, body, postBody} = e.detail
    urlpath = e.detail.path
    switch urlpath
      when '/kcsapi/api_get_member/basic'
        @nickNameId = window._nickNameId
        @getAttackData @nickNameId
        @getMissionData @nickNameId
        @getCreateItemData @nickNameId
        @getCreateShipData @nickNameId
        @getResourceData @nickNameId
        @checkSenkaData body.api_member_id
        @setState
          memberId: body.api_member_id
      when '/kcsapi/api_req_map/start'
        [@mapAreaId, @mapInfoNo, @apiNo, @BosscellNo, @colorNo] = [body.api_maparea_id, body.api_mapinfo_no, body.api_no, body.api_bosscell_no, body.api_color_no]
        @_deck = window._decks[postBody.api_deck_id-1]
        @_ships = window._ships
        @isStart = true
        @dangerousShip = '无'
        @notDemageFlag = true
      when '/kcsapi/api_req_map/next'
        @_ships = window._ships
        @_decks = window._decks
        [@mapAreaId, @mapInfoNo, @apiNo, @BosscellNo, @colorNo] = [body.api_maparea_id, body.api_mapinfo_no, body.api_no, body.api_bosscell_no, body.api_color_no]
        @dangerousShip = '无'
        @notDemageFlag = true
      when '/kcsapi/api_req_sortie/battle'
        @_ships = window._ships
        @_decks = window._decks
        [maxHp, nowHp] = getHp body.api_maxhps, body.api_nowhps
        afterHp = Object.clone nowHp
        if body.api_kouku.api_stage3?
          afterHp = koukuAttack afterHp, body.api_kouku.api_stage3
        if body.api_opening_atack?
          afterHp = openAttack afterHp, body.api_opening_atack
        if body.api_hougeki1?
          afterHp = hougekiAttack afterHp, body.api_hougeki1
        if body.api_hougeki2?
          afterHp = hougekiAttack afterHp, body.api_hougeki2
        if body.api_hougeki3?
          afterHp = hougekiAttack afterHp, body.api_hougeki3
        if body.api_raigeki?
          afterHp = raigekiAttack afterHp, body.api_raigeki
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ships
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp
      when '/kcsapi/api_req_battle_midnight/sp_midnight'
        @_ships = window._ships
        @_decks = window._decks
        [maxHp, nowHp] = getHp body.api_maxhps, body.api_nowhps
        afterHp = Object.clone nowHp
        if body.api_hougeki?
          afterHp = hougekiAttack afterHp, body.api_hougeki
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ships
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp
      when '/kcsapi/api_req_sortie/airbattle'
        @_ships = window._ships
        @_decks = window._decks
        [maxHp, nowHp] = getHp body.api_maxhps, body.api_nowhps
        afterHp = Object.clone nowHp
        if body.api_kouku?
          afterHp = koukuAttack afterHp, body.api_kouku.api_stage3
        if body.api_kouku2?
          afterHp = koukuAttack afterHp, body.api_kouku2.api_stage3
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ships
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp
      when '/kcsapi/api_req_battle_midnight/battle'
        @_ships = window._ships
        @_decks = window._decks
        [maxHp, nowHp] = getHp body.api_maxhps, body.api_nowhps
        afterHp = Object.clone nowHp
        if body.api_hougeki?
          afterHp = hougekiAttack afterHp, body.api_hougeki
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ships
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp
      when '/kcsapi/api_req_sortie/battleresult'
        @_ships = window._ships
        @_decks = window._decks
        dataItem = []
        nowDate = new Date()
        # dataItem.push "#{nowDate.toLocaleDateString()} #{nowDate.toTimeString()}"
        dataItem.push nowDate.getTime()
        dataItem.push "#{body.api_quest_name}(#{@mapAreaId}-#{@mapInfoNo})"
        if @apiNo is @BosscellNo or @colorNo is 5
          dataItem.push "#{@apiNo}(Boss点)"
        else dataItem.push "#{@apiNo}(道中)"
        if @isStart
          dataItem.push "出击"
        else dataItem.push "进击"
        @isStart = false
        switch body.api_win_rank
          when 'S'
            if @notDemageFlag
              dataItem.push '完全胜利!!!S'
            else dataItem.push '胜利S'
          when 'A'
            dataItem.push '胜利A'
          when 'B'
            dataItem.push '战术的胜利B'
          when 'C'
            dataItem.push '战术的败北C'
          when 'D'
            dataItem.push '败北D'
          when 'E'
            dataItem.push '败北E'
          else
            dataItem.push "奇怪的战果？#{body.api_win_rank}"
        dataItem.push body.api_enemy_info.api_deck_name
        if body.api_get_ship?
          dataItem.push body.api_get_ship.api_ship_name
        else if body.api_get_useitem
          dataItem.push getUseItem body.api_get_ship.api_get_useitem_id
        else dataItem.push ""
        dataItem.push @dangerousShip
        dataItem.push "#{@_ships[@_deck.api_ship[0]].api_name}(Lv.#{@_ships[@_deck.api_ship[0]].api_lv})", ''
        dataItem.push "#{@_ships[@_deck.api_ship[body.api_mvp-1]].api_name}(Lv.#{@_ships[@_deck.api_ship[body.api_mvp-1]].api_lv})", ''
        {attackData} = @state
        attackData.unshift dataItem
        # log "save and show new data"
        @saveAttackLog dataItem
        {dataVersion} = @state
        dataVersion[0] += 1
        @setState
          attackData: attackData
          dataVersion: dataVersion

      # 远征
      when '/kcsapi/api_req_mission/result'
        {$useitems} = window
        dataItem = []
        nowDate = new Date()
        dataItem.push nowDate.getTime()
        dataItem.push body.api_quest_name
        switch body.api_clear_result
          when 0
            dataItem.push "失败"
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
        {$slotitems, $slotitemTypes} = window
        dataItem = []
        nowDate = new Date()
        dataItem.push nowDate.getTime()
        if body.api_create_flag is 0
          dataItem.push "失败"
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
        dataItem.push "#{@_ships[_decks[0].api_ship[0]].api_name}(Lv.#{@_ships[_decks[0].api_ship[0]].api_lv})"
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
        if body.api_result is 1
          @largeFlag = (postBody.api_large_flag is "1")
          @material = [parseInt(postBody.api_item1), parseInt(postBody.api_item2), parseInt(postBody.api_item3), parseInt(postBody.api_item4), parseInt(postBody.api_item5)]
          @kdockId = parseInt(postBody.api_kdock_id)
          @createShipFlag = true
      when '/kcsapi/api_get_member/kdock'
        if @createShipFlag
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
        dataItem = []
        nowDate = new Date()
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

  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
  componentWillMount: ->
    @nickNameId = '132778983'
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
    <TabbedArea activeKey={@state.selectedKey} animation={false} onSelect={@handleSelectTab}>
      <TabPane eventKey={0} tab='出击' ><AkashicLog indexKey={0} selectedKey={@state.selectedKey} data={@state.attackData} dataVersion={@state.dataVersion[0]} tableTab={attackTableTab} contentType={'attack'}/></TabPane>
      <TabPane eventKey={1} tab='远征' ><AkashicLog indexKey={1} selectedKey={@state.selectedKey} data={@state.missionData} dataVersion={@state.dataVersion[1]} tableTab={missionTableTab} contentType={'mission'}/></TabPane>
      <TabPane eventKey={2} tab='建造' ><AkashicLog indexKey={2} selectedKey={@state.selectedKey} data={@state.createShipData} dataVersion={@state.dataVersion[3]} tableTab={createShipTableTab} contentType={'createShip'}/></TabPane>
      <TabPane eventKey={3} tab='开发' ><AkashicLog indexKey={3} selectedKey={@state.selectedKey} data={@state.createItemData} dataVersion={@state.dataVersion[2]} tableTab={createItemTableTab} contentType={'createItem'}/></TabPane>
      <TabPane eventKey={4} tab='资源统计' ><AkashicResourceLog indexKey={4} selectedKey={@state.selectedKey} data={@state.resourceData} dataVersion={@state.dataVersion[4]} tableTab={resourceTableTab} mapShowFlag={@state.mapShowFlag} contentType={'resource'}/></TabPane>
      <TabPane eventKey={5} tab='战果' ><AkashicSenkaLog indexKey={5} selectedKey={@state.selectedKey} downloadFlag={@state.downloadFlag} memberId={@state.memberId} tableTab={senkaTableTab} rankShowFlag={@state.rankShowFlag} contentType={'resource'}/></TabPane>
      <TabPane eventKey={6} tab='高级' >
        <AkashicAdvancedModule
          tableTab={
            'attack': attackTableTab
            'mission': missionTableTab
            'createItem': createItemTableTab
            'createShip': createShipTableTab
            'resource': resourceTableTab
          }
          attackData={@state.attackData}
          missionData={@state.missionData}
          createItemData={@state.createItemData}
          createShipData={@state.createShipData}
          resourceData={@state.resourceData}/>
      </TabPane>
    </TabbedArea>

React.render <AkashicRecordsArea />, $('akashic-records')
