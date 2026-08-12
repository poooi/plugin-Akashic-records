import { createSelector, OutputParametricSelector, Selector } from 'reselect'
import { memoize } from 'lodash'
import { dateToString } from '../../lib/utils'
import { LogContentState } from '../reducers/log-content'

import CONST from '../../lib/constant'

import { extensionSelectorFactory, fcdSelector, IState } from 'views/utils/selectors'
import { SearchRule } from '../reducers/search-rules'
import { DataType } from '../reducers/tab'
import { DataTable } from '../../lib/data-co-manager'
import { FcdMapState, resolveMapCells } from '../utils/map-cell'
import { ConfigItem } from '../reducers/view-control'
import { defaultTimeScale, filterByTimeScale, TimeScale } from '../utils/time-scale'

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
  showTimeScale: defaultTimeScale,
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

const fcdMapSelector: Selector<IState, FcdMapState | undefined> = createSelector(
  fcdSelector,
  (fcd) => fcd?.map
)

const withResolvedMapCells = (
  state: LogContentState,
  fcdMap: FcdMapState | undefined
): LogContentState => {
  const data = resolveMapCells(state.data, fcdMap)
  return data === state.data ? state : { ...state, data }
}

/**
 * Sortie records only store the edge id of the cell a battle took place in, the
 * readable name comes from fcd. Anything filtering or counting the logs has to
 * go through here, or it disagrees with what the table shows.
 */
export const resolveLogContent = (state: LogContentState, contentType: DataType): LogContentState =>
  contentType === 'attack'
    ? withResolvedMapCells(state, window.getStore('fcd.map'))
    : state

// memoized so that components creating their selector on every render still
// hit reselect's cache
export const logContentSelectorFactory = memoize((contentType: DataType): Selector<IState, LogContentState> => {
  const stateSelector = createSelector(
    pluginDataSelector,
    (pluginData) => pluginData[contentType] || emptyLogContentState
  )
  if (contentType !== 'attack') {
    return stateSelector
  }
  // fcd loads asynchronously, so this has to react to it rather than read it once
  return createSelector([stateSelector, fcdMapSelector], withResolvedMapCells)
})

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

const resourceApplyFilter = (logs: DataTable, tabVisibility: boolean[], keyWord: string, showScale: TimeScale) => {
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
  return filterByTimeScale(retLogs, showScale)
}

const emptyArr: string[] = []
const logSelectorFactory = () => {
  const getLogs = (state: LogContentState) => state.data
  const getFilterKeys = (state: LogContentState) =>
    (state.configListChecked[ConfigItem.ShowFilterBox]
      || state.configListChecked[ConfigItem.AutoSelected]
      || !state.configListChecked[ConfigItem.DisableFilteringWhileHidingFilterBox])
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
