path = require 'path-extra'
{relative, join} = require 'path-extra'
{$, _, $$, React, ReactBootstrap, FontAwesome, ROOT, layout} = window
{_ships, $ships, $shipTypes} = window
{Alert, Grid, Col, Input, DropdownButton, Table, MenuItem, Button} = ReactBootstrap

module.exports =
  name: 'Akashic records'
  priority: 10
  displayName: [<FontAwesome key={0} name='book' />, ' 航海日志']
  description: '日志'
  author: 'W.G.'
  link: 'http://weibo.com/jenningswu'
  version: '1.1.0'
  reactClass: React.createClass
    getInitialState: ->
      content: 'Hello, world!'
    handleResponse: (e) ->
      {method, path, body, postBody} = e.detail
      switch path
        when '/kcsapi/api_port/port'
          @setState
            content: 'Welcome back!'
          @handleShipChange()
    componentDidMount: ->
      window.addEventListener 'game.response', @handleResponse
    componentWillUnmount: ->
      window.removeEventListener 'game.response', @handleResponse
    render: ->
      <div>
        {@state.content}
      </div> 
