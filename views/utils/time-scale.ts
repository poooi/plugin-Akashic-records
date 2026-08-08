import { DataTable } from '../../lib/data-co-manager'

export enum TimeScale {
  Hour = 'hour',
  Day = 'day',
  Week = 'week',
  Month = 'month',
}

export const defaultTimeScale = TimeScale.Day

// the order the chart toolbox cycles through
export const timeScales = [TimeScale.Hour, TimeScale.Day, TimeScale.Week, TimeScale.Month]

export const timeScaleLabels: Record<TimeScale, string> = {
  [TimeScale.Hour]: 'Hour',
  [TimeScale.Day]: 'Day',
  [TimeScale.Week]: 'Week',
  [TimeScale.Month]: 'Month',
}

export const nextTimeScale = (scale: TimeScale): TimeScale =>
  timeScales[(timeScales.indexOf(scale) + 1) % timeScales.length]

// the table scale used to be persisted as an index: 0 for hour, 1 for day
const legacyTimeScales = [TimeScale.Hour, TimeScale.Day]

export const toTimeScale = (val: unknown): TimeScale => {
  if (typeof val === 'number') {
    return legacyTimeScales[val] || defaultTimeScale
  }
  return Object.values(TimeScale).includes(val as TimeScale)
    ? val as TimeScale
    : defaultTimeScale
}

// the bucket a record falls in, records sharing one are collapsed into the first
const dateToScaleString = (datetime: number | string, scale: TimeScale): string => {
  const date = new Date(datetime)
  switch (scale) {
  case TimeScale.Month:
    return `${date.getFullYear()}/${date.getMonth()}`
  case TimeScale.Week: {
    // keyed by the sunday the week starts on
    const first = new Date(date.getFullYear(), date.getMonth(), date.getDate() - date.getDay())
    return `${first.getFullYear()}/${first.getMonth()}/${first.getDate()}`
  }
  default:
    return `${date.getFullYear()}/${date.getMonth()}/${date.getDate()}`
  }
}

// keeps the first record of every bucket, so the caller's ordering decides
// whether that is the earliest or the latest one
export const filterByTimeScale = (data: DataTable, scale: TimeScale): DataTable => {
  if (scale === TimeScale.Hour) {
    return data
  }
  let dateString = ""
  return data.filter((item) => {
    const tmp = dateToScaleString(item[0], scale)
    if (tmp !== dateString) {
      dateString = tmp
      return true
    }
    return false
  })
}
