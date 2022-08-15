import React, { useCallback } from 'react'
import { useTranslation } from 'react-i18next'
import { Selector, createSelector } from 'reselect'
import { useSelector, useDispatch } from 'react-redux'
import {
  addSearchRule,
  addStatisticsRule,
  deleteSearchRule,
  deleteStatisticsRule,
  hiddenStatisticsPanel,
  setSearchRuleBase,
  setSearchRuleKey,
  setStatisticsRuleDenominator,
  setStatisticsRuleDenominatorType,
  setStatisticsRuleNumerator,
  setStatisticsRuleNumeratorType,
  showStatisticsPanel,
} from '../actions'
import { Collapse, HTMLSelect, HTMLTable, Icon, InputGroup } from '@blueprintjs/core'
import { memoize, range } from 'lodash'
import styled from 'styled-components'
import { shell } from 'electron'

import { DataType } from '../reducers/tab'
import CONST from '../../lib/constant'
import Divider from '../divider'
import { SearchRule } from '../reducers/search-rules'
import { StatisticsRule } from '../reducers/statistics-rules'
import { Popover } from 'views/components/etc/overlay'
import { filterSelectors, searchSelectors, logContentSelectorFactory } from '../selectors'
import { LogContentState } from '../reducers/log-content'
import { IState } from 'views/utils/selectors'

const { config } = window

const TipContainer = styled.div`
  padding: 8px 0;
`

interface SearchRuleWithResult extends SearchRule {
  res: number;
  total: number;
  percent: string;
}

interface StatisticsRuleWithResult extends StatisticsRule {
  percent: string;
}

interface SelectorResult {
  show: boolean;
  searchItems: SearchRuleWithResult[];
  statisticsItems: StatisticsRuleWithResult[];
}

export interface AkashicRecordsStatisticsPanelT {
  contentType: DataType;
}

function calPercent(num: number, de: number): string {
  return (de !== 0) ? `${Math.round(num*10000/de) / 100}%` : '0'
}

const getSearchItems = (lens: number[], searchRules: SearchRule[]): SearchRuleWithResult[] => {
  return searchRules.map((item, index) => {
    return {
      ...item,
      res: lens[index + 2],
      total: lens[item.baseOn],
      percent: calPercent(lens[index + 2], lens[item.baseOn]),
    }
  })
}

function getStatisticsItems(lens: number[], statisticsRules: StatisticsRule[]): StatisticsRuleWithResult[] {
  return statisticsRules.map((item) => {
    let ret = item
    if (item.numeratorType !== -1) {
      ret = {
        ...ret,
        numerator: lens[item.numeratorType],
      }
    }
    if (item.denominatorType !== -1) {
      ret = {
        ...ret,
        denominator: lens[item.denominatorType],
      }
    }
    return {
      ...ret,
      percent: calPercent(ret.numerator, ret.denominator),
    }
  })
}

const getSelector = memoize((dataType: DataType): Selector<LogContentState, SelectorResult> => {
  return createSelector([
    state => state.statisticsVisible ,
    state => state.data,
    state => filterSelectors[dataType](state),
    state => state.searchRules as SearchRule[],
    state => state.statisticsRules,
  ], (show, logs, filteredLogs, searchRules, statisticsRules) => {
    const loglens = searchSelectors[dataType](
      { logs, filteredLogs, searchRules })
    return {
      show,
      searchItems: getSearchItems(loglens, searchRules),
      statisticsItems: getStatisticsItems(loglens, statisticsRules),
    }
  })
})

const AkashicRecordsStatisticsPanel: React.FC<AkashicRecordsStatisticsPanelT> = ({ contentType }) => {
  const { t } = useTranslation('poi-plugin-akashic-records')
  const selector: Selector<IState, SelectorResult> = createSelector(
    logContentSelectorFactory(contentType),
    getSelector(contentType)
  )
  const { show, searchItems, statisticsItems } = useSelector(selector)
  const dispatch = useDispatch()

  const handlePanelShow = useCallback(() => {
    const next = !show
    config.set(`plugin.Akashic.${contentType}.statisticsPanelShow`, next)
    dispatch(next ? showStatisticsPanel(contentType) : hiddenStatisticsPanel(contentType))
  }, [contentType, show])
  const handleAddSearch = useCallback(() => {
    dispatch(addSearchRule(contentType))
  }, [contentType])

  const handleDeleteSearchLine = useCallback((index: number) => {
    dispatch(deleteSearchRule(index, contentType))
  }, [contentType])

  const handleSearchBaseSet = useCallback((index: number, searchBaseOn: number) => {
    dispatch(setSearchRuleBase(index, searchBaseOn, contentType))
  }, [contentType])

  const handleSearchRuleKeySet = useCallback((index: number, searchKey: string) => {
    dispatch(setSearchRuleKey(index, searchKey, contentType))
  }, [contentType])

  const handleAddStatisticRule = useCallback(() => {
    dispatch(addStatisticsRule(contentType))
  }, [contentType])

  const handleDeleteStatisticRule = useCallback((index: number) => {
    dispatch(deleteStatisticsRule(index, contentType))
  }, [contentType])

  const handleStatisticNumeratorTypeSet = useCallback((index: number, statisticNumeratorType: number) => {
    dispatch(setStatisticsRuleNumeratorType(index, statisticNumeratorType, contentType))
  }, [contentType])

  const handleStatisticNumeratorSet = useCallback((index: number, numerator: number) => {
    dispatch(setStatisticsRuleNumerator(index, numerator, contentType))
  }, [contentType])

  const handleStatisticDenominatorTypeSet = useCallback((index: number, denominatorType: number) => {
    dispatch(setStatisticsRuleDenominatorType(index, denominatorType, contentType))
  }, [contentType])

  const handleStatisticDenominatorSet = useCallback((index: number, denominator: number) => {
    dispatch(setStatisticsRuleDenominator(index, denominator, contentType))
  }, [contentType])

  return (
    <div>
      <div>
        <div>
          <div onClick={handlePanelShow}>
            <Divider text={t("Statistics")} icon={true} hr={true} show={show}/>
          </div>
        </div>
      </div>
      <Collapse isOpen={show}>
        <div>
          <div>
            <div>
              <HTMLTable condensed style={{ width: '100%' }}>
                <thead>
                  <tr>
                    <th style={{ verticalAlign: 'middle' }}>
                      <Popover>
                        <Icon icon="help" size={16} />
                        <TipContainer>
                          {t("Support the Javascript's ")}
                          <a onClick={() => shell.openExternal("http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>
                            {"RegExp"}
                          </a>
                        </TipContainer>
                      </Popover>
                    </th>
                    <th>No.</th>
                    <th>{t("Base On")}</th>
                    <th>{t("Keywords")}</th>
                    <th>{t("Result")}</th>
                    <th>{t("Sample Size")}</th>
                    <th>{t("Percentage")}</th>
                  </tr>
                </thead>
                <tbody>
                  {
                    range(searchItems.length).fill(0).map((_, index) => (
                      <tr key={index}>
                        {
                          (index === 0)
                            ? (
                              <td style={{ verticalAlign: 'middle' }}>
                                <Icon icon="add" onClick={handleAddSearch} size={16} />
                              </td>
                            ) : (
                              <td style={{ verticalAlign: 'middle' }}>
                                <Icon icon="remove" onClick={() => handleDeleteSearchLine(index)} size={16} />
                              </td>
                            )
                        }
                        <td>{index + 1}</td>
                        <td>
                          <HTMLSelect
                            minimal
                            value={searchItems[index].baseOn}
                            onChange={(e) => handleSearchBaseSet(index, parseInt(e.target.value))}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>
                              {t("All Data")}
                            </option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>
                              {t("Filtered")}
                            </option>
                            {
                              range(index).fill(0).map((_, i) => (
                                <option
                                  key={CONST.search.indexBase + (i + 1)}
                                  value={CONST.search.indexBase + (i + 1)}
                                >
                                  {t("Search Result No {{index}}", { index: i + 1 })}
                                </option>
                              ), this)
                            }
                          </HTMLSelect>
                        </td>
                        <td>
                          <InputGroup
                            type="text"
                            placeholder={t("Keywords")}
                            value={searchItems[index].content}
                            onChange={(e) => handleSearchRuleKeySet(index, e.target.value)}
                          />
                        </td>
                        <td>{searchItems[index].res}</td>
                        <td>{searchItems[index].total}</td>
                        <td>{searchItems[index].percent}</td>
                      </tr>
                    ))
                  }
                </tbody>
                <thead>
                  <tr>
                    <th></th>
                    <th>No.</th>
                    <th>{t("Numerator")}</th>
                    <th>{t("Denominator")}</th>
                    <th>{t("Numerator Number")}</th>
                    <th>{t("Denominator Number")}</th>
                    <th>{t("Percentage")}</th>
                  </tr>
                </thead>
                <tbody>
                  {
                    range(statisticsItems.length).map((_, index) => (
                      <tr key={index}>
                        {
                          (index === 0)
                            ? (
                              <td style={{ verticalAlign: 'middle' }}>
                                <Icon icon="add" onClick={handleAddStatisticRule} size={16} />
                              </td>
                            ) : (
                              <td style={{ verticalAlign: 'middle' }}>
                                <Icon icon="remove" onClick={() => handleDeleteStatisticRule(index)} size={16} />
                              </td>
                            )
                        }
                        <td>{index + 1}</td>
                        <td>
                          <HTMLSelect
                            minimal
                            value={statisticsItems[index].numeratorType}
                            onChange={(e) => handleStatisticNumeratorTypeSet(index, parseInt(e.target.value))}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>
                              {t("All Data")}
                            </option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>
                              {t("Filtered")}
                            </option>
                            {
                              range(index).fill(0).map((_, i) => (
                                <option
                                  key={CONST.search.indexBase + (i + 1)}
                                  value={CONST.search.indexBase + (i + 1)}
                                >
                                  {t("Search Result No {{index}}", { index: i + 1 })}
                                </option>
                              ), this)
                            }
                            {
                              range(searchItems.length).map((_, i) => (
                                <option
                                  key={CONST.search.indexBase + (i + 1)}
                                  value={CONST.search.indexBase + (i + 1)}
                                >
                                  {t("Search Result No {{index}}", { index: i + 1 })}
                                </option>
                              ), this)
                            }
                            <option key={-1} value={-1}>{t("Custom")}</option>
                          </HTMLSelect>
                        </td>
                        <td>
                          <HTMLSelect
                            minimal
                            value={statisticsItems[index].denominatorType}
                            onChange={(e) => handleStatisticDenominatorTypeSet(index, parseInt(e.target.value))}>

                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>
                              {t("All Data")}
                            </option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>
                              {t("Filtered")}
                            </option>
                            {
                              range(index).fill(0).map((_, i) => (
                                <option
                                  key={CONST.search.indexBase + (i + 1)}
                                  value={CONST.search.indexBase + (i + 1)}
                                >
                                  {t("Search Result No {{index}}", { index: i + 1 })}
                                </option>
                              ), this)
                            }
                            {
                              range(searchItems.length).map((_, i) => (
                                <option
                                  key={CONST.search.indexBase + (i + 1)}
                                  value={CONST.search.indexBase + (i + 1)}
                                >
                                  {t("Search Result No {{index}}", { index: i + 1 })}
                                </option>
                              ), this)
                            }
                            <option key={-1} value={-1}>{t("Custom")}</option>
                          </HTMLSelect>
                        </td>
                        {
                          (statisticsItems[index].numeratorType === -1)
                            ? (
                              <td>
                                <InputGroup
                                  type="number"
                                  value={statisticsItems[index].numerator.toString()}
                                  onChange={(e) => handleStatisticNumeratorSet(index, parseInt(e.target.value))}
                                />
                              </td>
                            ) : (
                              <td>{statisticsItems[index].numerator}</td>
                            )
                        }
                        {
                          (statisticsItems[index].denominatorType === -1)
                            ? (
                              <td>
                                <InputGroup
                                  type="number"
                                  value={statisticsItems[index].denominator.toString()}
                                  onChange={(e) => handleStatisticDenominatorSet(index, parseInt(e.target.value))}
                                />
                              </td>
                            ) : (
                              <td>{statisticsItems[index].denominator}</td>
                            )
                        }
                        <td>{statisticsItems[index].percent}</td>
                      </tr>
                    ), this)
                  }
                </tbody>
              </HTMLTable>
            </div>
          </div>
        </div>
      </Collapse>
    </div>
  )
}

export default AkashicRecordsStatisticsPanel
