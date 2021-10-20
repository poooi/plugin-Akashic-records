import { createSelector, OutputParametricSelector, Selector } from 'reselect'
import { dateToString } from '../../lib/utils'
import { LogContentState } from '../reducers/log-content'

import CONST from '../../lib/constant'

import { extensionSelectorFactory, IState } from 'views/utils/selectors'
import { SearchRule } from '../reducers/search-rules'
import { DataType } from '../reducers/tab'
import { DataTable } from '../../lib/data-co-manager'

type PluginState = Record<DataType, LogContentState>

const emptyLogContentState: LogContentState = {
  data: [],
  tabVisibility: [],
  activePage: 0,
  showAmount: 0,
  configListChecked: [],
  checkboxVisible: true,
  statisticsVisible: true,
  searchRules: [],
  statisticsRules: [],
  filterKeys: [],
  showTimeScale: 0,
}

const empty: PluginState = {
  attack: emptyLogContentState,
  mission: emptyLogContentState,
  createitem: emptyLogContentState,
  createship: emptyLogContentState,
  retirement: emptyLogContentState,
  resource: emptyLogContentState,
}

export const pluginDataSelector: Selector<IState, PluginState> = createSelector(
  extensionSelectorFactory('poi-plugin-akashic-records'),
  (state) => state as PluginState || empty
)

export const logContentSelectorFactory = (contentType: DataType): Selector<IState, LogContentState> => {
  return createSelector(pluginDataSelector, (pluginData) => pluginData[contentType] || emptyLogContentState)
}

const dateToDateString = (datetime: number | string): string => {
  const date = new Date(datetime)
  return `${date.getFullYear()}/${date.getMonth()}/${date.getDate()}`
}

const filterRegWindex = (data: DataTable, index: number, reg: RegExp) =>
  data.filter((row) =>
    reg.test(index === 0 ? dateToString(new Date(row[0])) : `${row[index]}`)
  )

const filterStringWIndex = (data: DataTable, index: number, keyword: string) =>
  data.filter((row)=>
    index === 0
      ? dateToString(new Date(row[0])).toLowerCase().trim().indexOf(keyword) >= 0
      : `${row[index]}`.toLowerCase().trim().indexOf(keyword) >= 0
  )

const filterWithIndex = (logs: DataTable, filterKeys: string[]): DataTable => {
  let retData = logs
  filterKeys.forEach((key, idx) => {
    if (key === '') return
    const res = key.match(/^\/(.+)\/([gim]*)$/)
    if (res != null) {
      try {
        retData = filterRegWindex(retData, idx, new RegExp(res[1], res[2]))
      } catch (e) {
        console.error(`Failed to resolve RegExp ${key}.`)
      }
    } else {
      retData = filterStringWIndex(retData, idx, key.toLowerCase().trim())
    }
  })
  return retData
}

const filterWNindex = (logs: DataTable, keyword: string): DataTable => {
  if (keyword === '') {
    return logs
  } else {
    let regFlag = false
    let reg: RegExp
    const res = keyword.match(/^\/(.+)\/([gim]*)$/)
    if (res != null) {
      try {
        reg = new RegExp(res[1], res[2])
        regFlag = true
      } catch (e) {
        regFlag = false
      }
    }
    return logs.filter((log) => {
      return log.some((item, i) => {
        let searchText = item
        if (i === 0) {
          searchText = dateToString(new Date(searchText))
        } else if (!regFlag){
          searchText = `${searchText}`.toLowerCase().trim()
        }
        return regFlag ? reg.test(searchText as string)
          : (searchText as string).indexOf(keyword.toLowerCase().trim()) >= 0
      })
    })
  }
}

const filterAsScale = (data: DataTable, showScale: number) => {
  if (showScale === 0) {
    return data
  } else {
    let dateString = ""
    return data.filter((item) => {
      const tmp =  dateToDateString(item[0])
      if (tmp !== dateString) {
        dateString = tmp
        return true
      } else {
        return false
      }
    })
  }
}

const resourceApplyFilter = (logs: DataTable, tabVisibility: boolean[], keyWord: string, showScale: number) => {
  let retLogs = logs
  if (keyWord != null) {
    retLogs = retLogs.filter((row) => {
      return row.some((item, idx) => {
        if (tabVisibility[idx + 1]) {
          return ((idx === 0 && dateToString(new Date(item)).toLowerCase().trim().indexOf(keyWord.toLowerCase().trim()) >= 0)
          || (idx !== 0 && `${item}`.toLowerCase().trim().indexOf(keyWord.toLowerCase().trim()) >= 0))
        } else {
          return false
        }
      })
    })
  }
  return filterAsScale(retLogs, showScale)
}

const emptyArr: string[] = []
const logSelectorFactory = () => {
  const getLogs = (state: LogContentState) => state.data
  const getFilterKeys = (state: LogContentState) =>
    (state.configListChecked[1] || state.configListChecked[2] || !state.configListChecked[3])
      ? state.filterKeys
      : emptyArr
  return createSelector([getLogs, getFilterKeys], filterWithIndex)
}

type LogSearchSelector = OutputParametricSelector<DataTable[], SearchRule, DataTable, (log: DataTable, rule: string) => DataTable>

const logSearchSelectorBaseFactory = (
  old: LogSearchSelector[],
  num: number
) => {
  const getLogs = (logsRes: DataTable[], searchRule: SearchRule): DataTable => logsRes[searchRule.baseOn]
  const getSearchKey = (logsRes: DataTable[], searchRule: SearchRule): string => searchRule.content
  return [...Array(num).keys()].map((index) =>
    old[index] || createSelector([getLogs, getSearchKey], filterWNindex)
  )
}

export interface LogSearchSelectorFactoryParam {
  logs: DataTable,
  filteredLogs: DataTable
  searchRules: SearchRule[]
}

const logSearchSelectorFactory = () => {
  return (function() {
    let selector: LogSearchSelector[]
    let lastLogs: DataTable
    return createSelector(
      [
        (params: LogSearchSelectorFactoryParam) => params.logs,
        (params: LogSearchSelectorFactoryParam) => params.filteredLogs,
        (params: LogSearchSelectorFactoryParam) => params.searchRules,
      ],
      (logs, filteredLogs, searchRules) => {
        if (selector == null || lastLogs !== logs)
          selector = logSearchSelectorBaseFactory([], searchRules.length)
        lastLogs = logs
        if (selector.length !== searchRules.length)
          selector = logSearchSelectorBaseFactory(selector, searchRules.length)
        const logsRes: DataTable[] = [logs, filteredLogs]
        searchRules.forEach((searchRule, i) =>
          logsRes[CONST.search.indexBase+i+1] = selector[i](logsRes, searchRule)
        )
        return logsRes.map((logs) => logs.length)
      }
    )
  })()
}

export const filterSelectors: Record<DataType, Selector<LogContentState, DataTable>> = {
  attack: logSelectorFactory(),
  mission: logSelectorFactory(),
  createship: logSelectorFactory(),
  createitem: logSelectorFactory(),
  retirement: logSelectorFactory(),
  resource: logSelectorFactory(),
}

export const searchSelectors: Record<DataType, Selector<LogSearchSelectorFactoryParam, number[]>> = {
  attack: logSearchSelectorFactory(),
  mission: logSearchSelectorFactory(),
  createship: logSearchSelectorFactory(),
  createitem: logSearchSelectorFactory(),
  retirement: logSearchSelectorFactory(),
  resource: logSearchSelectorFactory(),
}

export const resourceFilter = createSelector(
  [
    (state: LogContentState) => state.data,
    (state: LogContentState) => state.tabVisibility,
    (state: LogContentState) => state.filterKeys[0],
    (state: LogContentState) => state.showTimeScale,
  ], resourceApplyFilter
)
