import { DataRow, DataTable } from '../../lib/data-co-manager'

/** The part of poi's `fcd.map` this module needs, see views/redux/fcd.ts of poi. */
export type FcdMapState = Record<string, {
  /** edge id (api_no) -> [from spot, or null when starting, to spot] */
  route: Record<string, [string | null, string]>
}>

// `鎮守府正面海域(1-1)` or `連合艦隊、西へ(42-1 甲) | 3`
const MAP_ID_PATTERN = /\((\d+)-(\d+)[^)]*\)/
// `59(道中)`, where 59 is the api_no of the edge the fleet took to the cell
const MAP_CELL_PATTERN = /^(\d+)\((.*)\)$/

const MAP_INDEX = 1
const MAP_CELL_INDEX = 2

/**
 * Prepend the name of the cell a battle took place in to the recorded edge id,
 * e.g. `59(道中)` becomes `H (59, 道中)`. Falls back to the original text when
 * the map is unknown to fcd.
 */
function resolveMapCell(
  mapText: string,
  cellText: string,
  fcdMap: FcdMapState | undefined
): string {
  const cellMatch = MAP_CELL_PATTERN.exec(cellText)
  if (cellMatch == null) {
    return cellText
  }
  const mapMatch = MAP_ID_PATTERN.exec(mapText)
  if (mapMatch == null) {
    return cellText
  }
  const spot = fcdMap?.[`${mapMatch[1]}-${mapMatch[2]}`]?.route?.[cellMatch[1]]?.[1]
  return spot ? `${spot} (${cellMatch[1]}, ${cellMatch[2]})` : cellText
}

let cachedFcdMap: FcdMapState | undefined
let rowCache = new WeakMap<DataRow, DataRow>()
let lastData: DataTable | undefined
let lastResult: DataTable | undefined

/**
 * Resolve the cell column of every sortie record. Rows are cached by identity
 * so that appending a single battle does not re-resolve the whole log, and the
 * last result is kept so that every caller sees the same table identity.
 */
export function resolveMapCells(data: DataTable, fcdMap: FcdMapState | undefined): DataTable {
  if (fcdMap !== cachedFcdMap) {
    cachedFcdMap = fcdMap
    rowCache = new WeakMap()
    lastData = undefined
  }
  if (data === lastData && lastResult != null) {
    return lastResult
  }
  let resolvedAny = false
  const resolved = data.map((row) => {
    const cached = rowCache.get(row)
    if (cached != null) {
      resolvedAny = resolvedAny || cached !== row
      return cached
    }
    const cellText = `${row[MAP_CELL_INDEX]}`
    const label = resolveMapCell(`${row[MAP_INDEX]}`, cellText, fcdMap)
    const next: DataRow = label === cellText
      ? row
      : [row[0], row[MAP_INDEX], label, ...row.slice(3)]
    rowCache.set(row, next)
    resolvedAny = resolvedAny || next !== row
    return next
  })
  lastData = data
  lastResult = resolvedAny ? resolved : data
  return lastResult
}
