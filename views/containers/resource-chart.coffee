{__} = window
import { connect } from 'react-redux'
import ChartArea from '../components/akashic-resource-chart'

mapStateToProps = (state, ownProps) =>
  data: state.resource.data

mapDispatchToProps = (dispatch, ownProps) =>
  {}

module.exports = connect(
  mapStateToProps,
  mapDispatchToProps)(ChartArea)
