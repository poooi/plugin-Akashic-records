module.exports = (state = [], action) =>
  switch action.type
    when 'ADD_LOG'
      [state..., action.log]
    when 'INITIALIZE_LOG'
      action.logs
    else
      state
