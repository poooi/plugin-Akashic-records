import React from 'react'
import {
  Col,
  FormGroup,
  ControlLabel,
  FormControl,
  Grid,
  Row,
  Table,
  OverlayTrigger,
  Popover,
  Pagination,
} from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
import FontAwesome from 'react-fontawesome'

const { __, ipc } = window
const {openExternal} = require('electron').shell

// import i18n from '../node_modules/i18n'
// {__} = i18n

function dateToString(date) {
  const month = date.getMonth() < 9 ?
    `0${date.getMonth() + 1}` : `${date.getMonth() + 1}`
  const day = date.getDate() < 9 ?
    `0${date.getDate() + 1}` : `${date.getDate() + 1}`
  const hour = date.getHours() < 9 ?
    `0${date.getHours() + 1}` : `${date.getHours() + 1}`
  const minute = date.getMinutes() < 9 ?
    `0${date.getMinutes() + 1}` : `${date.getMinutes() + 1}`
  const second = date.getSeconds() < 9 ?
    `0${date.getSeconds() + 1}` : `${date.getSeconds() + 1}`
  return `${date.getFullYear()}/${month}/${day} ${hour}:${minute}:${second}`
}

function showBattleDetail(timestamp) {
  try {
    if (window.ipc == null) {
      throw `${__("Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release.")}`
    }

    const battleDetail = ipc.access('BattleDetail')
    if (battleDetail == null || battleDetail.showBattleWithTimestamp == null) {
      throw `${__("In order to find the detailed battle log, you need to download the latest battle-detail plugin and enable it.")}`
    }

    timestamp = (new Date(timestamp)).getTime()
    battleDetail.showBattleWithTimestamp(timestamp, (message) => {
      if (message) {
        window.toggleModal("Warning", `${__('Battle Detail')}: ${message}`)
      }
    })
  } catch (e) {
    window.toggleModal('Warning', e)
  }
}

const AkashicRecordsTableTbodyItem = (props) => (
  <tr>
    <td>
    {
      (props.contentType === 'attack') ?
        (<FontAwesome name='info-circle' style={{ marginRight: 3 }} onClick={() => showBattleDetail(props.data[0])}/>) : null
    }
    {props.index}
    </td>
    {
      props.data.map((item, index) => {
        if (index === 0 && props.rowChooseChecked[1]) {
          return (<td key={index}>{dateToString(new Date(item))}</td>)
        } else if (props.contentType === 'attack' && props.tableTab[index+1] === '大破舰') {
          return (props.rowChooseChecked[8]) ? (<td key={index} className="enable-auto-newline">{item}</td>) : null
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

  handlePaginationSelect = (key, selectedEvent) => {
    this.props.onActivePageSet(selectedEvent.eventKey || key)
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
                              <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                                <Popover id="table-tips" title={__("Tips")}>
                                  <li>{__("Disable filtering while hiding column")}</li>
                                  <li>{__("Support the Javascript's ")}<a onClick={openExternal.bind(this, "http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>{"RegExp"}</a></li>
                                </Popover>
                                }>
                                <FontAwesome name='question-circle'/>
                              </OverlayTrigger>
                            </th>
                          ) : (
                            this.props.tabVisibility[index] ? (
                              <th key={index} className="table-search">
                                <FormGroup controlId={index}>
                                  <ControlLabel>{showLabel ? this.props.tableTab[index] : ''}</ControlLabel>
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
                                </FormGroup>
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
                prev={false}
                next={false}
                first={true}
                last={true}
                ellipsis={true}
                items={this.props.paginationItems}
                maxButtons={Math.min(this.props.paginationItems, 5)}
                activePage={this.props.activePage}
                onSelect={this.handlePaginationSelect}
              />
            </Col>
          </Row>
        </Grid>
      </div>
    )
  }
}

export default AkashicRecordsTableArea
