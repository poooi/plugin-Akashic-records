import { connect } from 'react-redux'
import ChartArea from '../components/akashic-resource-chart'

function mapStateToProps(state, ownProps) {
  return { data: state.resource.data }
}

export default connect(
  mapStateToProps,
  () => ({})
)(ChartArea)
