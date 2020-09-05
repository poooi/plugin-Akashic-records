import React from 'react'
import { Grid, Row, Col, FormControl, Button, OverlayTrigger, Popover } from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
import FontAwesome from 'react-fontawesome'
import fs from 'fs-extra'
import iconv from 'iconv-lite'
import jschardet from 'jschardet'
import path from 'path-extra'
import { remote, shell } from 'electron'

import i18next from 'views/env-parts/i18next'

import { oriTableTab } from '../reducers/tab'
import { dateToString } from '../../lib/utils'
import CONST from '../../lib/constant'

const { config, APPDATA_PATH } = window
const DATA_PATH = config.get("plugin.Akashic.dataPath", APPDATA_PATH)
const { dialog } = remote.require('electron')
const { openExternal } = shell

const translate = (locale, str) => i18next.getFixedT(locale, 'poi-plugin-akashic-records')(str)

const { __ } = window.i18n['poi-plugin-akashic-records']

function dateCmp(a, b) {
  if (isNaN(a[0]))
    a[0] = (new Date(a[0])).getTime()
  if (isNaN(b[0]))
    b[0] = (new Date(b[0])).getTime()
  return b[0] - a[0]
}

function duplicateRemoval(arr) {
  arr.sort(dateCmp)
  let lastTmp = 0
  return arr.filter((log) => {
    const tmp = dateToString(new Date(log[0]))
    if (tmp !== lastTmp) {
      lastTmp = tmp
      return true
    }
    return false
  })
}

function duplicateResourceRemoval(arr) {
  arr.sort(dateCmp)
  let lastTmp = 0
  return arr.filter((log) => {
    const tmpDate = new Date(log[0])
    const tmp = `${tmpDate.getFullYear()}/${tmpDate.getMonth()}/${tmpDate.getDate()}/${tmpDate.getHours()}`
    if (tmp !== lastTmp) {
      lastTmp = tmp
      return true
    }
    return false
  })
}

function toDateLabel(datetime) {
  return dateToString(new Date(datetime))
}

function translateTableTab(tableTabEn, locale) {
  const tableTab = {}
  for (const key in tableTabEn) {
    tableTab[key] = tableTabEn[key].map((tab) => translate(locale, tab))
  }
  return tableTab
}

function resolveFile(fileContent, tableTabEn = oriTableTab) {
  const tableTab = {}
  tableTab['en-US'] = { ...oriTableTab }
  for (const key of ['ja-JP', 'zh-CN', 'zh-TW']) {
    tableTab[key] = translateTableTab(tableTabEn, key)
  }
  for (const key in tableTab) {
    for (const type in tableTab[key]) {
      tableTab[key][type] = tableTab[key][type].slice(1).join(',')
    }
  }
  let logType = null
  const logs = fileContent.split("\n")
  logs[0] = logs[0].trim()
  let data = null

  switch (logs[0]) {
  case tableTab['en-US'][CONST.typeList.attack]:
  case tableTab['ja-JP'][CONST.typeList.attack]:
  case tableTab['zh-CN'][CONST.typeList.attack]:
  case tableTab['zh-TW'][CONST.typeList.attack]: {
    logType = CONST.typeList.attack
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 12) {
        return []
      }
      logItem[0] = (new Date(logItem[0])).getTime()
      return logItem
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case tableTab['en-US'][CONST.typeList.mission]:
  case tableTab['ja-JP'][CONST.typeList.mission]:
  case tableTab['zh-CN'][CONST.typeList.mission]:
  case tableTab['zh-TW'][CONST.typeList.mission]: {
    logType = CONST.typeList.mission
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 11)
        return []
      logItem[0] = (new Date(logItem[0])).getTime()
      return logItem
    })
    data = data.filter((log) => log.length === 11)
    break
  }
  case tableTab['en-US'][CONST.typeList.createShip]:
  case tableTab['ja-JP'][CONST.typeList.createShip]:
  case tableTab['zh-CN'][CONST.typeList.createShip]:
  case tableTab['zh-TW'][CONST.typeList.createShip]: {
    logType = CONST.typeList.createShip
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 12)
        return []
      logItem[0] = (new Date(logItem[0])).getTime()
      return logItem
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case tableTab['en-US'][CONST.typeList.createItem]:
  case tableTab['ja-JP'][CONST.typeList.createItem]:
  case tableTab['zh-CN'][CONST.typeList.createItem]:
  case tableTab['zh-TW'][CONST.typeList.createItem]: {
    logType = CONST.typeList.createItem
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 10)
        return []
      logItem[0] = (new Date(logItem[0])).getTime()
      return logItem
    })
    data = data.filter((log) => log.length === 10)
    break
  }
  case tableTab['en-US'][CONST.typeList.retirement]:
  case tableTab['ja-JP'][CONST.typeList.retirement]:
  case tableTab['zh-CN'][CONST.typeList.retirement]:
  case tableTab['zh-TW'][CONST.typeList.retirement]: {
    logType = CONST.typeList.retirement
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 4)
        return []
      logItem[0] = (new Date(logItem[0])).getTime()
      return logItem
    })
    data = data.filter((log) => log.length === 4)
    break
  }
  case tableTab['en-US'][CONST.typeList.resource]:
  case tableTab['ja-JP'][CONST.typeList.resource]:
  case tableTab['zh-CN'][CONST.typeList.resource]:
  case tableTab['zh-TW'][CONST.typeList.resource]: {
    logType = CONST.typeList.resource
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 9)
        return []
      logItem[0] = (new Date(logItem[0])).getTime()
      return logItem
    })
    data = data.filter((log) => log.length === 9)
    break
  }

  // 航海日志扩张版
  case "No.,日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)": {
    logType = CONST.typeList.attack
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 14)
        return []
      const retData = [(new Date(logItem[1].replace(/-/g, "/"))).getTime()]
      const tmpArray = logItem[3].match(/:\d+(-\d+)?/g)
      retData.push`${logItem[2]}(${tmpArray[0].substring(1)})`
      retData.push(`${tmpArray[1].substring(1)}(${logItem[4] === 'ボス' ? 'Boss点' : '道中'})`)
      retData.push(logItem[4] === '出撃' ? '出撃' : '進撃')
      retData.push(logItem[5], logItem[6], logItem[8])
      retData.push(logItem[9] === '' ? '无' : '有')
      retData.push(logItem[10], logItem[11], logItem[12], logItem[13])
      return retData
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "No.,日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,ドロップアイテム,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)": {
    logType = CONST.typeList.attack
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 15)
        return []
      const retData = [(new Date(logItem[1].replace(/-/g, "/"))).getTime()]
      const tmpArray = logItem[3].match(/:\d+(-\d+)?/g)
      retData.push(`${logItem[2]}(${tmpArray[0].substring(1)})`)
      retData.push(`${tmpArray[1].substring(1)}(${logItem[4] === 'ボス' ? 'Boss点' : '道中'})`)
      retData.push(logItem[4] === '出撃' ? '出撃' : '進撃')
      retData.push(logItem[5], logItem[6])
      retData.push(`${logItem[8]}${(logItem[8] != '' && logItem[9] != '') ? ' & ' : ''}${logItem[9]}`)
      retData.push(logItem[10] === '' ? '无' : '有')
      retData.push(logItem[11], logItem[12], logItem[13], logItem[14])
      return retData
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)": {
    logType = CONST.typeList.attack
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 13)
        return []
      const retData = [(new Date(logItem[0].replace(/-/g, "/"))).getTime()]
      const tmpArray = logItem[2].match(/:\d+(-\d+)?/g)
      retData.push(`${logItem[1]}(${tmpArray[0].substring(1)})`)
      retData.push(`${tmpArray[1].substring(1)}(${logItem[3] === 'ボス' ? 'Boss点' : '道中'})`)
      retData.push(logItem[3] === '出撃' ? '出撃' : '進撃')
      retData.push(logItem[4], logItem[5], logItem[7])
      retData.push(logItem[8] === '' ? '无' : '有')
      retData.push(logItem[9], logItem[10], logItem[11], logItem[12])
      return retData
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "日付,海域,マス,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,味方艦1,味方艦1HP,味方艦2,味方艦2HP,味方艦3,味方艦3HP,味方艦4,味方艦4HP,味方艦5,味方艦5HP,味方艦6,味方艦6HP,敵艦1,敵艦1HP,敵艦2,敵艦2HP,敵艦3,敵艦3HP,敵艦4,敵艦4HP,敵艦5,敵艦5HP,敵艦6,敵艦6HP": {
    logType = CONST.typeList.attack
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 31)
        return []
      const retData = [(new Date(logItem[0].replace(/-/g, "/"))).getTime()]
      if (!isNaN(logItem[2])) {
        retData.push(logItem[1], logItem[2])
        retData.push('')
        retData.push(logItem[3], logItem[4], logItem[6])
        retData.push('')
        retData.push(logItem[7], '', '', '')
      } else {
        const tmpArray = logItem[2].match(/:\d+(-\d+)?/g)
        retData.push(`${logItem[1]}(${tmpArray[0].substring(1)})`)
        retData.push(`${tmpArray[1].substring(1)}(${logItem[2].indexOf('ボス') > -1 ? 'Boss点' : '道中'})`)
        retData.push('')
        retData.push(logItem[3], logItem[4], logItem[6])
        retData.push('')
        retData.push(logItem[7], '', '', '')
      }
      return retData
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "日付,結果,遠征,燃料,弾薬,鋼材,ボーキ": {
    logType = CONST.typeList.mission
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 7)
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        logItem[2],
        logItem[1],
        logItem[3],
        logItem[4],
        logItem[5],
        logItem[6],
        '', '', '', '',
      ]
    })
    data = data.filter((log) => log.length === 11)
    break
  }
  case "No.,日付,結果,遠征,燃料,弾薬,鋼材,ボーキ,アイテム1,個数,アイテム2,個数": {
    logType = CONST.typeList.mission
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 12)
        return []
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        logItem[3],
        logItem[2],
        logItem[4],
        logItem[5],
        logItem[6],
        logItem[7],
        logItem[8],
        logItem[9],
        logItem[10],
        logItem[11],
      ]
    })
    data = data.filter((log) => log.length === 11)
    break
  }
  case "日付,結果,遠征,燃料,弾薬,鋼材,ボーキ,アイテム1,個数,アイテム2,個数": {
    logType = CONST.typeList.mission
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 11)
        return []
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        logItem[2],
        logItem[1],
        logItem[3],
        logItem[4],
        logItem[5],
        logItem[6],
        logItem[7],
        logItem[8],
        logItem[9],
        logItem[10],
      ]
    })
    data = data.filter((log) => log.length === 11)
    break
  }
  case "No.,日付,種類,名前,艦種,燃料,弾薬,鋼材,ボーキ,開発資材,空きドック,秘書艦,司令部Lv": {
    logType = CONST.typeList.createShip
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 13)
        return []
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        logItem[2] === '通常艦建造' ? '普通建造' : '大型建造',
        ...logItem.slice(3, 13),
      ]
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "日付,種類,名前,艦種,燃料,弾薬,鋼材,ボーキ,開発資材,空きドック,秘書艦,司令部Lv": {
    logType = CONST.typeList.createShip
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 12)
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        logItem[1] === '通常艦建造' ? '普通建造' : '大型建造',
        ...logItem.slice(2, 12),
      ]
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "No.,日付,開発装備,種別,燃料,弾薬,鋼材,ボーキ,秘書艦,司令部Lv": {
    logType = CONST.typeList.createItem
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 10)
        return []
      const retData = [(new Date(logItem[1].replace(/-/g, "/"))).getTime()]
      if (logItem[2] === "失敗") {
        retData.push('失败', '', '')
      } else {
        retData.push('成功', logItem[2], logItem[3])
      }
      retData.push(...logItem.slice(4, 10))
      return retData
    })
    data = data.filter((log) => log.length === 10)
    break
  }
  case "日付,開発装備,種別,燃料,弾薬,鋼材,ボーキ,秘書艦,司令部Lv": {
    logType = CONST.typeList.createItem
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 9)
        return []
      const retData = [(new Date(logItem[0].replace(/-/g, "/"))).getTime()]
      if (logItem[1] === "失敗") {
        retData.push('失败', '', '')
      } else {
        retData.push('成功', logItem[1], logItem[2])
      }
      retData.push(...logItem.slice(3, 9))
      return retData
    })
    data = data.filter((log) => log.length === 10)
    break
  }
  case "日付,直前のイベント,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材,改修資材": {
    logType = CONST.typeList.resource
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if ((logItem.length !== 10) && (logItem.length !== 12))
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(2, 6),
        logItem[7],
        logItem[6],
        logItem[8],
        logItem[9],
      ]
    })
    data = data.filter((log) => log.length === 9)
    break
  }
  case "日付,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材,改修資材": {
    logType = CONST.typeList.resource
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if ((logItem.length !== 9) && (logItem.length !== 11))
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(1, 5),
        logItem[6],
        logItem[5],
        logItem[7],
        logItem[8],
      ]
    })
    data = data.filter((log) => log.length === 9)
    break
  }
  case "日付,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材": {
    logType = CONST.typeList.resource
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 8)
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(1, 5),
        logItem[6],
        logItem[5],
        logItem[7],
        '0',
      ]
    })
    data = data.filter((log) => log.length === 9)
    break
  }
  case "日付,種別,個別ID,名前,原因": {
    logType = CONST.typeList.retirement
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 5)
        return []
      if (logItem[1] === "艦娘")
        return [
          (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
          logItem[4].length > 4 ? logItem[4].substring(3).trim() : logItem[4].trim(),
          '',
          logItem[3],
        ]
      else return []
    })
    data = data.filter((log) => log.length === 4)
    break
  }

  // KCV yuyuvn版
  case "Date,Result,Operation,Enemy Fleet,Rank": {
    logType = CONST.typeList.attack
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 6)
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        logItem[2],
        '',
        '',
        logItem[4],
        logItem[3],
        logItem[1],
        '', '', '', '', '',
      ]
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "Date,Result,Secretary,Secretary level,Fuel,Ammo,Steel,Bauxite": {
    logType = CONST.typeList.createItem
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 9)
        return []
      const retData = [(new Date(logItem[0].replace(/-/g, "/"))).getTime()]
      if (logItem[1] === 'Penguin') {
        retData.push('失败', '', '')
      } else {
        retData.push('成功', logItem[1], '')
      }
      retData.push(...logItem.slice(4, 8), `${logItem[2]}(Lv.${logItem[3]})`, '')
      return retData
    })
    data = data.filter((log) => log.length === 10)
    break
  }
  case "Date,Result,Secretary,Secretary level,Fuel,Ammo,Steel,Bauxite,# of Build Materials": {
    logType = CONST.typeList.createShip
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 10)
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        logItem[4] < 1000 ? '普通建造' : '大型建造',
        logItem[1],
        '',
        ...logItem.slice(4, 9),
        '',
        `${logItem[2]}(Lv.${logItem[3]})`,
        '',
      ]
    })
    data = data.filter((log) => log.length === 12)
    break
  }
  case "Date,Fuel,Ammunition,Steel,Bauxite,DevKits,Buckets,Flamethrowers": {
    logType = CONST.typeList.resource
    data = logs.slice(1).map((logItem) => {
      logItem = logItem.split(',')
      if (logItem.length !== 9)
        return []
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(1, 5),
        logItem[7],
        logItem[6],
        logItem[5],
        '0',
      ]
    })
    data = data.filter((log) => log.length === 9)
    break
  }
  default: {
    const e = new Error()
    e.message = __("The encoding or file is not supported")
    throw (e)
  }
  }
  return {
    logType: logType,
    data: data,
    message: '',
  }
}

class AdvancedModule extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      typeChoosed: '出击',
      forceMinimize: config.get("plugin.Akashic.forceMinimize", false),
    }
  }

  handleClickCheckbox = () => {
    config.set("plugin.Akashic.forceMinimize", !this.state.forceMinimize)
    this.setState({ forceMinimize: !this.state.forceMinimize })
  }

  handleSetType = () => {
    this.setState({ typeChoosed: findDOMNode(this.type).value })
  }

  showMessage(message) {
    dialog.showMessageBox({
      type: 'info',
      buttons: ['OK'],
      title: 'Warning',
      message: message,
    })
  }

  saveLogHandle = () => {
    const nickNameId = window._nickNameId
    let logType = null
    let data = null
    if (nickNameId && nickNameId !== 0) {
      switch (this.state.typeChoosed) {
      case '出击':
        logType = CONST.typeList.attack
        data = this.props.attackData
        break
      case '远征':
        logType = CONST.typeList.mission
        data = this.props.missionData
        break
      case '建造':
        logType = CONST.typeList.createShip
        data = this.props.createShipData
        break
      case '开发':
        logType = CONST.typeList.createItem
        data = this.props.createItemData
        break
      case '除籍':
        logType = CONST.typeList.retirement
        data = this.props.retirementData
        break
      case '资源':
        logType = CONST.typeList.resource
        data = this.props.resourceData
        break
      default:
        this.showMessage('发生错误！请报告开发者')
        return
      }

      let codeType = 'utf8'
      if (process.platform === 'win32') {
        if (window.language === 'ja-JP') {
          codeType = 'shiftjis'
        } else if (window.language === 'zh-CN' || window.language === 'zh-TW') {
          codeType = 'GB2312'
        }
      }

      const filename = (dialog.showSaveDialogSync ? dialog.showSaveDialogSync : dialog.showSaveDialog)({
        title: `保存${this.state.typeChoosed}记录`,
        defaultPath: `${nickNameId}-${logType}.csv`,
      })
      if (filename != null) {
        const saveTableTab = this.props.tableTab[logType].map((tab) => __(tab))
        let saveData = `${saveTableTab.slice(1).join(',')}\n`
        for (const item of data) {
          saveData = `${saveData}${toDateLabel(item[0])},${item.slice(1).join(',')}\n`
        }
        if (codeType === 'GB2312')
          saveData = iconv.encode(saveData, 'GB2312')
        fs.writeFile(filename, saveData, (err) => {
          if (err) {
            console.error('[ERR] Save data error')
          }
        })
      }
    } else {
      this.showMessage('未找到相应的提督！是不是还没登录？')
    }
  }

  importLogHandle = () => {
    const nickNameId = window._nickNameId
    if (nickNameId == null || nickNameId === 0) {
      this.showMessage('请先登录再导入数据！')
      return
    }
    const filename = (dialog.showOpenDialogSync ? dialog.showOpenDialogSync : dialog.showOpenDialog)({
      title: `导入${this.state.typeChoosed}记录`,
      filters: [
        {
          name: "csv file",
          extensions: ['csv'],
        },
      ],
      properties: ['openFile'],
    })
    console.log(filename)
    if (filename != null && filename[0] != null) {
      try {
        fs.accessSync(filename[0], fs.R_OK)
        const fileContentBuffer = fs.readFileSync(filename[0])
        const codeType = jschardet.detect(fileContentBuffer, {minimumThreshold: 0.1}).encoding
        let fileContent = null
        switch (codeType) {
        case 'UTF-8':
          fileContent = fileContentBuffer.toString()
          break
        case 'GB2312':
        case 'GB18030':
        case 'GBK':
          fileContent = iconv.decode(fileContentBuffer, 'GBK')
          break
        case 'SHIFT_JIS':
          fileContent = iconv.decode(fileContentBuffer, 'shiftjis')
          break
        default:
          fileContent = iconv.decode(fileContentBuffer, 'shiftjis')
        }
        if (fileContent == null) {
          const e = new Error()
          e.message = __("The encoding or file is not supported")
          throw (e)
        }
        const { logType, data } = resolveFile(fileContent)
        let hint = null
        let oldData = null
        switch (logType) {
        case CONST.typeList.attack:
          hint = '出击'
          oldData = duplicateRemoval(this.props.attackData)
          break
        case CONST.typeList.mission:
          hint = '远征'
          oldData = duplicateRemoval(this.props.missionData)
          break
        case CONST.typeList.createShip:
          hint = '建造'
          oldData = duplicateRemoval(this.props.createShipData)
          break
        case CONST.typeList.createItem:
          hint = '开发'
          oldData = duplicateRemoval(this.props.createItemData)
          break
        case CONST.typeList.retirement:
          hint = '除籍'
          oldData = duplicateRemoval(this.props.retirementData)
          break
        case CONST.typeList.resource:
          hint = '资源'
          oldData = duplicateRemoval(this.props.resourceData)
          break
        default:
          throw "Type Error!"
        }
        // oldData = duplicateRemoval dataManager.getRawData logType
        const oldLength = oldData.length
        let newData = oldData.concat(data)
        if (logType === CONST.typeList.resource)
          newData = duplicateResourceRemoval(newData)
        else
          newData = duplicateRemoval(newData)
        const newLength = newData.length
        fs.emptyDirSync(path.join(DATA_PATH, 'akashic-records', "tmp"))
        let saveData = ''
        for (const item of newData) {
          saveData = `${saveData}${item.join(',')}\n`
        }
        fs.writeFile(path.join(DATA_PATH, 'akashic-records', "tmp", "data"), saveData)
        fs.emptyDirSync(path.join(DATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase()))
        fs.writeFile(path.join(DATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase(), "data"), saveData)
        this.props.onLogsReset(newData, logType)
        this.showMessage(`新导入${newLength - oldLength}条${hint}记录！`)
      } catch (e) {
        this.showMessage(e.message)
        throw e
      }
    }
    // console.log "import log"
  }

  render() {
    return (
      <div className="advancedmodule">
        <Grid>
          <Row className="title">
            <Col xs={12}>
              <span style={{ fontSize: "24px" }}>{__("Importing/Exporting")}</span>
              <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                <Popover id="about-message" title={__("About")}>
                  <h5>{__("Exporting")}</h5>
                  <ul>
                    <li>{__("Choose the data you want to export")}</li>
                    <li>{__("The file's encoding is determined by the OS. Win -> GB2312, Others -> utf8")}</li>
                  </ul>
                  <h5>{__("Importing")}</h5>
                  <ul>
                    <li>{__("Support List")}
                      <ul>
                        <li>阿克夏记录</li>
                        <li>航海日誌 拡張版 (某些版本)</li>
                        <li>KCV-yuyuvn</li>
                      </ul>
                    </li>
                  </ul>
                  <h5>{__("Need more?")}</h5>
                  <ul>
                    <li>
                      <a onClick={openExternal.bind(this, "https://github.com/poooi/plugin-Akashic-records/issues/new")}>{__("open a new issue on github")}</a>
                    </li>
                    <li style={{ whiteSpace: "nowrap" }}>{__("or email")} jenningswu@gmail.com </li>
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
              <FormControl
                componentClass="select"
                ref={(ref) => {
                  this.type = ref
                }}
                value={this.state.typeChoosed}
                onChange={() => {
                  this.handleSetType()
                }}>
                <option key={0} value={'出击'}>{__("Sortie")}</option>
                <option key={1} value={'远征'}>{__("Expedition")}</option>
                <option key={2} value={'建造'}>{__("Construction")}</option>
                <option key={3} value={'开发'}>{__("Development")}</option>
                <option key={4} value={'除籍'}>{__("Retirement")}</option>
                <option key={5} value={'资源'}>{__("Resource")}</option>
              </FormControl>
            </Col>
            <Col xs={4}>
              <Button bsStyle='primary' style={{ width: '100%' }} onClick={this.saveLogHandle}>{__("Export")}</Button>
            </Col>
            <Col xs={4}>
              <Button bsStyle='primary' style={{ width: '100%' }} onClick={this.importLogHandle}>{__("Import")}</Button>
            </Col>
          </Row>
          <Row style={{ marginTop: "10px" }}>
            <Col xs={12}>
              <a style={{ marginLeft: "30px" }} onClick={openExternal.bind(this, "https://github.com/yudachi/plugin-Akashic-records")}>{__("Bug Report & Suggestion")}</a>
            </Col>
          </Row>
        </Grid>
      </div>
    )
  }
}

export default AdvancedModule
