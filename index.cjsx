remote = require 'remote'
windowManager = remote.require './lib/window'

window.akashicRecordsWindow = null
initialAkashicRecordsWindow = ->
  window.akashicRecordsWindow = windowManager.createWindow
    x: config.get 'poi.window.x', 0
    y: config.get 'poi.window.y', 0
    width: 820
    height: 650
  window.akashicRecordsWindow.loadUrl "file://#{__dirname}/index.html"
  if process.env.DEBUG?
    window.akashicRecordsWindow.openDevTools
      detach: true
if config.get('plugin.Akashic.enable', true)
  initialAkashicRecordsWindow()

module.exports =
  name: 'Akashic'
  priority: 10
  displayName: [<FontAwesome key={0} name='book' />, ' 航海日志']
  description: '日志'
  author: 'W.G.'
  link: 'https://github.com/JenningsWu'
  version: '1.0.0'
  handleClick: ->
    window.akashicRecordsWindow.show()
