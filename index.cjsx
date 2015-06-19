remote = require 'remote'
windowManager = remote.require './lib/window'

akashicRecordsWindow = null
initialAkashicRecordsWindow = ->
  akashicRecordsWindow = windowManager.createWindow
    x: config.get 'poi.window.x', 0
    y: config.get 'poi.window.y', 0
    width: 820
    height: 650
  akashicRecordsWindow.loadUrl "file://#{__dirname}/index.html"
  if process.env.DEBUG?
    akashicRecordsWindow.openDevTools
      detach: true
initialAkashicRecordsWindow()


module.exports =
  name: 'Akashic'
  priority: 10
  displayName: [<FontAwesome key={0} name='book' />, ' 航海日志']
  description: '日志'
  author: 'W.G.'
  link: 'http://weibo.com/jenningswu'
  version: '0.0.1'
  reactClass: React.createClass
    getInitialState: ->
      content: 'Hello, world!'
    handleClick: ->
      akashicRecordsWindow.show()
    render: ->
      <div>
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'main.css')} />
        <Grid>
          <Row className='show-grid'>
            <Col xs={6}>
              <Button bsStyle='danger' onClick={@handleClick} style={width: '100%'}>
                出击记录
              </Button>
            </Col>
            <Col xs={6}>
              <Button bsStyle='danger' onClick={@handleClick} style={width: '100%'}>
                远征统计
              </Button>
            </Col>
          </Row>

          <Row className='show-grid'>
            <Col xs={6}>
              <Button bsStyle='info' onClick={@handleClick} style={width: '100%'}>
                开发记录
              </Button>
            </Col>
            <Col xs={6}>
              <Button bsStyle='info' onClick={@handleClick} style={width: '100%'}>
                建造记录
              </Button>
            </Col>
          </Row>

          <Row className='show-grid'>
            <Col xs={12}>
              <Button bsStyle='success' onClick={@handleClick} style={width: '100%'}>
                资源走势
              </Button>
            </Col>
          </Row>
        </Grid>
      </div> 
  handleClick: ->
    akashicRecordsWindow.show()

