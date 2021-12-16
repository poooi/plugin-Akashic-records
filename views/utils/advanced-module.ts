import fs from 'fs-extra'
import iconv from 'iconv-lite'
import { detect } from 'jschardet'
import path from 'path'
// @ts-expect-error keeping importing remote for compat
import { remote } from 'electron'
import { get } from 'lodash'

import { DataRow } from '../../lib/data-co-manager'
import CONST from '../../lib/constant'
import { dateToString } from '../../lib/utils'
import { pluginDataSelector } from '../selectors'
import { getTabs, DataType } from '../../views/reducers/tab'
import { IState } from 'views/utils/selectors'

const { dialog } = remote
const { config, APPDATA_PATH } = window
const DATA_PATH = config.get("plugin.Akashic.dataPath", APPDATA_PATH)

function getColCount(type: DataType) {
  return getTabs(type).length - 1
}

function dateCmp(a: DataRow, b: DataRow): number {
  const timeA = Number.isNaN(a[0]) ? (new Date(a[0])).getTime() : a[0]
  const timeB = Number.isNaN(b[0]) ? (new Date(b[0])).getTime() : b[0]
  return (new Date(timeA)).toUTCString() === (new Date(timeB)).toUTCString() ? 0 : timeB - timeA
}

function fullCmp(a: DataRow, b: DataRow): number {
  const dateCmpRet = dateCmp(a, b)
  if (dateCmpRet !== 0) return dateCmpRet
  const stringA = a.slice(1).toString()
  const stringB = b.slice(1).toString()
  return stringA > stringB ? -1 : stringA < stringB ? 1 : 0
}

function duplicateRemoval(arr: DataRow[]) {
  arr.sort(fullCmp)
  return arr.filter((log, index) => {
    if (index > 0) {
      return fullCmp(log, arr[index - 1]) !== 0
    }
    return true
  })
}

function duplicateResourceRemoval(arr: DataRow[]) {
  arr.sort(fullCmp)
  let lastTmp = ''
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

function toDateLabel(datetime: string | number) {
  return dateToString(new Date(datetime))
}

function getDataTypeTitle(type: DataType) {
  return getTabs(type).slice(1).join(',')
}

function getDataTypeFromTitle(title: string): DataType {
  switch (title) {
  case getDataTypeTitle('attack'):
    return 'attack'
  case getDataTypeTitle('mission'):
    return 'mission'
  case getDataTypeTitle('createitem'):
    return 'createitem'
  case getDataTypeTitle('createship'):
    return 'createship'
  case getDataTypeTitle('resource'):
    return 'resource'
  case getDataTypeTitle('retirement'):
    return 'retirement'
  default:
    return 'attack'
  }
}

function resolveFile(fileContent: string) {
  const [rawTitleLine, ...logs] = fileContent.split("\n")
  const titleLine = rawTitleLine.trim()
  let data: DataRow[]
  let logType: DataType
  switch (titleLine) {
  case getDataTypeTitle('attack'):
  case getDataTypeTitle('mission'):
  case getDataTypeTitle('createitem'):
  case getDataTypeTitle('createship'):
  case getDataTypeTitle('resource'):
  case getDataTypeTitle('retirement'): {
    logType = getDataTypeFromTitle(titleLine)
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      return [
        (new Date(logItem[0])).getTime(),
        ...logItem.slice(1),
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  // 航海日志扩张版
  case "No.,日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)": {
    logType = CONST.typeList.attack as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 14) {
        return [0] as DataRow
      }
      const tmpArray = logItem[3].match(/:\d+(-\d+)?/g) ?? ''
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        `${logItem[2]}(${tmpArray[0].substring(1)})`,
        `${tmpArray[1].substring(1)}(${logItem[4] === 'ボス' ? 'Boss点' : '道中'})`,
        logItem[4] === '出撃' ? '出撃' : '進撃',
        logItem[5],
        logItem[6],
        logItem[8],
        logItem[9] === '' ? '无' : '有',
        logItem[10],
        logItem[11],
        logItem[12],
        logItem[13],
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "No.,日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,ドロップアイテム,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)": {
    logType = CONST.typeList.attack as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 15) {
        return [0] as DataRow
      }
      const tmpArray = logItem[3].match(/:\d+(-\d+)?/g) || ''
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        `${logItem[2]}(${tmpArray[0].substring(1)})`,
        `${tmpArray[1].substring(1)}(${logItem[4] === 'ボス' ? 'Boss点' : '道中'})`,
        logItem[4] === '出撃' ? '出撃' : '進撃',
        logItem[5],
        logItem[6],
        `${logItem[8]}${(logItem[8] != '' && logItem[9] != '') ? ' & ' : ''}${logItem[9]}`,
        logItem[10] === '' ? '无' : '有',
        logItem[11],
        logItem[12],
        logItem[13],
        logItem[14],
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)": {
    logType = CONST.typeList.attack as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 13) {
        return [0] as DataRow
      }
      const tmpArray = logItem[2].match(/:\d+(-\d+)?/g) || ''
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        `${logItem[1]}(${tmpArray[0].substring(1)})`,
        `${tmpArray[1].substring(1)}(${logItem[3] === 'ボス' ? 'Boss点' : '道中'})`,
        logItem[3] === '出撃' ? '出撃' : '進撃',
        logItem[4],
        logItem[5],
        logItem[7],
        logItem[8] === '' ? '无' : '有',
        logItem[9],
        logItem[10],
        logItem[11],
        logItem[12],
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,海域,マス,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,味方艦1,味方艦1HP,味方艦2,味方艦2HP,味方艦3,味方艦3HP,味方艦4,味方艦4HP,味方艦5,味方艦5HP,味方艦6,味方艦6HP,敵艦1,敵艦1HP,敵艦2,敵艦2HP,敵艦3,敵艦3HP,敵艦4,敵艦4HP,敵艦5,敵艦5HP,敵艦6,敵艦6HP": {
    logType = CONST.typeList.attack as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 31) {
        return [0] as DataRow
      }
      const tmpArray = logItem[2].match(/:\d+(-\d+)?/g) || ''
      const restData = !isNaN(parseInt(logItem[2])) ? [
        logItem[1],
        logItem[2],
        '',
        logItem[3],
        logItem[4],
        logItem[6],
        '',
        logItem[7],
        '',
        '',
        '',
      ] : [
        `${logItem[1]}(${tmpArray[0].substring(1)})`,
        `${tmpArray[1].substring(1)}(${logItem[2].indexOf('ボス') > -1 ? 'Boss点' : '道中'})`,
        '',
        logItem[3],
        logItem[4],
        logItem[6],
        '',
        logItem[7],
        '',
        '',
        '',
      ]
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        ...restData,
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,結果,遠征,燃料,弾薬,鋼材,ボーキ": {
    logType = CONST.typeList.mission as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 7)
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        logItem[2],
        logItem[1],
        logItem[3],
        logItem[4],
        logItem[5],
        logItem[6],
        '', '', '', '',
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "No.,日付,結果,遠征,燃料,弾薬,鋼材,ボーキ,アイテム1,個数,アイテム2,個数": {
    logType = CONST.typeList.mission as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 12)
        return [0] as DataRow
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
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,結果,遠征,燃料,弾薬,鋼材,ボーキ,アイテム1,個数,アイテム2,個数": {
    logType = CONST.typeList.mission as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 11)
        return [0] as DataRow
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
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "No.,日付,種類,名前,艦種,燃料,弾薬,鋼材,ボーキ,開発資材,空きドック,秘書艦,司令部Lv": {
    logType = CONST.typeList.createShip as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 13)
        return [0] as DataRow
      return [
        (new Date(logItem[1].replace(/-/g, "/"))).getTime(),
        logItem[2] === '通常艦建造' ? '普通建造' : '大型建造',
        ...logItem.slice(3, 13),
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,種類,名前,艦種,燃料,弾薬,鋼材,ボーキ,開発資材,空きドック,秘書艦,司令部Lv": {
    logType = CONST.typeList.createShip as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 12)
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        logItem[1] === '通常艦建造' ? '普通建造' : '大型建造',
        ...logItem.slice(2, 12),
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "No.,日付,開発装備,種別,燃料,弾薬,鋼材,ボーキ,秘書艦,司令部Lv": {
    logType = CONST.typeList.createItem as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 10)
        return [0] as DataRow
      const retData = [(new Date(logItem[1].replace(/-/g, "/"))).getTime()] as DataRow
      if (logItem[2] === "失敗") {
        retData.push('失败', '', '')
      } else {
        retData.push('成功', logItem[2], logItem[3])
      }
      retData.push(...logItem.slice(4, 10))
      return retData
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,開発装備,種別,燃料,弾薬,鋼材,ボーキ,秘書艦,司令部Lv": {
    logType = CONST.typeList.createItem as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 9)
        return [0] as DataRow
      const retData = [(new Date(logItem[0].replace(/-/g, "/"))).getTime()] as DataRow
      if (logItem[1] === "失敗") {
        retData.push('失败', '', '')
      } else {
        retData.push('成功', logItem[1], logItem[2])
      }
      retData.push(...logItem.slice(3, 9))
      return retData
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,直前のイベント,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材,改修資材": {
    logType = CONST.typeList.resource as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if ((logItem.length !== 10) && (logItem.length !== 12))
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(2, 6),
        logItem[7],
        logItem[6],
        logItem[8],
        logItem[9],
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材,改修資材": {
    logType = CONST.typeList.resource as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if ((logItem.length !== 9) && (logItem.length !== 11))
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(1, 5),
        logItem[6],
        logItem[5],
        logItem[7],
        logItem[8],
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材": {
    logType = CONST.typeList.resource as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 8)
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(1, 5),
        logItem[6],
        logItem[5],
        logItem[7],
        '0',
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "日付,種別,個別ID,名前,原因": {
    logType = CONST.typeList.retirement as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 5)
        return [0] as DataRow
      if (logItem[1] === "艦娘")
        return [
          (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
          logItem[4].length > 4 ? logItem[4].substring(3).trim() : logItem[4].trim(),
          '',
          logItem[3],
        ] as DataRow
      else return [0] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  // KCV yuyuvn版
  case "Date,Result,Operation,Enemy Fleet,Rank": {
    logType = CONST.typeList.attack as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 6)
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        logItem[2],
        '',
        '',
        logItem[4],
        logItem[3],
        logItem[1],
        '', '', '', '', '',
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "Date,Result,Secretary,Secretary level,Fuel,Ammo,Steel,Bauxite": {
    logType = CONST.typeList.createItem as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 9)
        return [0] as DataRow
      const retData = [(new Date(logItem[0].replace(/-/g, "/"))).getTime()] as DataRow
      if (logItem[1] === 'Penguin') {
        retData.push('失败', '', '')
      } else {
        retData.push('成功', logItem[1], '')
      }
      retData.push(...logItem.slice(4, 8), `${logItem[2]}(Lv.${logItem[3]})`, '')
      return retData
    }).filter(log => log.length === colCount)
    break
  }
  case "Date,Result,Secretary,Secretary level,Fuel,Ammo,Steel,Bauxite,# of Build Materials": {
    logType = CONST.typeList.createShip as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 10)
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        parseInt(logItem[4]) < 1000 ? '普通建造' : '大型建造',
        logItem[1],
        '',
        ...logItem.slice(4, 9),
        '',
        `${logItem[2]}(Lv.${logItem[3]})`,
        '',
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  case "Date,Fuel,Ammunition,Steel,Bauxite,DevKits,Buckets,Flamethrowers": {
    logType = CONST.typeList.resource as DataType
    const colCount = getColCount(logType)
    data = logs.map(rawLog => {
      const logItem = rawLog.split(',')
      if (logItem.length !== 9)
        return [0] as DataRow
      return [
        (new Date(logItem[0].replace(/-/g, "/"))).getTime(),
        ...logItem.slice(1, 5),
        logItem[7],
        logItem[6],
        logItem[5],
        '0',
      ] as DataRow
    }).filter(log => log.length === colCount)
    break
  }
  default: {
    const e = new Error()
    e.message = "The encoding or file is not supported"
    throw (e)
  }
  }

  return {
    logType: logType,
    data: data,
    message: '',
  }
}

function getDataByType(type: DataType): DataRow[] {
  return get(pluginDataSelector(window.getStore() as IState), [type, 'data'], [])
}

let dialogOpened = false

export async function saveLog(
  typeChoosed: DataType,
  showMessage: (str: string) => Promise<void>,
  t: (str: string, obj?: object) => string
) {
  if (dialogOpened) {
    return
  }
  const nickNameId = window.getStore('info.basic.api_nickname_id') as string
  if (nickNameId && parseInt(nickNameId) !== 0) {
    const data = getDataByType(typeChoosed)
    dialogOpened = true
    const { filePath } = await dialog.showSaveDialog({
      title: t('Export {{type}} records', {type: typeChoosed}),
      defaultPath: `${nickNameId}-${typeChoosed}.csv`,
    })
    dialogOpened = false
    if (filePath != null) {
      const saveTableTab = getTabs(typeChoosed)
      const saveDataList = [`${saveTableTab.slice(1).join(',')}`]
      for (const item of data) {
        saveDataList.push(`${toDateLabel(item[0])},${item.slice(1).join(',')}`)
      }
      const saveData = saveDataList.join('\n')
      fs.writeFile(filePath, saveData, (err) => {
        if (err) {
          console.error('[ERR] Save data error')
        }
      })
    }
  } else {
    await showMessage(t('User not found. Please ensure you\'re logged in'))
  }
}

export async function importLog(
  onLogsReset: (data: DataRow[], logType: DataType) => void,
  showMessage: (str: string) => Promise<void>,
  t: (str: string, obj?: object) => string
) {
  const nickNameId = window.getStore('info.basic.api_nickname_id') as string
  if (nickNameId == null || parseInt(nickNameId) === 0) {
    await showMessage(t("Please log in game before import data"))
    return
  }
  const { filePaths } = await dialog.showOpenDialog({
    title: t('Import records'),
    filters: [
      {
        name: "csv file",
        extensions: ['csv'],
      },
    ],
    properties: ['openFile'],
  })
  console.warn(`Open ${filePaths[0]}`)
  if (filePaths != null && filePaths[0] != null) {
    try {
      fs.accessSync(filePaths[0], fs.constants.R_OK)
      const fileContentBuffer = fs.readFileSync(filePaths[0])
      const codeType = detect(fileContentBuffer, {minimumThreshold: 0.1}).encoding
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
        e.message = t("The encoding or file is not supported")
        throw (e)
      }
      const { logType, data } = resolveFile(fileContent)
      const hint = t(logType)
      const oldData = getDataByType(logType)
      const oldLength = oldData.length
      let newData = oldData.concat(data)
      if (logType === CONST.typeList.resource)
        newData = duplicateResourceRemoval(newData)
      else
        newData = duplicateRemoval(newData)
      const newLength = newData.length
      fs.emptyDirSync(path.join(DATA_PATH, 'akashic-records', "tmp"))
      const saveData = []
      for (const item of newData) {
        saveData.push(item.join(','))
      }
      await fs.writeFile(path.join(DATA_PATH, 'akashic-records', "tmp", "data"), saveData.join('\n'))
      fs.emptyDirSync(path.join(DATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase()))
      await fs.writeFile(path.join(DATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase(), "data"), saveData.join('\n'))
      onLogsReset(newData, logType)
      showMessage(t('Imported {{count}} {{hint}} records', { count: newLength - oldLength, hint }))
    } catch (e) {
      showMessage((e as Error).message)
      throw e
    }
  }
}
