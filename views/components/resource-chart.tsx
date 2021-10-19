import React, { useCallback, useEffect, useRef, useState } from 'react'
import images from '../../assets/img'
import dark from '../../assets/themes/dark'
import macarons from '../../assets/themes/macarons'
import { createSelector, Selector } from 'reselect'
import { logContentSelectorFactory } from 'views/selectors'
import { useSelector } from 'react-redux'
import { EChartsOption } from 'echarts-for-react'
import { DataState } from 'views/reducers/data'

import ReactEChartsCore from 'echarts-for-react/lib/core'
import { useTranslation } from 'react-i18next'
import { get } from 'lodash'

const echartPromise = import('echarts')

const { config } = window

const toDateLabel = (datetime: number): string => {
  const date = new Date(datetime)
  const month = date.getMonth() < 9 ?
    `0${date.getMonth() + 1}` : `${date.getMonth() + 1}`
  const day = date.getDate() < 9 ?
    `0${date.getDate()}` : `${date.getDate()}`
  const hour = date.getHours() < 9 ?
    `0${date.getHours()}` : `${date.getHours()}`
  const minute = date.getMinutes() < 9 ?
    `0${date.getMinutes()}` : `${date.getMinutes()}`
  return `${date.getFullYear()}-${month}-${day} ${hour}:${minute}`
}

const toDateString = (datetime: number): string => {
  const date = new Date(datetime)
  return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`
}

interface SelectorResult {
  data: DataState;
}

const AkashicResourceChart: React.FC = () => {
  const selector: Selector<any, SelectorResult> = createSelector(
    logContentSelectorFactory('resource'),
    (state) => ({ data: state.data })
  )
  const { data } = useSelector(selector)

  const isDarkTheme = useSelector(state => get(state, 'config.poi.appearance.theme', 'dark') === 'dark')

  const { t } = useTranslation('poi-plugin-akashic-records')

  const [showAsDay, setShowAsDay] = useState(config.get("plugin.Akashic.resource.chart.showAsDay", true))
  const [showSymbol, setShowSymbol] = useState(config.get("plugin.Akashic.resource.chart.showSymbol", false))
  const [dataLength, setDataLength] = useState(0)
  const [showData, setShowData] = useState<DataState>(data)
  const echartModuleRef = useRef<any>()

  useEffect(() => {
    echartPromise.then(echart => {
      echartModuleRef.current = echart
      echart.registerTheme('dark', dark)
      echart.registerTheme('macarons', macarons)
    })
  }, [echartModuleRef])

  const dataFilter = useCallback((data: DataState) => {
    let dateString = ''
    return data.filter((item) => {
      if (showAsDay) {
        const tmp = toDateString(item[0])
        if (tmp !== dateString) {
          dateString = tmp
          return true
        } else {
          return false
        }
      } else {
        return true
      }
    })
  }, [showAsDay])

  const textColor = isDarkTheme ? '#ddd' : '#333'

  const getEChartsOption = useCallback((): EChartsOption => {
      const toIcon = (source: string) => `image://${source}`
      return {
        textStyle: {
          color: textColor,
        },
        tooltip: {
          trigger: "axis",
          show: true,
          padding: 10,
          confine: true,
          formatter: (params: any) => {
            const dateString = toDateLabel(params[0].value[0])
            const resArray = params.map((item: any) => `${item.seriesName}: ${item.value[1]}`)
            resArray.unshift(`${dateString}`)
            return resArray.join('<br/>')
          },
        },
        legend: {
          data: [
            t('Fuel'),
            t('Ammo'),
            t('Steel'),
            t('Bauxite'),
            t('Fast Build Item'),
            t('Instant Repair Item'),
            t('Development Material'),
            t('Improvement Materials'),
          ],
          textStyle: {
            color: textColor,
          },
        },
        toolbox: {
          show: true,
          feature: {
            dataView: {
              show: false,
              readOnly: true,
            },
            restore: {
              show: true,
              title: t("Restore"),
            },
            saveAsImage: {
              show: true,
              backgroundColor: '#343434',
            },
            myShowScale: ((showAsDayValue) => {
              const opt = showAsDayValue
                ? {
                  title: t("Show by {{scale}}", { scale: t("Day") }),
                  icon: toIcon(images.day),
                } : {
                  title:  t("Show by {{scale}}", { scale: t("Hour") }),
                  icon: toIcon(images.hour),
                }
              return {
                show: true,
                ...opt,
                onclick: () => {
                  const newShowData = dataFilter(data).reverse()
                  setShowAsDay(!showAsDayValue)
                  setShowData(newShowData)
                  setDataLength(newShowData.length)
                  config.set("plugin.Akashic.resource.chart.showAsDay", !showAsDayValue)
                },
              }
            })(showAsDay),
            myShowType: ((showSymbolValue) => {
              const opt = showSymbolValue
                ? {
                  title: t("Hide node"),
                  icon: toIcon(images.withNodeInSleepMode),
                } : {
                  title: t("Show node"),
                  icon: toIcon(images.withNoNodeInSleepMode),
                }
              const showType = {
                show: true,
                ...opt,
                color: '#eee',
                onclick: () => {
                  setShowSymbol(!showSymbolValue)
                  config.set("plugin.Akashic.resource.chart.showSymbol", !showSymbolValue)
                },
              }
              return showType
            })(showSymbol),
          },
        },
        dataZoom: {
          show: true,
          realtime: true,
          dataBackground: {
            areaStyle: {
              color: 'rgba(98, 154, 250, 1)',
            },
          },
          textStyle: {
            color: textColor,
          },
        },
        xAxis: [{
          type: 'time',
          splitNumber: 10,
          axisLabel: {
            textStyle: {
              color: textColor,
            },
          },
          splitLine: {
            lineStyle: {
              color: '#505050',
              type: 'dashed',
            },
          },
        }],
        yAxis: (() => {
          const item = {
            type: 'value',
            axisLine: {
              lineStyle: {
                color: '#eee',
                width: 0,
              },
            },
            axisLabel: {
              textStyle: {
                color: textColor,
              },
            },
            axisTick: {
              show: false,
            },
            splitLine: {
              lineStyle: {
                color: '#505050',
                type: 'dashed',
              },
            },
          }
          return [item, { ...item }]
        })(),
        grid: { y2: 80 },
        series: [
          {
            name: t('Fuel'),
            type: "line",
            yAxisIndex: 0,
            itemStyle: {
              normal: { color: '#1b9d19' },
            },
            symbol: 'rect',
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[1], index]),
          },
          {
            name: t('Ammo'),
            type: "line",
            yAxisIndex: 0,
            symbol: 'roundRect',
            itemStyle: {
              normal: { color: '#663910' },
            },
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[2], index]),
          },
          {
            name: t('Steel'),
            type: "line",
            symbol: 'triangle',
            yAxisIndex: 0,
            itemStyle: {
              normal: { color: '#919191' },
            },
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[3], index]),
          },
          {
            name: t('Bauxite'),
            type: "line",
            symbol: 'diamond',
            yAxisIndex: 0,
            itemStyle: {
              normal: { color: '#b37c50' },
            },
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[4], index]),
          },
          {
            name: t('Fast Build Item'),
            type: "line",
            symbol: 'arrow',
            yAxisIndex: 1,
            itemStyle: {
              normal: { color: '#fb8a00' },
            },
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[5], index]),
          },
          {
            name: t('Instant Repair Item'),
            type: "line",
            symbol: 'pin',
            yAxisIndex: 1,
            itemStyle: {
              normal: { color: '#32eca1' },
            },
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[6], index]),
          },
          {
            name: t('Development Material'),
            type: "line",
            symbol: 'circle',
            yAxisIndex: 1,
            itemStyle: {
              normal: { color: '#419ba9' },
            },
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[7], index]),
          },
          {
            name: t('Improvement Materials'),
            type: "line",
            symbol: 'emptyCircle',
            yAxisIndex: 1,
            itemStyle: {
              normal: { color: '#aaaaaa' },
            },
            showSymbol: showSymbol,
            data: showData.map((logitem, index) =>
              [logitem[0], logitem[8], index]),
          },
        ],
        animation: false,
      }
  }, [dataFilter, showAsDay, showData, showSymbol, dataLength, textColor])

  return (
    echartModuleRef.current ?
      <div>
        <ReactEChartsCore
          echarts={echartModuleRef.current}
          option={getEChartsOption()}
          notMerge
          lazyUpdate
          theme={isDarkTheme ? 'dark' : 'macarons'}
          style={{ height: 'calc(100vh - 200px)', minHeight: 300 }}
        />
      </div> :
      null
  )
}

export default AkashicResourceChart;
