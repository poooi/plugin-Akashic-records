import React from 'react'
import {
  Col,
  FormControl,
  Grid,
  Row,
  Table,
  OverlayTrigger,
  Popover,
} from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
import FontAwesome from 'react-fontawesome'
import { dateToString } from '../../lib/utils'

import Pagination from './pagination'

const { ipc } = window

const { __ } = window.i18n['poi-plugin-akashic-records']

const {openExternal} = require('electron').shell

// import i18n from '../node_modules/i18n'
// {__} = i18n

function showBattleDetail(timestamp) {
  try {
    if (window.ipc == null) {
      throw `${__("Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release.")}`
    }

    const battleDetailPlugin = window.getStore('plugins').find(p => p.id === 'poi-plugin-battle-detail')
    if (!battleDetailPlugin || !battleDetailPlugin.enabled) {
      throw `${__("In order to find the detailed battle log, you need to download the latest battle-detail plugin and enable it.")}`
    }

    timestamp = (new Date(timestamp)).getTime()

    const battleDetail = ipc.access('BattleDetail')
    if (battleDetail == null || battleDetail.showBattleWithTimestamp == null) {
      ipc.register("BattleDetail", {
        timestamp,
      })
    } else {
      battleDetail.showBattleWithTimestamp(timestamp, (message) => {
        if (message) {
          window.toggleModal("Warning", `${__('Battle Detail')}: ${message}`)
        }
      })
    }

    const mainWindow = ipc.access('MainWindow')
    if (mainWindow && mainWindow.ipcFocusPlugin) {
      mainWindow.ipcFocusPlugin('poi-plugin-battle-detail')
    }
  } catch (e) {
    window.toggleModal('Warning', e)
  }
}

const parseMapInfo = (mapStr) => {
  if (!mapStr.includes('|'))
    return mapStr

  const match = mapStr.match(/\((\d+)-\d+ /)
  if (!match)
    return mapStr

  const eventId = parseInt(match[1], 10)
  if (`${eventId}` !== match[1])
    return mapStr

  const parts =mapStr.split('|')
  const rank = parseInt(parts[1], 10) || 0
  const rankText = (eventId < 41)
    ? ['', '丙', '乙', '甲'][rank]
    : ['', '丁', '丙', '乙', '甲'][rank]

  return parts[0].trim().replace('%rank', rankText)
}

const AkashicRecordsTableTbodyItem = (props) => (
  <tr>
    <td style={{textAlign: "right"}}>
      {
        (props.contentType === 'attack' && props.data[2] !== '基地防空戦') ?
          (<FontAwesome name='info-circle' style={{ marginRight: 3 }} onClick={() => showBattleDetail(props.data[0])}/>) : null
      }
      {props.index}
    </td>
    {
      props.data.map((item, index) => {
        if (index === 0 && props.rowChooseChecked[1]) {
          return (<td key={index}>{dateToString(new Date(+item))}</td>)
        } else if (props.contentType === 'attack' && index === 1) {
          return (props.rowChooseChecked[2]) ? (<td key={index}>{parseMapInfo(item)}</td>) : null
        } else if (props.contentType === 'attack' && (index === 4 || index === 5 || index === 7)) {
          return (props.rowChooseChecked[8]) ? (<td key={index} className="overflow" title={item}>{item}</td>) : null
        } else {
          return (props.rowChooseChecked[index+1]) ? (<td key={index}>{item}</td>) : null
        }
      })
    }
  </tr>
)

class AkashicRecordsTableArea extends React.Component {
  constructor(props) {
    super(props)
    this.input = {}
  }

  handleKeyWordChange = (index) => {
    this.props.onFilterKeySet(index - 1,  findDOMNode(this.input[`input${index}`]).value)
  }

  handlePaginationSelect = (idx) => {
    this.props.onActivePageSet(idx)
  }

  // # componentDidUpdate: ()=>
  // #   console.log `Table Area Update`

  render() {
    let showLabel = this.props.configListChecked[0]
    let showFilter = this.props.configListChecked[1]
    if (this.props.configListChecked[2]) {
      showFilter = true
      showLabel = showLabel || this.props.filterKeys.some((filterKey, index) =>
        this.props.tabVisibility[index + 1] && filterKey !== ''
      )
    }
    const startLogs = (this.props.activePage - 1) * this.props.showAmount
    const endLogs = Math.min(this.props.activePage * this.props.showAmount, this.props.logs.length)
    return (
      <div>
        <Grid>
          <Row>
            <Col xs={12}>
              <Table striped bordered condensed hover>
                <thead>
                  {
                    (showLabel && !showFilter) ? (
                      <tr>
                        {
                          this.props.tableTab.map((tab, index) => (
                            this.props.tabVisibility[index] ? <th key={index}>{tab}</th> : null
                          ))
                        }
                      </tr>
                    ) : (
                      (showLabel || showFilter) ? (
                        <tr>
                          {
                            this.props.tableTab.map((tab, index) =>
                              (index === 0) ? (
                                <th key={index}>
                                  <OverlayTrigger trigger='hover' rootClose={true} placement='right' overlay={
                                    <Popover id="table-tips" title={__("Tips")} style={{backgroundColor: '#6e6e6e', borderWidth: 0}}>
                                      <li>{__("Disable filtering while hiding column")}</li>
                                      <li>{__("Support the Javascript's ")}<a onClick={openExternal.bind(this, "http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>{"RegExp"}</a></li>
                                    </Popover>
                                  }>
                                    <FontAwesome name='question-circle' style={{ marginLeft: "3px"}}/>
                                  </OverlayTrigger>
                                </th>
                              ) : (
                                this.props.tabVisibility[index] ? (
                                  <th key={index} className="table-search">
                                    <FormControl
                                      type='text'
                                      placeholder={this.props.tableTab[index]}
                                      ref={(() => {
                                        const tmp = index
                                        return (ref) => this.input[`input${tmp}`] = ref
                                      })()}
                                      groupClassName='filter-area'
                                      value={`${this.props.filterKeys[index-1]}`}
                                      onChange={this.handleKeyWordChange.bind(this, index)} />
                                  </th>
                                ) : null
                              )
                            )
                          }
                        </tr>
                      ) : null
                    )
                  }
                </thead>
                <tbody>
                  {
                    Array(endLogs - startLogs).fill().map((_, i) => {
                      const index = startLogs + i
                      const item = this.props.logs[index]
                      return (
                        <AkashicRecordsTableTbodyItem
                          key = {item[0]}
                          index = {index+1}
                          data={item}
                          rowChooseChecked={this.props.tabVisibility}
                          contentType={this.props.contentType}
                          tableTab={this.props.tableTab}
                        />
                      )
                    })
                  }
                </tbody>
              </Table>
            </Col>
          </Row>
          <Row>
            <Col xs={12}>
              <Pagination className='akashic-table-pagination'
                max={this.props.paginationItems}
                curr={this.props.activePage}
                handlePaginationSelect={this.handlePaginationSelect}
              />
            </Col>
          </Row>
        </Grid>
      </div>
    )
  }
}

export default AkashicRecordsTableArea
