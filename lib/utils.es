function pad(str, max = 2) {
  let ret = `${str}`
  while (ret.length < max) {
    ret = `0${ret}`
  }
  return ret
}

export function dateToString(date) {
  const month = pad(date.getMonth() + 1)
  const day = pad(date.getDate())
  const hour = pad(date.getHours())
  const minute = pad(date.getMinutes())
  const second = pad(date.getSeconds())
  return `${date.getFullYear()}/${month}/${day} ${hour}:${minute}:${second}`
}
