remote = require 'remote'
windowManager = remote.require './lib/window'
path = require 'path-extra'

# i18n configure
i18n = new (require 'i18n-2')
  locales: ['en-US', 'ja-JP', 'zh-CN', 'zh-TW'],
  defaultLocale: 'zh-CN',
  directory: path.join(__dirname, 'i18n'),
  updateFiles: false,
  indent: '\t',
  extension: '.json',
  devMode: false
i18n.setLocale(window.language)
__ = i18n.__.bind(i18n)

devMode = true

window.akashicRecordsWindow = null
initialAkashicRecordsWindow = ->
  window.akashicRecordsWindow = windowManager.createWindow
    x: config.get 'poi.window.x', 0
    y: config.get 'poi.window.y', 0
    width: 820
    height: 650
    realClose: devMode
  window.akashicRecordsWindow.loadURL "file://#{__dirname}/index.html"
  if process.env.DEBUG? or devMode
    window.akashicRecordsWindow.openDevTools
      detach: true

if config.get('plugin.Akashic.enable', true) and not devMode
  initialAkashicRecordsWindow()

module.exports =
  name: 'Akashic'
  priority: 10
  displayName: <span><FontAwesome key={0} name='book' /> {__ "Logbook"}</span>
  #displayName: <span><FontAwesome key={0} name='book' /> 航海日志</span>
  description: "#{__ "Logs"}."
  author: 'Jennings Wu'
  link: 'https://github.com/JenningsWu'
  version: '2.3.2'
  handleClick: ->
    if devMode
      initialAkashicRecordsWindow()
    window.akashicRecordsWindow.show()
