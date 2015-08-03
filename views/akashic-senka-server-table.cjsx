{React, ReactBootstrap, ROOT, APPDATA_PATH} = window
{Grid, Row, Col, Table, ButtonGroup, Input} = ReactBootstrap
path = require 'path-extra'
fs = require 'fs-extra'
glob = require 'glob'
Promise = require 'bluebird'
async = Promise.coroutine
request = Promise.promisifyAll require('request')
{log, error} = require path.join(ROOT, 'lib/utils')

    #return new {
    #            name = String
    #            date = String
    #            list = Array Of Object{
    #                ranking = Int32
    #                level = Int32
    #                player_id = Int64
    #                player_name = String
    #                comment = String
    #                rank_point = Int32
    #                rank_name = String
    #                medals = Int32
    #                ranking_delta = Nullable Int32
    #                rank_point_delta = Nullable Int32
    #            }
    #        };
AkashicSenkaServerTableTbodyItem = React.createClass
  render: ->
    <tr>
      {
        if @props.data["ranking_delta"] > 0
          delta = "↑#{@props.data["ranking_delta"]}"
        else if @props.data["ranking_delta"] < 0
          delta = "↓#{-@props.data["ranking_delta"]}"
        else
          delta = "-"
        <td>{"#{@props.data["ranking"]}(#{delta})"}</td>
      }
        <td>{@props.data["level"]}</td>
        <td>{@props.data["player_name"]}</td>
        <td>{@props.data["rank_name"]}</td>
        <td>{@props.data["comment"]}</td>
      {
        if @props.data["rank_point_delta"] == null
          <td>{"#{@props.data["rank_point"]}"}</td>
        else
          <td>{"#{@props.data["rank_point"]}(#{@props.data["rank_point_delta"]})"}</td>
      }
      {
        if @props.data["medals"] > 0
          <td>{"甲#{@props.data["medals"]}"}</td>
        else
          <td></td>
      }
    </tr>

AkashicSenkaServerTable = React.createClass
  getInitialState: ->
    filterKey: ""
  shouldComponentUpdate: (nextProps, nextState) ->
    if nextProps.data? and nextProps.data isnt @props.data
      true
    else
      false
  render: ->
    <div>
      <Grid>
        <Row>
          <Col xs={12}>
            <Table striped bordered condensed hover Responsive>
              <thead>
                <tr>
                  {
                    for tab, index in @props.tableTab
                      <th>{tab}</th>
                  }
                </tr>
              </thead>
              <tbody>
                  {
                    if @props.data isnt []
                      if @props.data.length > 0
                        for item,index in @props.data
                          if index == @props.data.length-1
                            lastFlag = 1
                          else
                            lastFlag = 0
                          <AkashicSenkaServerTableTbodyItem
                            key = {index}
                            data = {item}
                            lastFlag = {lastFlag}
                            index = {index}
                          />
                   }
              </tbody>
            </Table>
          </Col>
        </Row>
      </Grid>
    </div>

module.exports = AkashicSenkaServerTable
