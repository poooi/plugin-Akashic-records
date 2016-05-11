{remote} = require 'electron'
windowManager = remote.require './lib/window'
path = require 'path-extra'
fs = require 'fs-extra'

{_, React, ReactBootstrap, APPDATA_PATH, remote} = window
{Grid, Row, Col, Button} = ReactBootstrap

{dialog} = remote.require 'electron'

__ = window.i18n['poi-plugin-akashic-records'].__.bind(window.i18n['poi-plugin-akashic-records'])

# Parameters:
#   label       String         The title to display
#   configName  String         Where you store in config
#   defaultVal  Bool           The default value for config
#   onNewVal    Function(val)  Called when a new value is set.
FolderPickerConfig = React.createClass
  getInitialState: ->
    myval: config.get @props.configName, @props.defaultVal
  onDrag: (e) ->
    e.preventDefault()
  synchronize: (callback) ->
    return if @lock
    @lock = true
    callback()
    @lock = false
  setPath: (val) ->
    @props.onNewVal(val) if @props.onNewVal
    config.set @props.configName, val
    @setState
      myval: val
  folderPickerOnDrop: (e) ->
    e.preventDefault()
    droppedFiles = e.dataTransfer.files
    isDirectory = fs.statSync(droppedFiles[0].path).isDirectory()
    @setPath droppedFiles[0].path if isDirectory
  folderPickerOnClick: ->
    @synchronize =>
      fs.ensureDirSync @state.myval
      filenames = dialog.showOpenDialog
        title: @props.label
        defaultPath: @state.myval
        properties: ['openDirectory', 'createDirectory']
      @setPath filenames[0] if filenames isnt undefined
  handleReset: ->
    config.set @props.configName, APPDATA_PATH
    @setState
      myval: APPDATA_PATH
  render: ->
    <Grid>
      <Row>
        <Col xs={12}>
          {__ "It will take effect after a restart"}
        </Col>
      </Row>
      <Row>
        <Col xs={9}>
          <div className="folder-picker"
               onClick={@folderPickerOnClick}
               onDrop={@folderPickerOnDrop}
               onDragEnter={@onDrag}
               onDragOver={@onDrag}
               onDragLeave={@onDrag}>
            {@state.myval}
          </div>
        </Col>
        <Col xs={3}>
          <Button bsStyle="warning" style={padding: 6} onClick={@handleReset} block>{__ "RESET"}</Button>
        </Col>
      </Row>
    </Grid>

module.exports =
  windowOptions:
    x: config.get 'poi.window.x', 0
    y: config.get 'poi.window.y', 0
    width: 820
    height: 650
  windowURL: "file://#{__dirname}/index.html"
  useEnv: true
  settingsClass: React.createClass
    getInitialState: ->
      defaultVal: config.get "plugin.Akashic.dataPath", APPDATA_PATH
    render: ->
      <FolderPickerConfig
          label={__ 'Data Folder'}
          configName="plugin.Akashic.dataPath"
          defaultVal={@state.defaultVal}/>
