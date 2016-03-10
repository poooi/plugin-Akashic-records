{React, ReactBootstrap, jQuery, config, __, CONST} = window
{Panel, Button, Col, Input, Grid, Row, ButtonGroup, DropdownButton,
  MenuItem, Table, OverlayTrigger, Popover, Collapse, Well} = ReactBootstrap
Divider = require './divider'
{openExternal} = require 'shell'

dataManager = require '../lib/data-manager'

boundActivePageNum = (activePage, logLength, showAmount) ->
  activePage = Math.min activePage, Math.ceil(logLength/showAmount)
  activePage = Math.max activePage, 1

AkashicRecordsStatisticsPanel = React.createClass
  handlePanelShow: ->
    show = not @props.show
    config.set "plugin.Akashic.#{@props.contentType}.statisticsPanelShow", show
    @props.setPanelVisibilitiy show

  handleAddSearch: ->
    @props.onSeaRuleAdd()
  handleDeleteSearchLine: (index)->
    @props.onSeaRuleDelete(index)

  handleAddStat: ->
    @props.onStatRuleAdd()
  handleDeleteStat: (index)->
    @props.onStatRuleDelete(index)

  render: ->
    <Grid>
      <Row>
          <Col xs={12}>
            <div onClick={@handlePanelShow}>
              <Divider text={__ "Statistics"} icon={true} hr={true} show={@props.show}/>
            </div>
          </Col>
        </Row>
        <Collapse className='akashic-records-statistics' in={@props.show}>
          <div>
            <Row>
              <Col xs={12}>
                <Table bordered responsive>
                  <thead>
                    <tr>
                      <th style={verticalAlign: 'middle'}>
                        <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                          <Popover title={__ "Tips"} id={"regExp-Hint"}>
                            <li>{__ "Support the Javascript's "}<a onClick={openExternal.bind(this, "http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>{"RegExp"}</a></li>
                          </Popover>
                          }>
                          <FontAwesome name='question-circle'/>
                        </OverlayTrigger>
                      </th>
                      <th>No.</th>
                      <th>{__ "Base on"}</th>
                      <th>{__ "Keywords"}</th>
                      <th>{__ "Result"}</th>
                      <th>{__ "Sample Size"}</th>
                      <th>{__ "Percentage"}</th>
                    </tr>
                  </thead>
                  <tbody>
                  {
                    for index in [0...@props.searchItems.length]
                      <tr key={index}>
                        {
                          if index is 0
                            <td style={verticalAlign: 'middle'}><FontAwesome name='plus-circle' onClick={@addSearchLine}/></td>
                          else
                            <td style={verticalAlign: 'middle'}><FontAwesome name='minus-circle' onClick={@deleteSearchLine.bind(@, index)}/></td>
                        }
                        <td>{index+1}</td>
                        <td>
                          <Input type="select" ref="baseOn#{index}" groupClassName='search-area' value={"#{@state.searchArgv[index].searchBaseOn}"} onChange={@handleSearchChange}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..index]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                          </Input>
                        </td>
                        <td>
                           <Input
                              type='text'
                              value={@state.searchArgv[index].filterKey}
                              placeholder={__ "Keywords"}
                              ref="search#{index}"
                              groupClassName='search-area'
                              onChange={@handleSearchChange} />
                        </td>
                        <td>{@state.searchArgv[index].res}</td>
                        <td>{@state.searchArgv[index].total}</td>
                        <td>{@state.searchArgv[index].percent}</td>
                      </tr>
                  }
                  </tbody>
                  <thead>
                    <tr>
                      <th></th>
                      <th>No.</th>
                      <th>{__ "Numerator"}</th>
                      <th>{__ "Denominator"}</th>
                      <th>{__ "Numerator Number"}</th>
                      <th>{__ "Denominator Number"}</th>
                      <th>{__ "Percentage"}</th>
                    </tr>
                  </thead>
                  <tbody>
                  {
                    for index in [0...@props.statisticsItems.length]
                      <tr key={index}>
                        {
                          if index is 0
                            <td style={verticalAlign: 'middle'}><FontAwesome name='plus-circle' onClick={@addCompareLine}/></td>
                          else
                            <td style={verticalAlign: 'middle'}><FontAwesome name='minus-circle' onClick={@deleteCompareLine.bind(@, index)}/></td>
                        }
                        <td>{index+1}</td>
                        <td>
                          <Input type="select" ref="numeratorBaseon#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index].numerator.baseOn}"} onChange={@handleCompareChange}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..@props.searchItems.length]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                            <option key={-1} value={-1}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        <td>
                          <Input type="select" ref="denominatorBaseon#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index].denominator.baseOn}"} onChange={@handleCompareChange}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..@props.searchItems.length]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                            <option key={-1} value={-1}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        {
                          if @state.compareArgv[index].numerator.baseOn is -1
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@state.compareArgv[index].numerator.num}"}
                                ref="numerator#{index}"
                                groupClassName='search-area'
                                onChange={@handleCompareChange} />
                            </td>
                          else
                            <td>{@state.compareArgv[index].numerator.num}</td>
                        }
                        {
                          if @state.compareArgv[index].denominator.baseOn is -1
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@state.compareArgv[index].denominator.num}"}
                                ref="denominator#{index}"
                                groupClassName='search-area'
                                onChange={@handleCompareChange} />
                            </td>
                          else
                            <td>{@state.compareArgv[index].denominator.num}</td>
                        }
                        <td>{@state.compareArgv[index].percent}</td>
                      </tr>
                  }
                  </tbody>
                </Table>
              </Col>
            </Row>
          </div>
        </Collapse>
    </Grid>

module.exports = AkashicRecordsStatisticsPanel
