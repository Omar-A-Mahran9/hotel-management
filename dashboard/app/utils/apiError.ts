import type { ValidationErrors } from '~/types/api'

export type ApiErrorKind =
  | 'validation' // 422
  | 'unauthenticated' // 401
  | 'forbidden' // 403
  | 'not_found' // 404
  | 'conflict' // 409 (backend has no 409 convention, kept for completeness)
  | 'rate_limited' // 429
  | 'server' // 5xx
  | 'network' // no response
  | 'unknown'

// Normalised error every dashboard screen can rely on, mapped from the
// Laravel error envelope { success:false, message, errors? }.
export class ApiError extends Error {
  readonly kind: ApiErrorKind
  readonly status: number
  readonly errors: ValidationErrors | null
  readonly retryAfter: number | null

  constructor(params: {
    kind: ApiErrorKind
    status: number
    message: string
    errors?: ValidationErrors | null
    retryAfter?: number | null
  }) {
    super(params.message)
    this.name = 'ApiError'
    this.kind = params.kind
    this.status = params.status
    this.errors = params.errors ?? null
    this.retryAfter = params.retryAfter ?? null
  }

  get isRetryable(): boolean {
    return this.kind === 'network' || this.kind === 'server' || this.kind === 'rate_limited'
  }
}

export function kindForStatus(status: number): ApiErrorKind {
  switch (status) {
    case 401:
      return 'unauthenticated'
    case 403:
      return 'forbidden'
    case 404:
      return 'not_found'
    case 409:
      return 'conflict'
    case 422:
      return 'validation'
    case 429:
      return 'rate_limited'
    default:
      if (status >= 500) return 'server'
      if (status <= 0) return 'network'
      return 'unknown'
  }
}
