"use strict"

{APPDATA_PATH, CONST, config} = window
{initializeLogs, addLog} = require './actions'

dataCoManager = require '../lib/data-co-manager'

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


class APIResolver
  constructor: (store)->
    @compatible = true

    @store = store

    @nickNameId = config.get 'plugin.Akashic.nickNameId', 0
    @nowDate = 0
    @enableRecord = false
    @isStart = true
    @_ships = []
    @timeString = ""
    @mapLv = []

    createShipFlag: false   #注意！之后要用config处理关于建造中正好猫了导致log数据遗失的问题！
    largeFlag: false
    material: []
    kdockId: 0

    @bindHandleResponse = @handleResponse.bind @
    @bindHandleBattleResultResponse = @handleBattleResultResponse.bind @

    @updateLogs()

  updateLogs: () ->
    if @nickNameId? and @nickNameId isnt 0
      data = dataCoManager.initializeData @nickNameId
      for type, logs of data
        @store.dispatch(initializeLogs(logs, type))
      if data['resource'].length > 0
        @timeString = timeToBString data['resource'][0][0]
      else
        @timeString = ''

  updateUser: () ->
    if window._nickNameId? and @nickNameId isnt window._nickNameId
      @nickNameId = window._nickNameId
      config.set 'plugin.Akashic.nickNameId', @nickNameId
      @updateLogs()

  start: () ->
    window.addEventListener 'game.response', @bindHandleResponse
    window.addEventListener 'battle.result', @bindHandleBattleResultResponse
    @updateUser()

  stop: () ->
    window.removeEventListener 'game.response', @bindHandleResponse
    window.removeEventListener 'battle.result', @bindHandleBattleResultResponse

  handleResponse: (e) ->
    {method, body, postBody} = e.detail
    urlpath = e.detail.path
    switch urlpath
      when '/kcsapi/api_get_member/basic'
        @updateUser()
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
        dataCoManager.saveLog(CONST.typeList.mission, dataItem, true)
        @store.dispatch(addLog(dataItem, CONST.typeList.mission))

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
        _decks = window._decks
        dataItem.push "#{@_ships[_decks[0].api_ship[0]].api_name}(Lv.#{@_ships[_decks[0].api_ship[0]].api_lv})"
        dataItem.push window._teitokuLv
        dataCoManager.saveLog(CONST.typeList.createItem, dataItem, true)
        @store.dispatch(addLog(dataItem, CONST.typeList.createItem))

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
          _decks = window._decks
          $ships = window.$ships
          $shiptypes = window.$shipTypes
          apiData = body[@kdockId-1]
          dataItem = []
          nowDate = new Date()
          dataItem.push nowDate.getTime()
          if @largeFlag
            dataItem.push "大型建造"
          else
            dataItem.push "普通建造"
          dataItem.push $ships[apiData.api_created_ship_id].api_name
          dataItem.push $shiptypes[$ships[apiData.api_created_ship_id].api_stype].api_name
          dataItem = dataItem.concat @material
          remainNum = 0
          for kdock in body
            if kdock.api_state is 0
              remainNum = remainNum + 1
          dataItem.push remainNum
          dataItem.push "#{@_ships[_decks[0].api_ship[0]].api_name}(Lv.#{@_ships[_decks[0].api_ship[0]].api_lv})"
          dataItem.push window._teitokuLv
          dataCoManager.saveLog(CONST.typeList.createShip, dataItem, true)
          @store.dispatch(addLog(dataItem, CONST.typeList.createShip))
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
          dataCoManager.saveLog('resource', dataItem, true)
          @store.dispatch(addLog(dataItem, 'resource'))

  handleBattleResultResponse: (e) ->
    {map, quest, boss, mapCell, rank, deckHp, deckShipId, enemy, dropItem, dropShipId, combined, mvp} = e.detail
    if not @enableRecord
      return
    if not combined?
      event = new CustomEvent 'akashic.records.incompatible',
        bubbles: true
        cancelable: true
        detail:
          warning: "Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release."
      window.dispatchEvent event
      @compatible = false
    if not @compatible
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
    dataCoManager.saveLog(CONST.typeList.attack, dataItem, true)
    @store.dispatch(addLog(dataItem, CONST.typeList.attack))

module.exports = APIResolver
