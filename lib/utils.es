export function dateToString(date) {
  const month = date.getMonth() < 9 ?
    `0${date.getMonth() + 1}` : `${date.getMonth() + 1}`
  const day = date.getDate() < 9 ?
    `0${date.getDate()}` : `${date.getDate()}`
  const hour = date.getHours() < 9 ?
    `0${date.getHours()}` : `${date.getHours()}`
  const minute = date.getMinutes() < 9 ?
    `0${date.getMinutes()}` : `${date.getMinutes()}`
  const second = date.getSeconds() < 9 ?
    `0${date.getSeconds()}` : `${date.getSeconds()}`
  return `${date.getFullYear()}/${month}/${day} ${hour}:${minute}:${second}`
}
