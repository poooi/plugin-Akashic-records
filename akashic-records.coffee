require 'coffee-react/register'
require "#{ROOT}/views/env"
require "#{ROOT}/views/battle-env"

path = require 'path-extra'

# i18n configure
i18n = new (require 'i18n-2')
  locales: ['en-US', 'ja-JP', 'zh-CN', 'zh-TW'],
  defaultLocale: 'zh-CN',
  directory: path.join(__dirname, 'i18n'),
  extension: '.json',
  devMode: false

i18n.setLocale(window.language)
window.__ = __ = i18n.__.bind(i18n)
window.translate = i18n.translate.bind(i18n)

window.theme = config.get 'poi.theme', '__default__'
if theme == '__default__'
  $('#bootstrap-css')?.setAttribute 'href', "file://" + require.resolve('bootstrap/dist/css/bootstrap.css')
else
  $('#bootstrap-css')?.setAttribute 'href', "file://#{ROOT}/assets/themes/#{theme}/css/#{theme}.css"
window.addEventListener 'theme.change', (e) ->
  window.theme = e.detail.theme
  if theme == '__default__'
    $('#bootstrap-css')?.setAttribute 'href', "file://" + require.resolve('bootstrap/dist/css/bootstrap.css')
  else
    $('#bootstrap-css')?.setAttribute 'href', "file://#{ROOT}/assets/themes/#{theme}/css/#{theme}.css"

if not window.ipc?
  try
    {remote} = window
    window.ipc = ipc = remote.require './lib/ipc'
  catch e
    console.log e if process.env.DEBUG is 1

window.CONST = require path.join(__dirname, 'lib', 'constant')

try
  window.Immutable = Immutable = require('immutable');
  require 'iconv-lite'
  require 'jschardet'
  require 'react-redux'
  require 'redux'
  require 'reselect'
  requirePass = true
catch e
  requirePass = false

switch window.language
  when 'ja-JP'
    windowTitle = 'アカシックレコード'
  when 'zh-CN'
    windowTitle = '阿克夏记录'
  when 'zh-TW'
    windowTitle = '阿克夏紀錄'
  else
    windowTitle = 'Akashic Records'

document.title = windowTitle

FontAwesome = if require('react-fontawesome')?.default? then require('react-fontawesome').default else require('react-fontawesome')

window.FontAwesome = FontAwesome

if requirePass
  require './views'
else
  require './views/error'
require './views/modal'
