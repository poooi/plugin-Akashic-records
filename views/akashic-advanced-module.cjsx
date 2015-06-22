{React, ReactBootstrap} = window
{Grid, Col, Table} = ReactBootstrap

AttackLog = React.createClass
  render: ->
    <div>
      <h2>TODO list</h2>
      <h3>统计页面部分</h3>
      <ul>
        <li>排序</li>
        <li>指定列的搜索</li>
        <li>高级搜索</li>
      </ul>
      <h3>资源走势图</h3>
      <ul>
        <li>优化颜色</li>
        <li>时间粒度与范围选择</li>
        <li>走势内容选择</li>
      </ul>
      <h3>资源表格</h3>
      <h3>高级功能</h3>
      <ul>
        <li>数据导入导出</li>
        <li>航海日志数据导入</li>
        <li>允许离线查看</li>
      </ul>
      <h4>Bug汇报：https://github.com/yudachi/plugin-Akashic-records</h4>
    </div>

module.exports = AttackLog
