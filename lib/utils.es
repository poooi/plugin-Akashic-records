export function dateToString(date) {
  const month = date.getMonth() < 9 ?
    `0${date.getMonth() + 1}` : `${date.getMonth() + 1}`
  const day = date.getDate() < 9 ?
    `0${date.getDate() + 1}` : `${date.getDate() + 1}`
  const hour = date.getHours() < 9 ?
    `0${date.getHours() + 1}` : `${date.getHours() + 1}`
  const minute = date.getMinutes() < 9 ?
    `0${date.getMinutes() + 1}` : `${date.getMinutes() + 1}`
  const second = date.getSeconds() < 9 ?
    `0${date.getSeconds() + 1}` : `${date.getSeconds() + 1}`
  return `${date.getFullYear()}/${month}/${day} ${hour}:${minute}:${second}`
}
