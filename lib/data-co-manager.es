"use strict"

import fs from 'fs-extra'
import glob from 'glob'
import path from 'path-extra'

import CONST from '../lib/constant'

const { APPDATA_PATH, config } = window

const DATA_PATH = config.get("plugin.Akashic.dataPath", APPDATA_PATH)

class DataCoManager {
  constructor() {
    this.nickNameId = 0
  }

  setNickNameId(id) {
    this.nickNameId = id
  }

  async _getDataAccordingToNameId(id, type) {
    const testNum = /^[1-9]+[0-9]*$/
    let datalogs = glob.sync(path.join(DATA_PATH, 'akashic-records', this.nickNameId.toString(), type, '*'))
    datalogs = datalogs.map(async (filePath) => {
      try {
        const fileContent = await fs.readFile(filePath, 'utf8')
        let logs = fileContent.split("\n")
        logs = logs.map((logItem) => {
          logItem = logItem.split(',')
          if (testNum.test(logItem[0])) {
            logItem[0] = parseInt(logItem[0])
          }
          return logItem
        })
        return logs.filter((log) => log.length > 2)
      } catch (e) {
        if (process.env.DEBUG) {
          console.warn(`Read and decode file:${filePath} error!${e.toString()}`)
        }
        return []
      }
    })
    datalogs = await Promise.all(datalogs)
    datalogs = datalogs.reduce((ret, cur) => ret.concat(cur), [])
    datalogs.reverse()
    datalogs.sort((a, b) => {
      if (isNaN(a[0]))
        a[0] = (new Date(a[0])).getTime()
      if (isNaN(b[0]))
        b[0] = (new Date(b[0])).getTime()
      return b[0] - a[0]
    })
    return datalogs
  }

  async initializeData() {
    const data = {}
    for (const k of Object.keys(CONST.typeList)) {
      const type = CONST.typeList[k]
      data[type] = await this._getDataAccordingToNameId(this.nickNameId, type)
    }
    return data
  }

  saveLog(type, log) {
    log = log.map(item => typeof item == 'string' ? item.trim() : item)
    fs.ensureDirSync(path.join(DATA_PATH, 'akashic-records', this.nickNameId.toString(), type))
    if (type === 'attack') {
      const date = new Date(log[0])
      const year = date.getFullYear()
      const month = date.getMonth() < 9 ?
        `0${date.getMonth() + 1}` : `${date.getMonth() + 1}`
      const day = date.getDate() < 10 ?
        `0${date.getDate()}` : `${date.getDate()}`
      fs.appendFile(
        path.join(DATA_PATH, 'akashic-records', this.nickNameId.toString(),
          type, `${year}${month}${day}`),
        `${log.join(',')}\n`,
        'utf8',
        (err) => {
          if (err && process.env.DEBUG)
            // eslint-disable-next-line
            console.error("Write attack-log file error!");
        }
      )
    } else {
      fs.appendFile(path.join(DATA_PATH, 'akashic-records', this.nickNameId.toString(), type, "data"),
        `${log.join(',')}\n`, 'utf8', (err) => {
          if (err && process.env.DEBUG)
            console.error(`Write ${type}-log file error!`)
        }
      )
    }
    if (process.env.DEBUG) {
      // eslint-disable-next-line
      console.log(`save one ${type} log`)
    }
  }
}

export default new DataCoManager()
