module.exports =
  addData: (data, type) ->
    type: 'ADD_DATA'
    dataType: type
    data: data
  