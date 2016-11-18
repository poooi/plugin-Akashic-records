const {APPDATA_PATH, CONST, config} = window
import { initializeLogs, addLog } from './actions'

import dataCoManager from '../lib/data-co-manager'

const judgeIfDemage = (nowHp, beforeHp) => {
  return nowHp.some((hp, i) => hp < beforeHp[i])
}

const judgeDanger = (nowHp, deckShipId, _ships) => {
  let dangerInfo = ''
  let dangerFlag = false
  deckShipId.forEach((id, i) => {
    if (id === -1) return
    if (nowHp[i] / _ships[id].api_maxhp < 0.250001) {
      dangerInfo = `${dangerInfo}${dangerInfo === '' ? '' : ' & '}`
      dangerInfo = `${dangerInfo}${_ships[id].api_name}`
    }
  })
  if (process.env.DEBUG) console.log("战斗结束后剩余HP：#{JSON.stringify nowHp}")
  return dangerInfo === '' ? '无' : dangerInfo
}

const timeToBString = (time) => {
  const date = new Date(time)
  return `${date.getFullYear()}${date.getMonth()}${date.getDate()}${date.getHours()}`
}


class APIResolver {
    constructor(store) {
      this.compatible = true
      this.store = store
      this.nickNameId = config.get('plugin.Akashic.nickNameId', 0)
      this.nowDate = 0
      this.enableRecord = false
      this.isStart = true
      this._ships = []
      this.timeString = ""
      this.mapLv = []
      this.battleStart = false

      this.createShipFlag = false   //注意！之后要用config处理关于建造中正好猫了导致log数据遗失的问题！
      this.largeFlag = false
      this.material = []
      this.kdockId = 0

      this.updateLogs()
    }
    updateLogs() {
      if (this.nickNameId && this.nickNameId != 0) {
        data = dataCoManager.initializeData(this.nickNameId)
        for (let type of Object.keys(data)) {
          this.store.dispatch(initializeData(data[type], type))
        }
        if ()
        this.timeString = data['resource'].length === 0
          ? timeToBString(data['resource'][0][0]
          : this.timeString = ''

      }

    }

    updateUser: () ->
      if window._nickNameId? and this.nickNameId isnt window._nickNameId
        this.nickNameId = window._nickNameId
        config.set 'plugin.Akashic.nickNameId', this.nickNameId
        this.updateLogs()

    start: () ->
      window.addEventListener 'game.request', this.bindHandleRequest
      window.addEventListener 'game.response', this.bindHandleResponse
      window.addEventListener 'battle.result', this.bindHandleBattleResultResponse
      this.updateUser()

    stop: () ->
      window.removeEventListener 'game.request', this.bindHandleRequest
      window.removeEventListener 'game.response', this.bindHandleResponse
      window.removeEventListener 'battle.result', this.bindHandleBattleResultResponse

    handleRequest: (e) ->
      {path, body} = e.detail
      urlpath = e.detail.path
      switch urlpath
        # 解体
        when '/kcsapi/api_req_kousyou/destroyship'
          _ships = window._ships
          $shiptypes = window.$shipTypes
          dataItem = []
          nowDate = new Date()
          dataItem.push nowDate.getTime()
          dataItem.push '解体'
          shipId = body.api_ship_id
          dataItem.push $shiptypes[_ships[shipId].api_stype].api_name
          dataItem.push "#{_ships[shipId].api_name}(Lv.#{_ships[shipId].api_lv})"
          dataCoManager.saveLog('retirement', dataItem)
          this.store.dispatch(addLog(dataItem, 'retirement'))

        # 改修
        when '/kcsapi/api_req_kaisou/powerup'
          {api_id, api_id_items} = e.detail.body
          _ships = window._ships
          $shiptypes = window.$shipTypes
          dateTime = new Date().getTime()
          # Read the status before modernization
          for shipId in api_id_items.split ','
            dataItem = []
            dataItem.push dateTime++
            dataItem.push '改修'
            dataItem.push $shiptypes[_ships[shipId].api_stype].api_name
            dataItem.push "#{_ships[shipId].api_name}(Lv.#{_ships[shipId].api_lv})"
            dataCoManager.saveLog('retirement', dataItem)
            this.store.dispatch(addLog(dataItem, 'retirement'))

    handleResponse: (e) ->
      {method, body, postBody} = e.detail
      urlpath = e.detail.path
      switch urlpath
        when '/kcsapi/api_get_member/basic'
          this.updateUser()
        # Map selected rank
        when '/kcsapi/api_get_member/mapinfo'
          for map in body
            this.mapLv[map.api_id] = 0
            if map.api_eventmap?
              this.mapLv[map.api_id] = map.api_eventmap.api_selected_rank
        # Eventmap select report
        when '/kcsapi/api_req_map/select_eventmap_rank'
          this.mapLv[parseInt(postBody.api_maparea_id) * 10 + parseInt(postBody.api_map_no)] = parseInt(postBody.api_rank)
        when '/kcsapi/api_req_map/start'
          this._ships = window._ships
          this.isStart = true
          this.battleStart = false
        when '/kcsapi/api_req_map/next'
          this._ships = window._ships
          this.nowDate = new Date().getTime()
          this.battleStart = false
        when '/kcsapi/api_req_sortie/battle', \
        '/kcsapi/api_req_battle_midnight/sp_midnight', \
        '/kcsapi/api_req_sortie/airbattle', \
        '/kcsapi/api_req_battle_midnight/battle', \
        '/kcsapi/api_req_combined_battle/airbattle', \
        '/kcsapi/api_req_combined_battle/battle', \
        '/kcsapi/api_req_combined_battle/midnight_battle', \
        '/kcsapi/api_req_combined_battle/sp_midnight', \
        '/kcsapi/api_req_combined_battle/battle_water'
          if not this.battleStart
            this._ships = window._ships
            this.nowDate = new Date().getTime()
            this.battleStart = true

        # 远征
        when '/kcsapi/api_req_mission/result'
          if not this.enableRecord
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
          dataCoManager.saveLog(CONST.typeList.mission, dataItem)
          this.store.dispatch(addLog(dataItem, CONST.typeList.mission))

        # 开发
        when '/kcsapi/api_req_kousyou/createitem'
          if not this.enableRecord
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
          this._ships = window._ships
          _decks = window._decks
          dataItem.push "#{this._ships[_decks[0].api_ship[0]].api_name}(Lv.#{this._ships[_decks[0].api_ship[0]].api_lv})"
          dataItem.push window._teitokuLv
          dataCoManager.saveLog(CONST.typeList.createItem, dataItem)
          this.store.dispatch(addLog(dataItem, CONST.typeList.createItem))

        # 建造
        when '/kcsapi/api_req_kousyou/createship'
          if not this.enableRecord
            break
          if body.api_result is 1
            this.largeFlag = (postBody.api_large_flag is "1")
            this.material = [parseInt(postBody.api_item1), parseInt(postBody.api_item2), parseInt(postBody.api_item3), parseInt(postBody.api_item4), parseInt(postBody.api_item5)]
            this.kdockId = parseInt(postBody.api_kdock_id)
            this.createShipFlag = true
        when '/kcsapi/api_get_member/kdock'
          if this.createShipFlag and this.enableRecord
            this._ships = window._ships
            _decks = window._decks
            $ships = window.$ships
            $shiptypes = window.$shipTypes
            apiData = body[this.kdockId-1]
            dataItem = []
            nowDate = new Date()
            dataItem.push nowDate.getTime()
            if this.largeFlag
              dataItem.push "大型建造"
            else
              dataItem.push "普通建造"
            dataItem.push $ships[apiData.api_created_ship_id].api_name
            dataItem.push $shiptypes[$ships[apiData.api_created_ship_id].api_stype].api_name
            dataItem = dataItem.concat this.material
            remainNum = 0
            for kdock in body
              if kdock.api_state is 0
                remainNum = remainNum + 1
            dataItem.push remainNum
            dataItem.push "#{this._ships[_decks[0].api_ship[0]].api_name}(Lv.#{this._ships[_decks[0].api_ship[0]].api_lv})"
            dataItem.push window._teitokuLv
            dataCoManager.saveLog(CONST.typeList.createShip, dataItem)
            this.store.dispatch(addLog(dataItem, CONST.typeList.createShip))
            this.createShipFlag = false

        # 资源
        when '/kcsapi/api_port/port'
          this.updateUser()
          this.enableRecord = true
          dataItem = []
          nowDate = new Date()
          this.deckCombinedFlag = body.api_combined_flag
          if this.timeString isnt timeToBString(nowDate.getTime())
            this.timeString = timeToBString(nowDate.getTime())
            dataItem = []
            dataItem.push nowDate.getTime()
            dataItem.push item.api_value for item in body.api_material
            dataCoManager.saveLog('resource', dataItem)
            this.store.dispatch(addLog(dataItem, 'resource'))



    handleBattleResultResponse: (e) ->
      this.battleStart = false
      {map, quest, boss, mapCell, rank, deckHp, deckShipId, enemy, dropItem, dropShipId, combined, mvp} = e.detail
      if not this.enableRecord
        return
      if not combined?
        event = new CustomEvent 'akashic.records.incompatible',
          bubbles: true
          cancelable: true
          detail:
            warning: "Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release."
        window.dispatchEvent event
        this.compatible = false
      if not this.compatible
        return
      dataItem = []
      dataItem.push this.nowDate
      switch this.mapLv[map]
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
      if this.isStart
        dataItem.push "出撃"
      else dataItem.push "進撃"
      this.isStart = false
      beforeHp = deckShipId.map (id) =>
        if id isnt -1
          this._ships[id].api_nowhp
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
      dataItem.push judgeDanger deckHp, deckShipId, this._ships
      tmp = ['', '', '', '']
      tmp[0] = "#{this._ships[deckShipId[0]].api_name}(Lv.#{this._ships[deckShipId[0]].api_lv})"
      tmp[2] = "#{this._ships[deckShipId[mvp[0]]].api_name}(Lv.#{this._ships[deckShipId[mvp[0]]].api_lv})"
      if combined
        tmp[1] = "#{this._ships[deckShipId[6]].api_name}(Lv.#{this._ships[deckShipId[6]].api_lv})"
        tmp[3] = "#{this._ships[deckShipId[6 + mvp[1]]].api_name}(Lv.#{this._ships[deckShipId[6 + mvp[1]]].api_lv})"
      dataItem = dataItem.concat tmp
      dataCoManager.saveLog(CONST.typeList.attack, dataItem)
      this.store.dispatch(addLog(dataItem, CONST.typeList.attack))
}

module.exports = APIResolver
