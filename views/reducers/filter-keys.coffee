defaultFilterKeys = ['', '', '', '', '', '',
                    '', '', '', '', '', '']

module.exports = (state = defaultFilterKeys, action) =>
  switch action.type
    when 'SET_FILTER_KEY'
      tmp = [state...]
      tmp[action.index] = action.val
    else
      state
