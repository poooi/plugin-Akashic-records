{Immutable} = window

module.exports = (state = Immutable.List(), action) =>
  switch action.type
    when 'ADD_LOG'
      state.push Immutable.fromJS action.log
    when 'INITIALIZE_LOG'
      Immutable.fromJS action.logs
    else
      state
