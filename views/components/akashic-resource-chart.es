import path from 'path-extra'
import React from 'react'
import {
  Grid,
  Row,
  Col,
} from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
const { config, ROOT, __ } = window
const {error} = require(path.join(ROOT, 'lib/utils'))

// #import i18n from '../node_modules/i18n'
// # {__} = i18n

require('../../assets/echarts-all')
const { echarts } = window

import dark from '../../assets/themes/dark'
import macarons from '../../assets/themes/macarons'

function toDateLabel(datetime) {
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

function toDateString(datetime) {
  const date = new Date(datetime)
  return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`
}

class AkashicResourceChart extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                        true, true],
    }
    this.showAsDay = true
    this.showAllSymbol = false
    this.sleepMode = false
    this.resourceChart = 0
    this.wholeDataLength = 0
    this.dataLength = 0
    this.showData = []
  }
  componentWillMount() {
    this.showAsDay = config.get("plugin.Akashic.resource.chart.showAsDay", true)
    this.showAllSymbol = config.get("plugin.Akashic.resource.chart.showAllSymbol", false)
    this.sleepMode = config.get("plugin.Akashic.resource.chart.sleepMode", true)
    window.onresize = () => {
      document.getElementById('ECharts').style.height = `${window.remote.getCurrentWindow().getBounds().height - 150}px`
      if (this.resourceChart !== 0) {
        this.resourceChart.resize()
      }
      return true
    }
  }

  dataFilter(data) {
    let dateString = ''
    const showAsDay = this.showAsDay
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
  }

  getEChartsOption() {
    return {
      tooltip: {
        trigger: "item",
        show: true,
        formatter(params) {
          const dateTime = params.value[0]
          const dateString = toDateLabel(params.value[0])
          const series = this.getSeries()
          let index = -1
          const logdata = [dateTime]
          for (const item of series) {
            const data = item.data
            if (index === -1) {
              if (data[params.value[2]] != null && data[params.value[2]][0] === logdata[0]) {
                index = params.value[2]
              } else {
                if (!data.some((item, i) => {
                  if (item[0] === logdata[0]) {
                    index = i
                    return true
                  }
                  return false
                })) {
                  error("can't find matched data! in ECharts's tooltip formatter()")
                }
              }
            }
            logdata.push(data[index][1])
            if (logdata[0] !== data[index][0]) {
              error("data error! in ECharts's tooltip formatter()")
            }
          }
          return `${dateString}<br/>${__("Fuel")}: ${logdata[1]}<br/>\
  ${__("Ammo")}: ${logdata[2]}<br/>\
  ${__("Steel")}: ${logdata[3]}<br/>\
  ${__("Bauxite")}: ${logdata[4]}<br/>\
  ${__("Fast Build Item")}: ${logdata[5]}<br/>\
  ${__("Instant Repair Item")}: ${logdata[6]}<br/>\
  ${__("Development Material")}: ${logdata[7]}<br/>\
  ${__("Improvement Materials")}: ${logdata[8]}`
        },
      },

      legend: {
        data: [
          __('Fuel'),
          __('Ammo'),
          __('Steel'),
          __('Bauxite'),
          __('Fast Build Item'),
          __('Instant Repair Item'),
          __('Development Material'),
          __('Improvement Materials'),
        ],
        textStyle: this.sleepMode ? {
          color: '#fff'
        } : {},
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
            title: __("Restore"),
          },
          saveAsImage: {
            show: false,
          },
          showScale: ((showAsDay) => {
            const opt = showAsDay
              ? {
                title: __("Show by %s", __("Day")),
                icon: './assets/echarts-day.png',
              } : {
                title:  __("Show by %s", __("Hour")),
                icon: './assets/echarts-hour.png',
              }
            return {
              show: true,
              ...opt,
              onclick: () => {
                this.showAsDay = !this.showAsDay
                this.showData = this.dataFilter(this.props.data)
                this.dataLength = this.showData.length
                this.showData.reverse()
                if (this.showData.length !== 0) {
                  if (this.resourceChart.getSeries() == null) {
                    this.resourceChart.hideLoading()
                  }
                  this.resourceChart.setOption(this.getEChartsOption(), true)
                }
                config.set("plugin.Akashic.resource.chart.showAsDay", this.showAsDay)
              },
            }
          })(this.showAsDay),
          showType: ((showAllSymbol) => {
            const suffix = this.sleepMode ? '-sleepmode' : ''
            const opt = showAllSymbol
              ? {
                title: __("Show node"),
                icon: `./assets/echarts-with-node${suffix}.png`,
              } : {
                title: __("Hide node"),
                icon: `./assets/echarts-no-node${suffix}.png`,
              }
            const showType = {
              show: true,
              ...opt,
              onclick: () => {
                this.showAllSymbol = !this.showAllSymbol
                this.resourceChart.setOption(this.getEChartsOption(), true)
                config.set("plugin.Akashic.resource.chart.showAllSymbol", this.showAllSymbol)
              },
            }
            if (this.sleepMode)
              showType.color = '#eee'
            return showType
          })(this.showAllSymbol),
          themeMode: ((sleepMode) => {
            const opt = sleepMode ? {
              title: __("Sleep mode"),
              icon: './assets/echarts-moon.png',
            } : {
              title: __("Light mode"),
              icon: './assets/echarts-sun.png',
            }
            return {
              show: true,
              ...opt,
              onclick: () => {
                this.sleepMode = !this.sleepMode
                this.resourceChart.setTheme(this.sleepMode ? dark : macarons)
                this.resourceChart.setOption(this.getEChartsOption(), true)
                config.set("plugin.Akashic.resource.chart.sleepMode", this.sleepMode)
              },
            }
          })(this.sleepMode),
        },
      },
      grid: { y2: 80 },
      dataZoom: {
        show: true,
        realtime: true,
      },
      xAxis: ((sleepMode) => {
        const opt = sleepMode ? {
          labelColor: '#ddd',
          splitColor: '#505050',
        } : {
          labelColor: '#333',
          splitColor: '#eee',
        }
        return [{
          type: 'time',
          splitNumber: 10,
          axisLabel: {
            textStyle: {
              color: opt.labelColor,
            },
          },
          splitLine: {
            lineStyle: {
              color: opt.splitColor,
            },
          },
        }]
      })(this.sleepMode),
      yAxis: ((sleepMode) => {
        const opt = sleepMode ? {
          labelColor: '#ddd',
          splitColor: '#505050',
        } : {
          labelColor: '#333',
          splitColor: '#eee',
        }
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
              color: opt.labelColor,
            },
          },
          splitLine: {
            lineStyle: {
              color: opt.splitColor,
            },
          },
        }
        return [item, JSON.parse(JSON.stringify(item))]
      })(this.sleepMode),
      series: [
        {
          name: __('Fuel'),
          type:"line",
          yAxisIndex: 0,
          itemStyle: {
            normal: { color: '#1b9d19' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[1], index]),
        },
        {
          name:__('Ammo'),
          type:"line",
          yAxisIndex: 0,
          itemStyle: {
            normal: { color: '#663910' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[2], index]),
        },
        {
          name:__('Steel'),
          type:"line",
          yAxisIndex: 0,
          itemStyle: {
            normal: { color: '#919191' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[3], index]),
        },
        {
          name:__('Bauxite'),
          type:"line",
          yAxisIndex: 0,
          itemStyle: {
            normal: { color: '#b37c50' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[4], index]),
        },
        {
          name:__('Fast Build Item'),
          type:"line",
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#fb8a00' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[5], index]),
        },
        {
          name:__('Instant Repair Item'),
          type:"line",
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#32eca1' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[6], index]),
        },
        {
          name:__('Development Material'),
          type:"line",
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#419ba9' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[7], index]),
        },
        {
          name:__('Improvement Materials'),
          type:"line",
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#aaaaaa' },
          },
          showAllSymbol: this.showAllSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[8], index]),
        },
      ],
    }
  }

  renderChart() {
    const node = findDOMNode(this.chart)
    const theme = this.sleepMode ? dark : macarons
    this.resourceChart = this.resourceChart || echarts.init(node, theme)
    const option = this.getEChartsOption()
    this.resourceChart.setOption(option)
  }
  // # componentDidMount: () =>
  //   #
  componentDidUpdate() {
    if (this.resourceChart === 0 && this.props.mapShowFlag) {
      this.showData = this.dataFilter(this.props.data)
      this.dataLength = this.showData.length
      this.showData.reverse()
      this.wholeDataLength = this.props.data.length
      this.renderChart()
    }
  }
  shouldComponentUpdate(nextProps, nextState) {
    if (this.resourceChart === 0) return true
    if (nextProps.data.length > this.wholeDataLength) {
      let dateString = ''
      if (this.wholeDataLength > 0) {
        dateString = toDateString(nextProps.data[nextProps.data.length - this.wholeDataLength][0])
      }
      if (this.resourceChart.getSeries() != null) {
        if (!this.showAsDay) {
          for (let i = nextProps.data.length - this.wholeDataLength - 1; i >= 0; --i) {
            this.showData.push(nextProps.data[i])
            const dataitem = []
            for (const [j, item] of nextProps.data[i].entries()) {
              if (j === 0) continue
              dataitem.push([j - 1, [nextProps.data[i][0], item, this.showData.length - 1], false, true, ''])
            }
            this.resourceChart.addData(dataitem)
          }
        } else {
          for (let i = nextProps.data.length - this.wholeDataLength - 1; i >= 0; --i) {
            const tmp = toDateString(nextProps.data[i][0])
            if (dateString !== tmp) {
              dateString = tmp
              this.showData.push(nextProps.data[i])
              const dataitem = []
              for (const [j, item] of nextProps.data[i]) {
                if (j === 0) continue
                dataitem.push([j - 1, [nextProps.data[i][0], item, this.showData.length - 1], false, true, ''])
              }
              this.resourceChart.addData(dataitem)
            }
          }
        }
      } else {
        this.showData = this.dataFilter(nextProps.data)
        this.dataLength = this.showData.length
        this.showData.reverse()
        if (this.showData.length !== 0) {
          this.resourceChart.hideLoading()
          this.resourceChart.setOption(this.getEChartsOption(), true)
        }
      }
      this.dataLength = this.showData.length
      this.wholeDataLength = nextProps.data.length
    }
    return false
  }
  render() {
    return (
      <Grid>
        <Row>
          <Col xs={12}>
             <div id="ECharts" style={{ height: "500px" }} ref={(ref) => this.chart = ref}></div>
          </Col>
        </Row>
      </Grid>
    )
  }
}

export default AkashicResourceChart
