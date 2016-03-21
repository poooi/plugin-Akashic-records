{React, ReactDOM, ReactBootstrap, $, ROOT, __, translate, CONST} = window
{Label} = ReactBootstrap

# getUseItem: (id)->
#   switch id
#     when 10
#       "家具箱（小）"
#     when 11
#       "家具箱（中）"
#     when 12
#       "家具箱（大）"
#     when 50
#       "応急修理要員"
#     when 51
#       "応急修理女神"
#     when 54
#       "給糧艦「間宮」"
#     when 56
#       "艦娘からのチョコ"
#     when 57
#       "勲章"
#     when 59
#       "給糧艦「伊良湖」"
#     when 62
#       "菱餅"
#     else
#       "特殊的东西"

errorMessage = __('''
Please make sure you are using the lastest version of poi, and you did not interrupt the installation process of the plugin, so that it is correctly installed.
''') + ' ' + __ '''
If errors still happen, please uninstall the plugin and try to install again.
'''
AkashicRecordsArea = React.createClass
  getInitialState: ->
    warning: errorMessage

  render: ->
    <div>
      <div  style={'fontSize': 18}>
        <Label bsStyle="danger" style={'whiteSpace': 'normal'}>{@state.warning}</Label>
      </div>
    </div>

ReactDOM.render(
  <AkashicRecordsArea />,
  $('akashic-records')
)
