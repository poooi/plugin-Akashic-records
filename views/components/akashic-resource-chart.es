import React from 'react'
import {
  Grid,
  Row,
  Col,
} from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
// eslint-disable-next-line
import dark from '../../assets/themes/dark'
// eslint-disable-next-line
import { WindowEnv } from 'views/components/etc/window-env'
import images from '../../assets/img'

const echarts = require('../../assets/echarts')
const { config, i18n } = window
const { __ } = i18n['poi-plugin-akashic-records']

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
      rowChooseChecked: [
        true, true, true, true, true, true, true, true, true, true, true, true, true, true,
      ],
    }
    this.showAsDay = config.get("plugin.Akashic.resource.chart.showAsDay", true)
    this.showSymbol = config.get("plugin.Akashic.resource.chart.showSymbol", false)
    this.resourceChart = 0
    this.wholeDataLength = 0
    this.dataLength = 0
    this.showData = []

    props.window.onresize = () => {
      try {
        const { window } = props
        window.document.getElementById('ECharts').style.height = `${window.innerHeight - 150}px`
        if (this.resourceChart !== 0) {
          this.resourceChart.resize()
        }
        return true
      } catch(err) {
        console.error(err)
        return true
      }
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
    const toIcon = source => `image://${source}`
    return {
      tooltip: {
        trigger: "axis",
        show: true,
        padding: 10,
        confine: true,
        formatter(params) {
          const dateString = toDateLabel(params[0].value[0])
          const resArray = params.map(item => `${item.seriesName}: ${item.value[1]}`)
          resArray.unshift(`${dateString}`)
          return resArray.join('<br/>')
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
        textStyle: {
          color: '#ddd',
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
            title: __("Restore"),
          },
          saveAsImage: {
            show: true,
            backgroundColor: '#343434',
          },
          myShowScale: ((showAsDay) => {
            const opt = showAsDay
              ? {
                title: __("Show by %s", __("Day")),
                icon: toIcon(images.day),
              } : {
                title:  __("Show by %s", __("Hour")),
                icon: toIcon(images.hour),
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
                  if (this.resourceChart.getOption().series == null) {
                    this.resourceChart.hideLoading()
                  }
                  this.resourceChart.setOption(this.getEChartsOption(), true)
                }
                config.set("plugin.Akashic.resource.chart.showAsDay", this.showAsDay)
              },
            }
          })(this.showAsDay),
          myShowType: ((showSymbol) => {
            const opt = showSymbol
              ? {
                title: __("Show node"),
                icon: toIcon(images.withNodeInSleepMode),
              } : {
                title: __("Hide node"),
                icon: toIcon(images.withNoNodeInSleepMode),
              }
            const showType = {
              show: true,
              ...opt,
              color: '#eee',
              onclick: () => {
                this.showSymbol = !this.showSymbol
                this.resourceChart.setOption(this.getEChartsOption(), true)
                config.set("plugin.Akashic.resource.chart.showSymbol", this.showSymbol)
              },
            }
            return showType
          })(this.showSymbol),
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
          color: "#ddd",
        },
      },
      xAxis: [{
        type: 'time',
        splitNumber: 10,
        axisLabel: {
          textStyle: {
            color: '#ddd',
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
              color: '#ddd',
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
          name: __('Fuel'),
          smooth: true,
          type: "line",
          yAxisIndex: 0,
          itemStyle: {
            normal: { color: '#1b9d19' },
          },
          symbol: 'rect',
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[1], index]),
        },
        {
          name: __('Ammo'),
          smooth: true,
          type: "line",
          yAxisIndex: 0,
          symbol: 'roundRect',
          itemStyle: {
            normal: { color: '#663910' },
          },
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[2], index]),
        },
        {
          name: __('Steel'),
          smooth: true,
          type: "line",
          symbol: 'triangle',
          yAxisIndex: 0,
          itemStyle: {
            normal: { color: '#919191' },
          },
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[3], index]),
        },
        {
          name: __('Bauxite'),
          smooth: true,
          type: "line",
          symbol: 'diamond',
          yAxisIndex: 0,
          itemStyle: {
            normal: { color: '#b37c50' },
          },
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[4], index]),
        },
        {
          name: __('Fast Build Item'),
          type: "line",
          symbol: 'arrow',
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#fb8a00' },
          },
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[5], index]),
        },
        {
          name: __('Instant Repair Item'),
          type: "line",
          symbol: 'pin',
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#32eca1' },
          },
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[6], index]),
        },
        {
          name: __('Development Material'),
          type: "line",
          symbol: 'circle',
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#419ba9' },
          },
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[7], index]),
        },
        {
          name: __('Improvement Materials'),
          type: "line",
          symbol: 'emptyCircle',
          yAxisIndex: 1,
          itemStyle: {
            normal: { color: '#aaaaaa' },
          },
          showSymbol: this.showSymbol,
          data: this.showData.map((logitem, index) =>
            [logitem[0], logitem[8], index]),
        },
      ],
    }
  }

  renderChart() {
    const node = findDOMNode(this.chart)
    const theme = dark
    this.resourceChart = this.resourceChart || echarts.init(node, theme)
    const option = this.getEChartsOption()
    this.resourceChart.setOption(option)
  }

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
      if (this.resourceChart.getOption().series != null) {
        if (!this.showAsDay) {
          for (let i = nextProps.data.length - this.wholeDataLength - 1; i >= 0; --i) {
            this.showData.push(nextProps.data[i])
            nextProps.data[i].slice(1).forEach((item, idx) => {
              this.resourceChart.appendData({
                seriesIndex: idx,
                data: [nextProps.data[i][0], item, this.showData.length - 1],
              })
            })
            this.resourceChart.setOption(this.getEChartsOption())
          }
        } else {
          for (let i = nextProps.data.length - this.wholeDataLength - 1; i >= 0; --i) {
            const tmp = toDateString(nextProps.data[i][0])
            if (dateString !== tmp) {
              dateString = tmp
              this.showData.push(nextProps.data[i])
              nextProps.data[i].slice(1).forEach((item, idx) => {
                this.resourceChart.appendData({
                  seriesIndex: idx,
                  data: [nextProps.data[i][0], item, this.showData.length - 1],
                })
              })
              this.resourceChart.setOption(this.getEChartsOption())
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

const Chart = props => (
  <WindowEnv.Consumer>
    {({ window }) => <AkashicResourceChart window={window} {...props} />}
  </WindowEnv.Consumer>
)
export default Chart
