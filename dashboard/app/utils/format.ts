// Pure display formatters. The backend is authoritative for every monetary
// value — these only render an already-computed decimal string; they never
// do arithmetic on financial data.

/**
 * Render a backend money string ("120.00") with its currency code. Falls
 * back to the raw value if it is not parseable, so a surprising backend
 * value is shown, never hidden.
 */
export function money(amount: string | number | null | undefined, currency?: string | null): string {
  if (amount == null || amount === '') return '—'
  const n = typeof amount === 'number' ? amount : Number(amount)
  if (!Number.isFinite(n)) return String(amount)
  const body = n.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  return currency ? `${body} ${currency}` : body
}

/** Date only (YYYY-MM-DD kept stable — no timezone shift on a plain date). */
export function date(value: string | null | undefined): string {
  if (!value) return '—'
  return value.length >= 10 ? value.slice(0, 10) : value
}

/** Date + time, localised. */
export function dateTime(value: string | null | undefined): string {
  if (!value) return '—'
  const d = new Date(value)
  return Number.isNaN(d.getTime()) ? value : d.toLocaleString()
}
