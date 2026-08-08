// search rules and statistics rules refer to a data set by its index in the
// length list: the two fixed entries below, then one entry per search rule.
// Custom is statistics-only and means the number is typed in by hand instead.
export enum DataSource {
  Custom = -1,
  AllData = 0,
  Filtered = 1,
}

export default {
  typeList: {
    attack: 'attack',
    mission: 'mission',
    createShip: 'createship',
    createItem: 'createitem',
    resource: 'resource',
    retirement: 'retirement',
  },
  eventList: {
    dataChange: 'datachange',
    filteredDataChange: 'filtereddatachange',
  },
  search: {
    rawDataIndex: DataSource.AllData,
    filteredDataIndex: DataSource.Filtered,
    // search result i sits at indexBase + i + 1
    indexBase: 1,
  },
}
