import { connect } from 'react-redux'
import ChartArea from '../components/akashic-resource-chart'

import { pluginDataSelector } from '../selectors'

function mapStateToProps(poi_state, ownProps) {
  const state = pluginDataSelector(poi_state)
  return { data: state.resource.data }
}

export default connect(
  mapStateToProps,
  () => ({})
)(ChartArea)
