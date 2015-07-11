{React, ReactBootstrap, ROOT} = window
{Grid, Row, Col, Input, Button, OverlayTrigger, Popover} = ReactBootstrap

fs = require 'fs-extra'
iconv = require 'iconv-lite'

remote = require 'remote'
dialog = remote.require 'dialog'
toDateLabel = (datetime) ->
  date = new Date(datetime)
  month = date.getMonth()+1
  if month < 10
    month = "0#{month}"
  day = date.getDate()
  if day < 10
    day = "0#{day}"
  hour = date.getHours()
  if hour < 10
    hour = "0#{hour}"
  minute = date.getMinutes()
  if minute < 10
    minute = "0#{minute}"
  second = date.getSeconds()
  if second < 10
    second = "0#{second}"

  "#{date.getFullYear()}/#{month}/#{day} #{hour}:#{minute}:#{second}"

AttackLog = React.createClass
  getInitialState: ->
    typeChoosed: '出击'
    codeType: '选择文件编码格式'
  # componentWillMount: ->
  #   console.log "test"
  handleSetType: ->
    @setState
      typeChoosed: @refs.type.getValue()
  handleSetCode: ->
    @setState
      codeType: @refs.codeType.getValue()
  showMessage: (message)->
    dialog.showMessageBox
      type: 'info'
      buttons: ['确定']
      title: '提醒'
      message: message
  saveLogHandle: ->
    nickNameId = window._nickNameId
    if nickNameId and nickNameId isnt 0
      switch @state.typeChoosed
        when '出击'
          logType = 'attack'
          data = @props.attackData
        when '远征'
          logType = 'mission'
          data = @props.missionData
        when '建造'
          logType = 'createitem'
          data = @props.createItemData
        when '开发'
          logType = 'createship'
          data = @props.createShipData
        when '资源'
          logType = 'resource'
          data = @props.resourceData
        else
          @showMessage '发生错误！请报告开发者'
          return
      if @state.codeType isnt 'utf8' and @state.codeType isnt 'GBK'
        @showMessage '请选择编码格式'
      else
        filename = dialog.showSaveDialog
          title: "保存#{@state.typeChoosed}记录"
          defaultPath: "#{nickNameId}-#{logType}.csv"
        if filename?
          saveData = ""
          for item in data
            saveData = "#{saveData}#{toDateLabel item[0]},#{item.slice(1).join(',')}\n"
          if @state.codeType is 'GBK'
            saveData = iconv.encode saveData, 'GBK'
          fs.writeFile filename, saveData, (err)->
            if err
              console.log "err! Save data error"
    else
      @showMessage '未找到相应的提督！是不是还没登录？'
  importLogHandle: ->
    # dialog.showOpenDialog 
    #   title: "导入#{@state.typeChoosed}记录"
    #   properties: ['openFile']
    # , (filename)->
    #   console.log "get file!#{filename}"
    # console.log "import log"
    @showMessage '未开放'
  render: ->
    <div className="advancedmodule">
      <Grid>
        <Row>
          <Col xs={12}>
            <h3>数据导入导出</h3>
          </Col>
        </Row>
        <Row>
          <Col xs={3}>
            <Input type="select" ref="type" value={@state.typeChoosed} onChange={@handleSetType}>
                <option key={0} value={'出击'}>出击</option>
                <option key={1} value={'远征'}>远征</option>
                <option key={2} value={'建造'}>建造</option>
                <option key={3} value={'开发'}>开发</option>
                <option key={4} value={'资源'}>出击</option>
            </Input>
          </Col>
          <Col xs={3}>
            <Input type="select" ref="codeType" value={@state.codeType} onChange={@handleSetCode}>
                <option key={0} value={'选择文件编码格式'}>文件编码格式</option>
                <option key={1} value={'utf8'}>utf8(mac等用户)</option>
                <option key={2} value={'GBK'}>GBK(windows用户)</option>
            </Input>
          </Col>
          <Col xs={3}>
             <Button bsStyle='primary' style={width: '100%'} onClick={@saveLogHandle}>导出</Button>
          </Col>
          <Col xs={3}>
             <Button bsStyle='primary' style={width: '100%'} onClick={@importLogHandle}>导入</Button>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <div>
              <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                <Popover title=''>
                  <h3>统计页面部分</h3>
                  <ul>
                    <li>排序</li>
                    <li>高级搜索</li>
                  </ul>
                  <h3>其他功能</h3>
                  <ul>
                    <li>航海日志数据导入</li>
                    <li>允许离线查看</li>
                  </ul>
                </Popover>
                }>
                <Button bsStyle='default'>TODO list</Button>
              </OverlayTrigger>
              <h4>Bug汇报：https://github.com/yudachi/plugin-Akashic-records</h4>
            </div>
          </Col>
        </Row>
      </Grid>
    </div>
    

module.exports = AttackLog
