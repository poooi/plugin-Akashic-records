fs = require 'fs-extra'
glob = require 'glob'
{React, ReactBootstrap, $, path, ROOT, APPDATA_PATH} = window
{TabbedArea, TabPane} = ReactBootstrap
{log, warn, error} = require path.join(ROOT, 'lib/utils')
# AkashicRecordTab = require './item-info-table-area'
# AkashicRecordContent = require './item-info-checkbox-area'
AkashicLog = require './akashic-records-log'


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
        dangerInfo = "#{dangerInfo}, "
      dangerInfo = "#{dangerInfo}#{_ships[_deck.api_ship[i]].api_name}"
      dangerFlag = true
  log "战斗结束后剩余HP：#{JSON.stringify afterHp}"
  [dangerFlag, dangerInfo]


attackTableTab = ['No.', '时间', '海域', '地图点', '状态', '战况', '敌舰队', 
    '捞！', '大破舰', '旗舰', '旗舰（第二舰队）', 'MVP', 'MVP(第二舰队）']

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
  nickNameId: 0
  mapAreaId: 0
  mapInfoNo: 0
  apiNo: 0
  BosscellNo: -1
  colorNo: 0
  dangerousShip: null
  flagShip: ['', '']
  isStart: true
  notDemageFlag: true
  _deck: []
  _ship: []
  getDataAccordingToNameId: (id) ->
    testNum = /^[1-9]+[0-9]*$/
    attackLogs = glob.sync(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), 'attack', '*'))
    attackLogs = attackLogs.map (filePath) ->
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
    {attackData} = @state
    for attackLog in attackLogs
      attackData = attackData.concat attackLog
    log "getData from file"
    @setState 
      attackData: attackData
  saveAttackLog: (log) ->
    fs.ensureDirSync(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), 'attack'))
    fs.appendFile(path.join(APPDATA_PATH, 'akashic-records', @nickNameId.toString(), 'attack', "#{(new Date(log[0])).toLocaleDateString().replace(/[^0-9]/g, "")}"), "#{log.join(',')}\n", 'utf8', (err)->
      error "Write attack-log file error!" if err) 
  handleResponse: (e) ->
    {method, body, postBody} = e.detail
    urlpath = e.detail.path
    switch urlpath
      when '/kcsapi/api_get_member/basic'
        @nickNameId = body.api_nickname_id
        @getDataAccordingToNameId @nickNameId
      when '/kcsapi/api_req_map/start'
        [@mapAreaId, @mapInfoNo, @apiNo, @BosscellNo, @colorNo] = [body.api_maparea_id, body.api_mapinfo_no, body.api_no, body.api_bosscell_no, body.api_color_no]
        @_deck = window._decks[postBody.api_deck_id-1]
        @_ship = window._ships
        @isStart = true
        @dangerousShip = '无'
        @notDemageFlag = true
      when '/kcsapi/api_req_map/next'
        [@mapAreaId, @mapInfoNo, @apiNo, @BosscellNo, @colorNo] = [body.api_maparea_id, body.api_mapinfo_no, body.api_no, body.api_bosscell_no, body.api_color_no]
        @dangerousShip = '无'
        @notDemageFlag = true
      when '/kcsapi/api_req_sortie/battle'
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
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ship
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp
      when '/kcsapi/api_req_battle_midnight/sp_midnight'
        [maxHp, nowHp] = getHp body.api_maxhps, body.api_nowhps
        afterHp = Object.clone nowHp
        if body.api_hougeki?
          afterHp = hougekiAttack afterHp, body.api_hougeki
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ship
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp
      when '/kcsapi/api_req_sortie/airbattle'
        [maxHp, nowHp] = getHp body.api_maxhps, body.api_nowhps
        afterHp = Object.clone nowHp
        if body.api_kouku?
          afterHp = koukuAttack afterHp, body.api_kouku.api_stage3
        if body.api_kouku2?
          afterHp = koukuAttack afterHp, body.api_kouku2.api_stage3
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ship
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp
      when '/kcsapi/api_req_battle_midnight/battle'
        [maxHp, nowHp] = getHp body.api_maxhps, body.api_nowhps
        afterHp = Object.clone nowHp
        if body.api_hougeki?
          afterHp = hougekiAttack afterHp, body.api_hougeki
        [dangerFlag, dangerInfo] = judgeDanger afterHp, maxHp, @_deck, @_ship
        @dangerousShip = dangerInfo if dangerFlag
        @notDemageFlag = @notDemageFlag and judgeFace nowHp, afterHp  
      when '/kcsapi/api_req_sortie/battleresult'
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
        dataItem.push "#{@_ship[@_deck.api_ship[0]].api_name}(Lv.#{@_ship[@_deck.api_ship[0]].api_lv})", ''
        dataItem.push "#{@_ship[@_deck.api_ship[body.api_mvp-1]].api_name}(Lv.#{@_ship[@_deck.api_ship[body.api_mvp-1]].api_lv})", ''
        {attackData} = @state
        attackData.push dataItem
        log "save and show new data"
        @saveAttackLog dataItem
        @setState attackData

  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
  componentWillMount: ->
    if @nickNameId isnt 0
      @getDataAccordingToNameId @nickNameId
  render: ->
    <TabbedArea defaultActiveKey={0}>
      <TabPane eventKey={0} tab='出击'><AkashicLog data={@state.attackData} tableTab={attackTableTab}/></TabPane>
      <TabPane eventKey={1} tab='远征'></TabPane>
      <TabPane eventKey={2} tab='建造'></TabPane>
      <TabPane eventKey={3} tab='开发'></TabPane>
      <TabPane eventKey={4} tab='资源统计'></TabPane>
      <TabPane eventKey={5} tab='高级'></TabPane>
    </TabbedArea>

React.render <AkashicRecordsArea />, $('akashic-records')
