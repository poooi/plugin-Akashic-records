import fs from 'fs-extra'
import glob from 'glob'
import path from 'path'

import CONST from './constant'

const { APPDATA_PATH, config } = window

const DATA_PATH = config.get("plugin.Akashic.dataPath", APPDATA_PATH)

export type DataRow = [number, ...(number | string)[]]
export type DataTable = DataRow[]
export interface Data {
  [key: string]: DataTable
}

class DataCoManager {
  private nickNameId = ''

  setNickNameId(id: string) {
    this.nickNameId = id
  }

  getParsedTimestamp(ts: string): number {
    const fixedTs = ts.length > 13 ? ts.slice(0, 13) : ts
    if (/^[1-9]+[0-9]*$/.test(fixedTs)) {
      return parseInt(fixedTs)
    } else {
      return 0
    }
  }

  async getData(type: string): Promise<DataTable> {
    const datalogsPromise = glob.sync(
      path.join(DATA_PATH, 'akashic-records', this.nickNameId, type, '*')
    ).map(async (filePath) => {
      try {
        const fileContent = await fs.readFile(filePath, 'utf8')
        let logs = fileContent.split("\n")
        const parsed = logs.map((logItem) => {
          const splitedLogItem = logItem.split(',')
          const parsedLogItem: DataRow = [
            this.getParsedTimestamp(splitedLogItem[0]),
            ...splitedLogItem.slice(1).map(s => s.replaceAll('%2C', ','))
          ]
          return parsedLogItem
        })
        return parsed.filter((log) => log.length > 2)
      } catch (e) {
        if (process.env.DEBUG) {
          console.warn(`Read and decode file:${filePath} error!${(e as string).toString()}`)
        }
        return []
      }
    })
    const datalogs = (await Promise.all(datalogsPromise))
      .reduce((ret, cur) => ret.concat(cur), [] as DataTable)
      .reverse()
      .sort((a, b) => {
        if (isNaN(a[0]))
          a[0] = (new Date(a[0])).getTime()
        if (isNaN(b[0]))
          b[0] = (new Date(b[0])).getTime()
        return (b[0]) - (a[0])
      })
    return datalogs
  }

  async initializeData(id: string) {
    this.setNickNameId(id)
    const data: Data = {}
    for (const type of Object.values(CONST.typeList)) {
      data[type] = await this.getData(type)
    }
    return data
  }

  saveLog(type: string, log: DataRow) {
    log = [log[0], ...log.slice(1).map(item => typeof item == 'string' ? item.trim().replaceAll(',', '%2C') : item)]
    fs.ensureDirSync(path.join(DATA_PATH, 'akashic-records', this.nickNameId, type))
    if (type === 'attack') {
      const date = new Date(log[0])
      const year = date.getFullYear()
      const month = date.getMonth() < 9 ?
        `0${date.getMonth() + 1}` : `${date.getMonth() + 1}`
      const day = date.getDate() < 10 ?
        `0${date.getDate()}` : `${date.getDate()}`
      fs.appendFile(
        path.join(DATA_PATH, 'akashic-records', this.nickNameId, type, `${year}${month}${day}`),
        `${log.join(',')}\n`,
        { encoding: 'utf8' },
        (err) => {
          if (process.env.DEBUG) {
            if (err) {
              console.error("Write attack-log file error!");
            } else {
              console.log("Write attack-log file successful!")
            }
          }
        }
      )
    } else {
      fs.appendFile(path.join(DATA_PATH, 'akashic-records', this.nickNameId, type, "data"),
        `${log.join(',')}\n`,
        { encoding: 'utf8' },
        (err) => {
          if (process.env.DEBUG) {
            if (err) {
              console.error(`Write ${type}-log file error!`)
            } else {
              console.log(`Write ${type}-log file successful!`)
            }
          }
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
