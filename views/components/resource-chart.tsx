import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { createSelector, Selector } from 'reselect'
import { useSelector } from 'react-redux'
import ReactEChartsCore from 'echarts-for-react/lib/core'
import { EChartsOption } from 'echarts-for-react'
import { useTranslation } from 'react-i18next'
import { get } from 'lodash'
import { IState } from 'views/utils/selectors'

import { logContentSelectorFactory } from '../selectors'
import { DataTable } from '../../lib/data-co-manager'
import images from '../../assets/img'
import dark from '../../assets/themes/dark'
import macarons from '../../assets/themes/macarons'
import {
  filterByTimeScale,
  nextTimeScale,
  TimeScale,
  timeScaleLabels,
  toTimeScale,
} from '../utils/time-scale'

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

const scaleGlyphs: Record<TimeScale, string> = {
  [TimeScale.Hour]: 'H',
  [TimeScale.Day]: 'D',
  [TimeScale.Week]: 'W',
  [TimeScale.Month]: 'M',
}

// the bundled toolbox icons only cover hour and day, so every scale is drawn
// as a glyph instead, keeping the four states of the cycle consistent
const toScaleIcon = (scale: TimeScale, color: string): string => {
  const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 50 50">'
    + '<text x="25" y="39" text-anchor="middle" font-family="sans-serif"'
    + ` font-size="46" font-weight="bold" fill="${color}">${scaleGlyphs[scale]}</text>`
    + '</svg>'
  return `image://data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`
}

interface SelectorResult {
  data: DataTable;
}

const AkashicResourceChart: React.FC = () => {
  const selector: Selector<IState, SelectorResult> = createSelector(
    logContentSelectorFactory('resource'),
    (state) => ({ data: state.data })
  )
  const { data } = useSelector(selector)

  const isDarkTheme = useSelector(state => get(state, 'config.poi.appearance.theme', 'dark') === 'dark')

  const { t } = useTranslation('poi-plugin-akashic-records')

  const [timeScale, setTimeScale] = useState<TimeScale>(() => toTimeScale(
    config.get("plugin.Akashic.resource.chart.timeScale",
      // carried over from the hour/day toggle this cycle replaces
      config.get("plugin.Akashic.resource.chart.showAsDay", true) ? TimeScale.Day : TimeScale.Hour)
  ))
  const [showSymbol, setShowSymbol] = useState(config.get("plugin.Akashic.resource.chart.showSymbol", false))
  const echartModuleRef = useRef<any>()

  useEffect(() => {
    echartPromise.then(echart => {
      echartModuleRef.current = echart
      echart.registerTheme('dark', dark)
      echart.registerTheme('macarons', macarons)
    })
  }, [echartModuleRef])

  // records come in newest first, the time axis reads left to right
  const showData: DataTable = useMemo(
    () => [...filterByTimeScale(data, timeScale)].reverse(),
    [data, timeScale]
  )

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
          myShowScale: {
            show: true,
            title: t("Show by {{scale}}", { scale: t(timeScaleLabels[timeScale]) }),
            icon: toScaleIcon(timeScale, textColor),
            onclick: () => {
              const next = nextTimeScale(timeScale)
              setTimeScale(next)
              config.set("plugin.Akashic.resource.chart.timeScale", next)
            },
          },
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
  }, [t, timeScale, showData, showSymbol, textColor])

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

export default AkashicResourceChart
