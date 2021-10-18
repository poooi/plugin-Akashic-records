const { config } = window
import CONST from '../lib/constant'
import { initializeLogs, addLog } from './actions'
import _ from 'lodash'
import * as API from 'kcsapi'
import { APIMstShip, APIMstShipgraph, APIMstStype, APIMstUseitem, APIMstSlotitem, APIMstSlotitemEquiptype } from 'kcsapi/api_start2/getData/response'

import dataCoManager from '../lib/data-co-manager'

import { store, Store } from 'views/create-store'
import { DataRow } from './reducers/data'
import { APIShip } from 'kcsapi/api_port/port/response'
import { APIDeck } from 'kcsapi/api_get_member/preset_deck/response'
import { APIGetItem } from 'kcsapi/api_req_mission/result/response'
import { DataType } from './reducers/tab'

interface GameRequestDetail {
  method: string
  path: string
  body: object
  time: number
}
type GameRequestEvent = CustomEvent<GameRequestDetail>

interface GameResponseDetail {
  method: string
  path: string
  body: object
  postBody: object
  time: number
}
type GameResponseEvent = CustomEvent<GameResponseDetail>

interface BattleResultDetail {
  map: number
  quest: string
  boss: boolean
  mapCell: number
  rank: string
  deckHp: number[]
  deckInitHp: number[]
  deckShipId: number[]
  enemy: string
  dropItem: APIGetItem
  dropShipId: number
  combined: string
  mvp: number[]
  time: number
}
type BattleResultEvent = CustomEvent<BattleResultDetail>

const judgeIfDemage = (nowHp: number[], beforeHp: number[]) => {
  return nowHp.some((hp, i) => hp < beforeHp[i])
}

const timeToBString = (time: number) => {
  const date = new Date(time)
  return `${date.getFullYear()}${date.getMonth()}${date.getDate()}${date.getHours()}`
}

const seikuText = ['制空均衡','制空権確保','航空優勢','航空劣勢','制空権喪失']
const lostKindText = [
  '空襲により備蓄資源に損害を受けました！',
  '空襲により備蓄資源に損害を受け、基地航空隊にも地上撃破の損害が発生しました！',
  '空襲により基地航空隊に地上撃破の損害が発生しました！',
  '空襲による基地の損害はありません。',
]


class APIResolver {
  private compatible = true
  private store: Store
  private nickNameId = config.get('plugin.Akashic.nickNameId', '0')
  private nowDate = 0
  private enableRecord = false
  private isStart = true
  private timeString = 'INIT'
  private mapLv: number[] = []
  private battleStart = false

  private createShipFlag = false   //注意！之后要用config处理关于建造中正好猫了导致log数据遗失的问题！
  private largeFlag = false
  private material: number[] = []
  private kdockId = 0

  constructor(store: Store) {
    this.store = store
  }

  initializeLogs() {
    dataCoManager.initializeData(this.nickNameId).then((data) => {
      for (const type of Object.keys(data)) {
        this.store.dispatch(initializeLogs(data[type], type as DataType))
      }
      this.timeString = data.resource.length > 0 ? timeToBString(data.resource[0][0]) : ''
    })
  }

  updateUser(forceUpdateLogs = false) {
    if ((this.getNickNameId() && this.nickNameId !== this.getNickNameId()) || forceUpdateLogs) {
      this.nickNameId = this.getNickNameId()
      config.set('plugin.Akashic.nickNameId', this.nickNameId)
      dataCoManager.setNickNameId(this.nickNameId)
      this.initializeLogs()
    }
  }

  start() {
    window.addEventListener('game.request', this.handleRequest)
    window.addEventListener('game.response', this.handleResponse)
    window.addEventListener('battle.result', this.handleBattleResultResponse)
    this.updateUser(true)
  }

  stop() {
    window.removeEventListener('game.request', this.handleRequest)
    window.removeEventListener('game.response', this.handleResponse)
    window.removeEventListener('battle.result', this.handleBattleResultResponse)
  }

  getMstShipByApiShipId = (shipId: number | string): APIMstShip => {
    return window.getStore(`const.$ships.${shipId}`)
  }

  getMstShip = (id: number | string): APIMstShip => {
    const { api_ship_id: shipId } = this.getShip(id)
    return this.getMstShipByApiShipId(shipId)
  }

  getShip = (id: number | string): APIShip => {
    return window.getStore(`info.ships.${id}`)
  }

  getShipType = (id: number | string): APIMstStype => {
    return window.getStore(`const.$shipTypes.${id}`)
  }

  getShipGraph = (id: number | string): APIMstShipgraph => {
    return window.getStore(`const.$shipgraph.${id}`)
  }

  getDeck = (index: number): APIDeck => {
    return window.getStore(`info.fleets.${index}`)
  }

  getMstUseItem = (id: number | string): APIMstUseitem => {
    return window.getStore(`const.$useitems.${id}`)
  }

  getMstEquip = (id: number | string): APIMstSlotitem => {
    return window.getStore(`const.$equips.${id}`)
  }

  getEquipType = (id: number | string): APIMstSlotitemEquiptype => {
    return window.getStore(`const.$equipTypes.${id}`)
  }

  getTeitokuLv = (): string => {
    return window.getStore('info.basic.api_level').toString()
  }

  getNickNameId = (): string => {
    return window.getStore('info.basic.api_nickname_id')
  }

  judgeDanger = (nowHp: number[], deckShipId: number[]) => {
    let dangerInfo = ''
    deckShipId.forEach((id, i) => {
      if (id === -1) return
      if (nowHp[i] / this.getShip(id).api_maxhp < 0.250001) {
        dangerInfo = `${dangerInfo}${dangerInfo === '' ? '' : ' & '}`
        dangerInfo = `${dangerInfo}${this.getMstShip(id).api_name}`
      }
    })
    if (process.env.DEBUG) console.log("战斗结束后剩余HP：#{JSON.stringify nowHp}")
    return dangerInfo
  }

  handleRequest = (event: Event) => {
    const e = event as GameRequestEvent
    const urlpath = e.detail.path
    switch (urlpath) {
      // 解体
      case '/kcsapi/api_req_kousyou/destroyship': {
        const body = e.detail.body as API.APIReqKousyouDestroyshipRequest
        let dateTime = new Date().getTime()
        for (const shipId of body.api_ship_id.split(',')) {
          const ship = this.getShip(shipId)
          const mstShip = this.getMstShip(shipId)
          const dataItem: DataRow = [
            dateTime++,
            '解体',
            this.getShipType(mstShip.api_stype).api_name,
            `${mstShip.api_name}(Lv.${ship.api_lv})`,
          ]
          dataCoManager.saveLog('retirement', dataItem)
          this.store.dispatch(addLog(dataItem, 'retirement'))
        }
        break
      }

      // 改修
      case '/kcsapi/api_req_kaisou/powerup': {
        const body = e.detail.body as API.APIReqKaisouPowerupRequest
        const { api_id_items: apiIdItems } = body
        let dateTime = new Date().getTime()
        // Read the status before modernization
        for (const shipId of apiIdItems.split(',')) {
          const ship = this.getShip(shipId)
          const mstShip = this.getMstShip(shipId)
          const dataItem: DataRow = [
            dateTime++,
            '改修',
            this.getShipType(mstShip.api_stype).api_name,
            `${mstShip.api_name}(Lv.${ship.api_lv})`,
          ]
          dataCoManager.saveLog('retirement', dataItem)
          this.store.dispatch(addLog(dataItem, 'retirement'))
        }
        break
      }
    }
  }

  handleResponse = (event: Event) => {
    const e = event as GameResponseEvent
    const urlpath = e.detail.path
    switch (urlpath) {
      case '/kcsapi/api_get_member/basic':
        this.updateUser()
        break

        // Map selected rank
      case '/kcsapi/api_get_member/mapinfo':
        const body = e.detail.body as API.APIGetMemberMapinfoResponse
        for (const map of body.api_map_info) {
          this.mapLv[map.api_id] = 0
          if (map.api_eventmap)
            this.mapLv[map.api_id] = map.api_eventmap.api_selected_rank
        }
        break

        // Eventmap select report
      case '/kcsapi/api_req_map/select_eventmap_rank':
        const postBody = e.detail.postBody as API.APIReqMapSelectEventmapRankRequest
        this.mapLv[parseInt(postBody.api_maparea_id) * 10 + parseInt(postBody.api_map_no)] = parseInt(postBody.api_rank)
        break

      case '/kcsapi/api_req_map/start':
      case '/kcsapi/api_req_map/next': {
        const body = e.detail.body as API.APIReqMapNextResponse
        if (urlpath === '/kcsapi/api_req_map/start') {
          this.isStart = true
        }
        this.nowDate = new Date().getTime()
        this.battleStart = false
        const { api_destruction_battle } = body
        if (api_destruction_battle != null) {
          const { api_air_base_attack } = api_destruction_battle
          const parsed_api_air_base_attack =
            typeof api_air_base_attack === 'string'
              ? JSON.parse(api_air_base_attack)
              : api_air_base_attack

          const map = parseInt(window.getStore('sortie.sortieMapId'), 10) || 0
          const quest = window.getStore('const.$maps')[map]?.api_name || ''
          const mapText = map <= 410
            ? `${quest}(${Math.floor(map / 10)}-${map % 10})`
            : `${quest}(${Math.floor(map / 10)}-${map % 10} %rank) | ${this.mapLv[map] || 0}`

          const seiku = seikuText[parsed_api_air_base_attack.api_stage1.api_disp_seiku] || '奇怪的结果'
          const lostKind = lostKindText[api_destruction_battle.api_lost_kind - 1] || '奇怪的结果'
          const enemy = ''

          const dataItem: DataRow = [this.nowDate, mapText,'基地防空戦', seiku, lostKind, enemy,'','','','','','']
          dataCoManager.saveLog(CONST.typeList.attack, dataItem)
          this.store.dispatch(addLog(dataItem, CONST.typeList.attack as DataType))
        }
        break
      }

      case '/kcsapi/api_req_sortie/battle':
      case '/kcsapi/api_req_battle_midnight/sp_midnight':
      case '/kcsapi/api_req_sortie/airbattle':
      case '/kcsapi/api_req_battle_midnight/battle':
      case '/kcsapi/api_req_combined_battle/airbattle':
      case '/kcsapi/api_req_combined_battle/ld_airbattle':
      case '/kcsapi/api_req_combined_battle/battle':
      case '/kcsapi/api_req_combined_battle/midnight_battle':
      case '/kcsapi/api_req_combined_battle/sp_midnight':
      case '/kcsapi/api_req_combined_battle/battle_water':
        if (!this.battleStart) {
          this.nowDate = (new Date()).getTime()
          this.battleStart = true
        }
        break

        // 远征
      case '/kcsapi/api_req_mission/result': {
        if (!this.enableRecord)
          break
        const body = e.detail.body as API.APIReqMissionResultResponse
        const nowDate = new Date()
        const dataItem: DataRow = [
          nowDate.getTime(),
          body.api_quest_name,
          ["失敗", "成功", "大成功"][body.api_clear_result] || "奇怪的结果",
        ]

        if (body.api_clear_result === 0)
          dataItem.push(0, 0, 0, 0)
        else {
          dataItem.push(...(body.api_get_material as number[]).slice(0, 4))
        }

        const useItemFlag = body.api_useitem_flag;
        [0, 1].forEach((idx) => {
          if (useItemFlag[idx] > 0) {
            const itemStr = 'api_get_item' + (idx + 1) as ('api_get_item1' | 'api_get_item2')
            const useItemId =
                (body[itemStr]!.api_useitem_id <= 0) ?
                  useItemFlag[idx] :
                  body[itemStr]!.api_useitem_id
            dataItem.push(
              this.getMstUseItem(useItemId).api_name,
              body[itemStr]!.api_useitem_count
            )
          } else {
            dataItem.push('', '')
          }
        })
        dataCoManager.saveLog(CONST.typeList.mission, dataItem)
        this.store.dispatch(addLog(dataItem, CONST.typeList.mission as DataType))
        break
      }

      // 开发
      case '/kcsapi/api_req_kousyou/createitem': {
        if (!this.enableRecord) {
          break
        }
        const body = e.detail.body as API.APIReqKousyouCreateitemResponse
        const postBody = e.detail.postBody as API.APIReqKousyouCreateitemRequest
        const timestamp = (new Date()).getTime()
        _.each(body.api_get_items, (item, index) => {
          const dataItem: DataRow = [timestamp + index / 10] // apply a dcecimal to avoid key duplicating
          const deckFlagShipId = this.getDeck(0).api_ship[0]
          if (item.api_slotitem_id > -1) {
            const $item = this.getMstEquip(item.api_slotitem_id)
            dataItem.push(
              "成功",
              $item.api_name,
              this.getEquipType(_.get($item, 'api_type.2')).api_name
            )
          }
          else {
            dataItem.push(
              "失敗",
              'NA',
              'NA'
            )
          }
          dataItem.push(
            postBody.api_item1,
            postBody.api_item2,
            postBody.api_item3,
            postBody.api_item4
          )
          dataItem.push(
            `${this.getMstShip(deckFlagShipId).api_name}(Lv.${this.getShip(deckFlagShipId).api_lv})`,
            this.getTeitokuLv()
          )
          dataCoManager.saveLog(CONST.typeList.createItem, dataItem)
          this.store.dispatch(addLog(dataItem, CONST.typeList.createItem as DataType))
        })
        break
      }

      // 建造
      case '/kcsapi/api_req_kousyou/createship': {
        if (!this.enableRecord)
          break
        const body = e.detail.body as API.APIReqKousyouCreateshipResponse
        const postBody = e.detail.postBody as API.APIReqKousyouCreateshipRequest
        if (body.api_result === 1) {
          this.largeFlag = (postBody.api_large_flag === "1")
          this.material = (['api_item1', 'api_item2', 'api_item3', 'api_item4', 'api_item5'] as ('api_item1' | 'api_item2' | 'api_item3' | 'api_item4' | 'api_item5')[])
            .map((k) => parseInt(postBody[k]))
          this.kdockId = parseInt(postBody.api_kdock_id)
          this.createShipFlag = true
        }
        break
      }

      case '/kcsapi/api_get_member/kdock': {
        if (this.createShipFlag && this.enableRecord) {
          const body = e.detail.body as API.APIGetMemberKdockResponse[]
          const apiData = body[this.kdockId - 1]
          const mstShip = this.getMstShipByApiShipId(apiData.api_created_ship_id)
          const deckFlagShipId = this.getDeck(0).api_ship[0]
          const dataItem: DataRow = [
            (new Date()).getTime(),
            this.largeFlag ? '大型建造' : '普通建造',
            mstShip.api_name,
            this.getShipType(mstShip.api_stype).api_name,
            ...this.material,
          ]
          dataItem.push(
            body.filter(kdock => kdock.api_state === 0).length,
            `${this.getMstShip(deckFlagShipId).api_name}(Lv.${this.getShip(deckFlagShipId).api_lv})`,
            this.getTeitokuLv()
          )
          dataCoManager.saveLog(CONST.typeList.createShip, dataItem)
          this.store.dispatch(addLog(dataItem, CONST.typeList.createShip as DataType))
          this.createShipFlag = false
        }
        break
      }

      // 资源
      case '/kcsapi/api_port/port': {
        const body = e.detail.body as API.APIPortPortResponse
        this.updateUser()
        this.enableRecord = true
        const nowDate = new Date()
        if (this.timeString !== 'INIT' && this.timeString !== timeToBString(nowDate.getTime())) {
          this.timeString = timeToBString(nowDate.getTime())
          const dataItem: DataRow = [
            (new Date()).getTime(),
            ...body.api_material.map(item => item.api_value),
          ]
          dataCoManager.saveLog('resource', dataItem)
          this.store.dispatch(addLog(dataItem, 'resource'))
        }
        break
      }
    }
  }



  handleBattleResultResponse = (event: Event) => {
    const e = event as BattleResultEvent
    this.battleStart = false
    const {
      map,
      quest,
      boss,
      mapCell,
      rank,
      deckHp,
      deckShipId,
      enemy,
      dropItem,
      dropShipId,
      combined,
      mvp,
    } = e.detail

    if (!this.enableRecord)
      return
    if (combined == null) {
      const event = new CustomEvent(
        'akashic.records.incompatible', {
          bubbles: true,
          cancelable: true,
          detail: {
            warning: "Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release.",
          },
        }
      )
      window.dispatchEvent(event)
      this.compatible = false
    }
    if (!this.compatible)
      return

    const {
      time,
      deckInitHp,
    } = e.detail

    if (time == null || deckInitHp == null) {
      console.warn("Suggest to use up-to-date POI.")
    }

    let dataItem: DataRow = [time || this.nowDate]

    const mapText = map <= 410
      ? `${quest}(${Math.floor(map / 10)}-${map % 10})`
      : `${quest}(${Math.floor(map / 10)}-${map % 10} %rank) | ${this.mapLv[map] || 0}`
    dataItem.push(
      mapText,
      `${mapCell}(${boss ? 'Boss点' : '道中'})`,
      this.isStart ? '出撃' : '進撃'
    )
    this.isStart = false
    const beforeHp = deckInitHp || deckShipId.map((id) => id !== -1 ? this.getShip(id).api_nowhp : -1)
    switch (rank) {
    case 'S':
      dataItem.push(judgeIfDemage(deckHp, beforeHp) ? '勝利S' : '完全勝利!!!S')
      break
    case 'A':
      dataItem.push('勝利A')
      break
    case 'B':
      dataItem.push('戦術的勝利B')
      break
    case 'C':
      dataItem.push('戦術的敗北C')
      break
    case 'D':
      dataItem.push('敗北D')
      break
    case 'E':
      dataItem.push('敗北E')
      break
    default:
      dataItem.push(`奇怪的战果？${rank}`)
      break
    }
    dataItem.push(enemy)

    let dropData = dropShipId !== -1 ? this.getMstShipByApiShipId(dropShipId).api_name : ''
    if (dropItem && this.getMstUseItem(dropItem.api_useitem_id) && this.getMstUseItem(dropItem.api_useitem_id).api_name)
      dropData = `${dropData}${dropData !== '' ? ' &' : ''}${this.getMstUseItem(dropItem.api_useitem_id).api_name}`
    dataItem.push(dropData)
    dataItem.push(this.judgeDanger(deckHp, deckShipId))
    const tmp = ['', '', '', '']
    tmp[0] = `${this.getMstShip(deckShipId[0]).api_name}(Lv.${this.getShip(deckShipId[0]).api_lv})`
    tmp[2] = `${this.getMstShip(deckShipId[mvp[0]]).api_name}(Lv.${this.getShip(deckShipId[mvp[0]]).api_lv})`
    if (combined) {
      tmp[1] = `${this.getMstShip(deckShipId[6]).api_name}(Lv.${this.getShip(deckShipId[6]).api_lv})`
      tmp[3] = `${this.getMstShip(deckShipId[6 + mvp[1]]).api_name}(Lv.${this.getShip(deckShipId[6 + mvp[1]]).api_lv})`
    }
    dataItem.push(...tmp)
    dataCoManager.saveLog(CONST.typeList.attack, dataItem)
    this.store.dispatch(addLog(dataItem, CONST.typeList.attack as DataType))
  }
}

export const apiResolver = new APIResolver(store)
export default APIResolver
