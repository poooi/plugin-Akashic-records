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

AkashicRecordsArea = React.createClass
  getInitialState: ->
    warning: '请确保使用的 POI 是最新版本，以及安装插件时未中断，插件已完整安装！若仍然黑屏，请尝试卸载插件，重新安装。'

  render: ->
    <div>
      <div  style={'fontSize': 18}>
        <Label bsStyle="danger">{@state.warning}</Label>
      </div>
    </div>

ReactDOM.render(
  <AkashicRecordsArea />,
  $('akashic-records')
)
