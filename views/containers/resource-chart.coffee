{__} = window
{connect} = require 'react-redux'
ChartArea = require '../components/akashic-resource-chart'

mapStateToProps = (state, ownProps) =>
  data: state.resource.data

mapDispatchToProps = (dispatch, ownProps) =>
  {}

module.exports = connect(
  mapStateToProps,
  mapDispatchToProps)(ChartArea)
