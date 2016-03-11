{React, ReactBootstrap, jQuery, config, __, CONST} = window
{Panel, Button, Col, Input, Grid, Row, ButtonGroup, DropdownButton,
  MenuItem, Table, OverlayTrigger, Popover, Collapse, Well} = ReactBootstrap
Divider = require '../divider'
{openExternal} = require 'shell'

boundActivePageNum = (activePage, logLength, showAmount) ->
  activePage = Math.min activePage, Math.ceil(logLength/showAmount)
  activePage = Math.max activePage, 1

AkashicRecordsStatisticsPanel = React.createClass
  shouldComponentUpdate: (nextProps, nextState)->
    @props.show isnt nextProps.show or
    not @props.searchItems.equals(nextProps.searchItems) or
    not @props.statisticsItems.equals(nextProps.statisticsItems)
  handlePanelShow: ->
    show = not @props.show
    config.set "plugin.Akashic.#{@props.contentType}.statisticsPanelShow", show
    @props.setPanelVisibilitiy show

  handleAddSearch: ->
    @props.onSeaRuleAdd()
  handleDeleteSearchLine: (index)->
    @props.onSeaRuleDelete index
  handleSeaBaseSet: (index)->
    @props.onSeaRuleBaseSet index, @refs["baseOn#{index}"].getValue()
  onSeaRuleKeySet: (index)->
    @props.onSeaRuleBaseSet index, @refs["search#{index}"].getValue()

  handleAddStat: ->
    @props.onStatRuleAdd()
  handleDeleteStat: (index)->
    @props.onStatRuleDelete index
  handleStatNTypeSet: (index)->
    @props.onStatRuleNTypeSet index, @refs["NType#{index}"].getValue()
  handleStatRuleNSet: (index)->
    @props.onStatRuleNSet index, @refs["numerator#{index}"].getValue()
  handleStatDTypeSet: (index)->
    @props.onStatRuleDTypeSet index, @refs["DType#{index}"].getValue()
  handleStatRuleDSet: (index)->
    @props.onStatRuleDSet index, @refs["denominator#{index}"].getValue()

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
                            <li>
                              {__ "Support the Javascript's "}
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
                      <th>{__ "Base on"}</th>
                      <th>{__ "Keywords"}</th>
                      <th>{__ "Result"}</th>
                      <th>{__ "Sample Size"}</th>
                      <th>{__ "Percentage"}</th>
                    </tr>
                  </thead>
                  <tbody>
                  {
                    for index in [0...@props.searchItems.size]
                      <tr key={index}>
                        {
                          if index is 0
                            <td style={verticalAlign: 'middle'}>
                              <FontAwesome name='plus-circle' onClick={@handleAddSearch}/>
                            </td>
                          else
                            <td style={verticalAlign: 'middle'}>
                              <FontAwesome name='minus-circle' onClick={@handleDeleteSearchLine.bind(@, index)}/>
                            </td>
                        }
                        <td>{index+1}</td>
                        <td>
                          <Input type="select" ref="baseOn#{index}" groupClassName='search-area' value={"#{@props.searchItems.get(index).get('baseOn')}"} onChange={@handleSeaBaseSet.bind(@, index)}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>
                              {__ "All Data"}
                            </option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>
                              {__ "Filtered"}
                            </option>
                            {
                              for i in [1...index+1]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>
                                  {__ "Search Result No. %s", i}
                                </option>
                            }
                          </Input>
                        </td>
                        <td>
                           <Input
                              type='text'
                              value={@props.searchItems.get(index).get('content')}
                              placeholder={__ "Keywords"}
                              ref="search#{index}"
                              groupClassName='search-area'
                              onChange={@onSeaRuleKeySet.bind(@, index)} />
                        </td>
                        <td>{@props.searchItems.get(index).get('res')}</td>
                        <td>{@props.searchItems.get(index).get('total')}</td>
                        <td>{@props.searchItems.get(index).get('percent')}</td>
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
                    for index in [0...@props.statisticsItems.size]
                      <tr key={index}>
                        {
                          if index is 0
                            <td style={verticalAlign: 'middle'}>
                              <FontAwesome name='plus-circle' onClick={@handleAddStat}/>
                            </td>
                          else
                            <td style={verticalAlign: 'middle'}>
                              <FontAwesome name='minus-circle' onClick={@handleDeleteStat.bind(@, index)}/>
                            </td>
                        }
                        <td>{index+1}</td>
                        <td>
                          <Input type="select" ref="NType#{index}" groupClassName='search-area' value={"#{@props.statisticsItems.get(index).get('numeratorType')}"} onChange={@handleStatNTypeSet.bind(@, index)}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..@props.searchItems.size]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                            <option key={-1} value={-1}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        <td>
                          <Input type="select" ref="DType#{index}" groupClassName='search-area' value={"#{@props.statisticsItems.get(index).get('denominatorType')}"} onChange={@handleStatDTypeSet.bind(@, index)}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..@props.searchItems.size]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                            <option key={-1} value={-1}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        {
                          if @props.statisticsItems.get(index).get('numeratorType') is -1
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@props.statisticsItems.get(index).get('numerator')}"}
                                ref="numerator#{index}"
                                groupClassName='search-area'
                                onChange={@handleStatRuleNSet.bind(@, index)} />
                            </td>
                          else
                            <td>{@props.statisticsItems.get(index).get('numerator')}</td>
                        }
                        {
                          if @props.statisticsItems.get(index).get('denominatorType') is -1
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@props.statisticsItems.get(index).get('denominator')}"}
                                ref="denominator#{index}"
                                groupClassName='search-area'
                                onChange={@handleStatRuleDSet.bind(@, index)} />
                            </td>
                          else
                            <td>{@props.statisticsItems.get(index).get('denominator')}</td>
                        }
                        <td>{@props.statisticsItems.get(index).get('percent')}</td>
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
