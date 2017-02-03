import React from 'react'
import {
  Col,
  FormControl,
  Grid,
  Row,
  Collapse,
  Table,
  OverlayTrigger,
  Popover,
} from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
import FontAwesome from 'react-fontawesome'
import Divider from '../divider'

const { config, __, CONST } = window
const { openExternal } = require('electron').shell

// function boundActivePageNum(activePage, logLength, showAmount) {
//   const ret = Math.min(activePage, Math.ceil(logLength/showAmount))
//   return Math.max(ret, 1)
// }

class AkashicRecordsStatisticsPanel extends React.Component {
  constructor(props) {
    super(props)
    this.input = {}
    this.baseOn = {}
  }
  shouldComponentUpdate(nextProps, nextState) {
    return this.props.show !== nextProps.show ||
      this.props.searchItems !== nextProps.searchItems ||
      this.props.statisticsItems !== nextProps.statisticsItems
  }

  handlePanelShow = () => {
    const show = !this.props.show
    config.set(`plugin.Akashic.${this.props.contentType}.statisticsPanelShow`,
               show)
    this.props.setPanelVisibilitiy(show)
  }
  handleAddSearch = () => {
    this.props.onSeaRuleAdd()
  }
  handleDeleteSearchLine = (index) => {
    this.props.onSeaRuleDelete(index)
  }
  handleSeaBaseSet = (index) => {
    this.props.onSeaRuleBaseSet(
      index, parseInt(findDOMNode(this.baseOn[`baseOn${index}`]).value))
  }
  handleSeaRuleKeySet = (index) => {
    this.props.onSeaRuleKeySet(index, findDOMNode(this.input[`search${index}`]).value)
  }
  handleAddStat = () => {
    this.props.onStatRuleAdd()
  }
  handleDeleteStat = (index) => {
    this.props.onStatRuleDelete(index)
  }
  handleStatNTypeSet = (index) => {
    this.props.onStatRuleNTypeSet (index, parseInt(findDOMNode(this.baseOn[`NType${index}`]).value))
  }
  handleStatRuleNSet = (index) => {
    this.props.onStatRuleNSet(index, parseInt(findDOMNode(this.input[`numerator${index}`]).value))
  }
  handleStatDTypeSet = (index) => {
    this.props.onStatRuleDTypeSet(index, parseInt(findDOMNode(this.baseOn[`DType${index}`]).value))
  }
  handleStatRuleDSet = (index) => {
    this.props.onStatRuleDSet(index, parseInt(findDOMNode(this.input[`denominator${index}`]).value))
  }

  render() {
    return (
      <Grid>
        <Row>
            <Col xs={12}>
              <div onClick={this.handlePanelShow}>
                <Divider text={__("Statistics")} icon={true} hr={true} show={this.props.show}/>
              </div>
            </Col>
          </Row>
          <Collapse className='akashic-records-statistics' in={this.props.show}>
            <div>
              <Row>
                <Col xs={12}>
                  <Table bordered responsive>
                    <thead>
                      <tr>
                        <th style={{ verticalAlign: 'middle' }}>
                          <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                            <Popover title={__("Tips")} id={"regExp-Hint"}>
                              <li>
                                {__("Support the Javascript's ")}
                                <a onClick={openExternal.bind(this, "http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>
                                  {"RegExp"}
                                </a>
                              </li>
                            </Popover>
                            }>
                            <FontAwesome name='question-circle'/>
                          </OverlayTrigger>
                        </th>
                        <th>No.</th>
                        <th>{__("Base on")}</th>
                        <th>{__("Keywords")}</th>
                        <th>{__("Result")}</th>
                        <th>{__("Sample Size")}</th>
                        <th>{__("Percentage")}</th>
                      </tr>
                    </thead>
                    <tbody>
                    {
                      Array(this.props.searchItems.length).fill().map((_, index) => (
                        <tr key={index}>
                          {
                            (index === 0)
                              ? (
                                <td style={{ verticalAlign: 'middle' }}>
                                  <FontAwesome name='plus-circle' onClick={this.handleAddSearch}/>
                                </td>
                              ) : (
                                <td style={{ verticalAlign: 'middle' }}>
                                  <FontAwesome name='minus-circle' onClick={this.handleDeleteSearchLine.bind(this, index)}/>
                                </td>
                              )
                          }
                          <td>{index + 1}</td>
                          <td>
                            <FormControl
                              componentClass="select"
                              ref={(() => {
                                const tmp = index
                                return (ref) => this.baseOn[`baseOn${tmp}`] = ref
                              })()}
                              groupClassName='search-area'
                              value={`${this.props.searchItems[index].baseOn}`}
                              onChange={this.handleSeaBaseSet.bind(this, index)}>
                              <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>
                                {__("All Data")}
                              </option>
                              <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>
                                {__("Filtered")}
                              </option>
                              {
                                Array(index).fill().map((_, i) => (
                                  <option
                                    key={CONST.search.indexBase + (i + 1)}
                                    value={CONST.search.indexBase + (i + 1)}
                                  >
                                    {__("Search Result No. %s", i + 1)}
                                  </option>
                                ), this)
                              }
                            </FormControl>
                          </td>
                          <td>
                             <FormControl
                                type='text'
                                placeholder={__("Keywords")}
                                ref={(() => {
                                  const tmp = index
                                  return (ref) => this.input[`search${tmp}`] = ref
                                })()}
                                value={this.props.searchItems[index].content}
                                groupClassName='search-area'
                                onChange={this.handleSeaRuleKeySet.bind(this, index)} />
                          </td>
                          <td>{this.props.searchItems[index].res}</td>
                          <td>{this.props.searchItems[index].total}</td>
                          <td>{this.props.searchItems[index].percent}</td>
                        </tr>
                      ))
                    }
                    </tbody>
                    <thead>
                      <tr>
                        <th></th>
                        <th>No.</th>
                        <th>{__("Numerator")}</th>
                        <th>{__("Denominator")}</th>
                        <th>{__("Numerator Number")}</th>
                        <th>{__("Denominator Number")}</th>
                        <th>{__("Percentage")}</th>
                      </tr>
                    </thead>
                    <tbody>
                    {
                      Array(this.props.statisticsItems.length).fill().map((_, index) => (
                        <tr key={index}>
                          {
                            (index === 0)
                              ? (
                                <td style={{ verticalAlign: 'middle' }}>
                                  <FontAwesome name='plus-circle' onClick={this.handleAddStat}/>
                                </td>
                              ) : (
                                <td style={{ verticalAlign: 'middle' }}>
                                  <FontAwesome name='minus-circle' onClick={this.handleDeleteStat.bind(this, index)}/>
                                </td>
                              )
                          }
                          <td>{index+1}</td>
                          <td>
                            <FormControl
                              componentClass="select"
                              ref={(() => {
                                const tmp = index
                                return (ref) => this.baseOn[`NType${tmp}`] = ref
                              })()}
                              groupClassName='search-area'
                              value={`${this.props.statisticsItems[index].numeratorType}`}
                              onChange={this.handleStatNTypeSet.bind(this, index)}>
                              <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__("All Data")}</option>
                              <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__("Filtered")}</option>
                              {
                                Array(this.props.searchItems.length).fill().map((_, i) => (
                                  <option
                                    key={CONST.search.indexBase + (i + 1)}
                                    value={CONST.search.indexBase + (i + 1)}
                                  >
                                    {__("Search Result No. %s", i + 1)}
                                  </option>
                                ), this)
                              }
                              <option key={-1} value={-1}>{__("Custom")}</option>
                            </FormControl>
                          </td>
                          <td>
                            <FormControl
                              componentClass="select"
                              ref={(() => {
                                const tmp = index
                                return (ref) => this.baseOn[`DType${tmp}`] = ref
                              })()}
                              groupClassName='search-area'
                              value={`${this.props.statisticsItems[index].denominatorType}`}
                              onChange={this.handleStatDTypeSet.bind(this, index)}>
                              <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__("All Data")}</option>
                              <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__("Filtered")}</option>
                              {
                                Array(this.props.searchItems.length).fill().map((_, i) => (
                                  <option
                                    key={CONST.search.indexBase + (i + 1)}
                                    value={CONST.search.indexBase + (i + 1)}
                                  >
                                    {__("Search Result No. %s", i + 1)}
                                  </option>
                                ), this)
                              }
                              <option key={-1} value={-1}>{__("Custom")}</option>
                            </FormControl>
                          </td>
                          {
                            (this.props.statisticsItems[index].numeratorType === -1)
                              ? (
                                <td>
                                  <FormControl
                                    type='number'
                                    placeholder={"0"}
                                    value={`${this.props.statisticsItems[index].numerator}`}
                                    ref={(() => {
                                      const tmp = index
                                      return (ref) => this.input[`numerator${tmp}`] = ref
                                    })()}
                                    groupClassName='search-area'
                                    onChange={this.handleStatRuleNSet.bind(this, index)} />
                                </td>
                              ) : (
                                <td>{this.props.statisticsItems[index].numerator}</td>
                              )
                          }
                          {
                            (this.props.statisticsItems[index].denominatorType === -1)
                              ? (
                                <td>
                                  <FormControl
                                    type='number'
                                    placeholder={"0"}
                                    value={`${this.props.statisticsItems[index].denominator}`}
                                    ref={(() => {
                                      const tmp = index
                                      return (ref) => this.input[`denominator${tmp}`] = ref
                                    })()}
                                    groupClassName='search-area'
                                    onChange={this.handleStatRuleDSet.bind(this, index)} />
                                </td>
                              ) : (
                                <td>{this.props.statisticsItems[index].denominator}</td>
                              )
                          }
                          <td>{this.props.statisticsItems[index].percent}</td>
                        </tr>
                      ), this)
                    }
                    </tbody>
                  </Table>
                </Col>
              </Row>
            </div>
          </Collapse>
      </Grid>
    )
  }
}

export default AkashicRecordsStatisticsPanel
