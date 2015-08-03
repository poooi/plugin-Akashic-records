{React, ReactBootstrap, jQuery, config} = window
{Grid, Col, ButtonGroup, Button, Row, Input, option, Alert} = ReactBootstrap
glob = require 'glob'
path = require 'path-extra'
fs = require 'fs-extra'
Promise = require 'bluebird'
async = Promise.coroutine
request = Promise.promisifyAll require('request')
{log, warn, error} = require path.join(ROOT, 'lib/utils')
AkashicSenkaServerTable = require './akashic-senka-server-table'
AkashicSenkaServerSelect = require './akashic-senka-server-select'
dateToString = ->
  date = new Date()
  year = date.getFullYear()
  month = date.getMonth() + 1
  if month < 10
    month = "0#{month}"
  day = date.getDate()
  if day < 10
    day = "0#{day}"
  hour = date.getHours()
  if hour in [2..13]
    time = "02"
  else if hour in [14..23]
    time = "14"
  else
    day = day - 1
    time = "14"
  "#{year}#{month}#{day}#{time}"

dateStringFormat = (date)->
  time = date[11..15]
  if time == "15:00"
    time = "夜"
  else
    time = "昼"
  return date[0..3] + date[5..6] + date[8..9] + "　" + time

serverNames = ["空", "横须贺镇守府", "吴镇守府", "佐世保镇守府", "舞鹤镇守府", "大凑警备府",
               "トラック泊地", "リンガ泊地", "ラバウル基地", "ショートランド泊地", "ブイン基地",
               "タウイタウイ泊地", "パラオ泊地", "ブルネイ泊地", "単冠湾泊地", "幌筵泊地",
               "宿毛湾泊地", "鹿屋基地", "岩川基地", "佐伯湾泊地", "柱岛泊地"]

sync = async (memberId, serverId, serverSelectedVersion, isDownloading) ->
  time = dateToString()
  senkaList = {}
  #serverList 1-100/500/990
  [response, body] = yield request.getAsync "https://www.senka.me/server/#{serverId}/ranking?f=json",
    json: true
  if response.statusCode == 200
    senkaList = JSON.stringify(body)
    try
      fs.ensureDirSync path.join(APPDATA_PATH, 'akashic-records', "#{memberId}", 'senkaList', "#{serverId}", '500')
      fs.writeFileSync path.join(APPDATA_PATH, 'akashic-records', "#{memberId}", 'senkaList', "#{serverId}", '500', time), "#{senkaList}", 'utf8'
    catch e
      error "Write senkaList file error!#{e}"
    log "save server:#{serverId} senkaList(500) from senkame[#{time}]"
  else
    log response.statusCode
  #serverList 1-990
  [response, body] = yield request.getAsync "https://www.senka.me/server/#{serverId}/ranking?f=json&lm=990",
    json: true
  if response.statusCode == 200
    senkaList = JSON.stringify(body)
    try
      fs.ensureDirSync path.join(APPDATA_PATH, 'akashic-records', "#{memberId}", 'senkaList', "#{serverId}", '990')
      fs.writeFileSync path.join(APPDATA_PATH, 'akashic-records', "#{memberId}", 'senkaList', "#{serverId}", '990', time), "#{senkaList}", 'utf8'
    catch e
      error "Write senkaList file error!#{e}"
    log "save server:#{serverId} senkaList(990) from senkame[#{time}]"
  else
    log response.statusCode
  isDownloading(serverSelectedVersion)
  return

AkashicSenkaServer = React.createClass
  getInitialState: ->
    showAmount: config.get "plugin.Akashic.senka.table.showAmount", 500
    tableData: []
    server: "镇守府"
    date: "日期"
    serverId: config.get "plugin.Akashic.senka.serverId", 0
    serverSelectedVersion: 0
    downloadingFlag: true

  updateSenkaList: (showAmount, serverId, serverSelectedVersion) ->
    time = dateToString()
    senkalist = {}
    senkaList = glob.sync(path.join(APPDATA_PATH, 'akashic-records', "#{@props.memberId}", 'senkaList', "#{serverId}", "#{showAmount}", "#{time}"))
    if senkaList.length == 0
      sync @props.memberId, serverId, serverSelectedVersion, isDownloading=(serverSelectedVersion) =>
        if serverSelectedVersion is @state.serverSelectedVersion
          @updateSenkaList @state.showAmount, @state.serverId, @state.serverSelectedVersion
      @setState
        downloadingFlag: true
    else
      senkaList = senkaList.map (filePath) ->
        try
          fileContent = fs.readFileSync filePath, 'utf8'
          data = JSON.parse(fileContent)
          data
        catch e
          warn "Read and decode file:#{senkaList} error!#{e}"
          return {}
      log "read senkaList[#{serverId}]-[#{showAmount}]-[#{time}]"
      list = senkaList[0]
      @setState
        tableData: list["list"]
        server: list["name"]
        date: dateStringFormat(list["date"])
        downloadingFlag: false

  shouldComponentUpdate: (nextProps, nextState) ->
    refreshFlag = false
    if @state.downloadingFlag isnt nextProps.downloadingFlag
      refreshFlag = true
    else if @state.tableData isnt nextProps.tableData or @state.tableData.length < 10
      refreshFlag = true
    refreshFlag

#  componentDidUpdate: (prevProps, prevState) ->
#    if @state.tableData.length < 10 and @props.memberId > 0
#      @updateSenkaList @state.showAmount, @state.serverId

  componentWillMount: () ->
    @updateSenkaList @state.showAmount, @state.serverId, @state.serverSelectedVersion

  componentWillReceiveProps: (nextProps) ->
    time = dateToString()
    if @props.memberId > 0 and @state.tableData.length < 10
      @updateSenkaList @state.showAmount, @state.serverId, @state.serverSelectedVersion

  handleCustomClick: ->
    showAmount = 500
    if not @state.downloadingFlag
      @updateSenkaList showAmount, @state.serverId, @state.serverSelectedVersion
      @setState
        showAmount: showAmount
      config.set "plugin.Akashic.senka.table.showAmount", showAmount
  handleMoreClick: ->
    showAmount = 990
    if not @state.downloadingFlag
      @updateSenkaList showAmount, @state.serverId, @state.serverSelectedVersion
      @setState
        showAmount: showAmount
      config.set "plugin.Akashic.senka.table.showAmount", showAmount

  handleFilterSelect: (e) ->
    serverId = parseInt e.target.value
    {serverSelectedVersion} = @state
    serverSelectedVersion += 1
    @updateSenkaList @state.showAmount, serverId, serverSelectedVersion
    @setState
      serverId: serverId
      serverSelectedVersion: serverSelectedVersion
    config.set "plugin.Akashic.senka.serverId", serverId

  render: ->
    <Grid>
      <Row>
        <Col xs={1} md={1}>
          <h4 className="akashic-senka-title">{"#{@state.server}"}</h4>
        </Col>
        <Col xs={1} md={1}>
          <h6 className="akashic-senka-time">{"　　　#{@state.date}"}</h6>
        </Col>
        <Col xs={10} md={10}>
          <AkashicSenkaServerSelect handleFilterSelect={@handleFilterSelect}
                                    handleCustomClick={@handleCustomClick}
                                    handleMoreClick={@handleMoreClick}
                                    filterPaneShow={@state.filterPaneShow}
                                    statisticsPaneShow={@state.statisticsPaneShow}
                                    serverId={@state.serverId}
                                    serverNames={serverNames}/>
          {
            if @state.downloadingFlag
              <Alert className="akashic-senka-alert">
                <h4>downloading...</h4>
              </Alert>
            else
              <AkashicSenkaServerTable tableTab={@props.tableTab} data={@state.tableData}/>
          }
        </Col>
      </Row>
    </Grid>

module.exports = AkashicSenkaServer