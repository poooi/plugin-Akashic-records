import { createSelector } from 'reselect'
import { dateToString } from '../../lib/utils'

import CONST from '../../lib/constant'

import { extensionSelectorFactory } from 'views/utils/selectors'

const empty = {}

export const pluginDataSelector = createSelector(
  extensionSelectorFactory('poi-plugin-akashic-records'),
  (state) => state || empty
)

const dateToDateString = (datetime) => {
  const date = new Date(datetime)
  return `${date.getFullYear()}/${date.getMonth()}/${date.getDate()}`
}

const filterRegWindex = (data, index, reg) =>
  data.filter((row) =>
    reg.test(index === 0 ? dateToString(new Date(row[0])) : `${row[index]}`)
  )

const filterStringWIndex = (data, index, keyword) =>
  data.filter((row)=>
    index === 0
      ? dateToString(new Date(row[0])).toLowerCase().trim().indexOf(keyword) >= 0
      : `${row[index]}`.toLowerCase().trim().indexOf(keyword) >= 0
  )

const filterWithIndex = (logs, filterKeys) => {
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

const filterWNindex = (logs, keyword) => {
  if (keyword === '') {
    return logs
  } else {
    let regFlag = false
    let reg = null
    const res = keyword.match(/^\/(.+)\/([gim]*)$/)
    if (res != null) {
      try {
        reg = new RegExp(res[1], res[2])
        regFlag = true
      } catch (e) {
        regFlag = false
      } finally {
        if (regFlag) keyword = reg
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
        return regFlag ? keyword.test(searchText)
                        : searchText.indexOf(keyword.toLowerCase().trim()) >= 0
      })
    })
  }
}

const filterAsScale = (data, showScale) => {
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

const resourceApplyFilter = (logs, tabVisibility, keyWord, showScale) => {
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

const emptyArr = []
const logSelectorFactory = () => {
  const getLogs = (state) => state.data
  const getFilterKeys = (state) =>
    (state.configListChecked[1] || state.configListChecked[2] || !state.configListChecked[3])
    ? state.filterKeys
    : emptyArr
  return createSelector([getLogs, getFilterKeys], filterWithIndex)
}

const logSearchSelectorBaseFactory = (old, num) => {
  const getLogs = (logsRes, searchRule) => logsRes[searchRule.baseOn]
  const getSearchKey = (logsRes, searchRule) => searchRule.content
  return [...Array(num).keys()].map((index) =>
    old[index] || createSelector([getLogs, getSearchKey], filterWNindex)
  )
}

const logSearchSelectorFactory = () => {
  return (function() {
    let selector = null
    let lastLogs = null
    return createSelector(
      [
        params => params.logs,
        params => params.filteredLogs,
        params => params.searchRules,
      ],
      (logs, filteredLogs, searchRules) => {
        if (selector == null || lastLogs !== logs)
          selector = logSearchSelectorBaseFactory([], searchRules.length)
        lastLogs = logs
        if (selector.length !== searchRules.length)
          selector = logSearchSelectorBaseFactory(selector, searchRules.length)
        const logsRes = [logs, filteredLogs]
        searchRules.forEach((searchRule, i) =>
          logsRes[CONST.search.indexBase+i+1] = selector[i](logsRes, searchRule)
        )
        return logsRes.map((logs) => logs.length)
      }
    )
  })()
}

export const filterSelectors = {
  attack: logSelectorFactory(),
  mission: logSelectorFactory(),
  createship: logSelectorFactory(),
  createitem: logSelectorFactory(),
  retirement: logSelectorFactory(),
  resource: logSelectorFactory(),
}

export const searchSelectors = {
  attack: logSearchSelectorFactory(),
  mission: logSearchSelectorFactory(),
  createship: logSearchSelectorFactory(),
  createitem: logSearchSelectorFactory(),
  retirement: logSearchSelectorFactory(),
  resource: logSearchSelectorFactory(),
}

export const resourceFilter = createSelector(
  [
    (state) => state.data,
    (state) => state.tabVisibility,
    (state) => state.filterKeys[0],
    (state) => state.showTimeScale,
  ], resourceApplyFilter
)

export const tableTabNameSelector = createSelector(
  [
    (state) => state[CONST.typeList.attack].tabs,
    (state) => state[CONST.typeList.mission].tabs,
    (state) => state[CONST.typeList.createShip].tabs,
    (state) => state[CONST.typeList.createItem].tabs,
    (state) => state[CONST.typeList.retirement].tabs,
    (state) => state[CONST.typeList.resource].tabs,
  ], (attack, mission, createShip, createItem, retirement, resource) => (
    {
      [CONST.typeList.attack]: attack,
      [CONST.typeList.mission]: mission,
      [CONST.typeList.createShip]: createShip,
      [CONST.typeList.createItem]: createItem,
      [CONST.typeList.retirement]: retirement,
      [CONST.typeList.resource]: resource,
    }
  )
)
