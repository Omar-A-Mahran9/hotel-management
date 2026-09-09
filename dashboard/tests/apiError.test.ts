import { describe, expect, it } from 'vitest'
import { ApiError, kindForStatus } from '~/utils/apiError'

describe('kindForStatus — maps the Laravel envelope status codes', () => {
  it.each([
    [401, 'unauthenticated'],
    [403, 'forbidden'],
    [404, 'not_found'],
    [422, 'validation'],
    [429, 'rate_limited'],
    [500, 'server'],
    [503, 'server'],
    [0, 'network'],
    [418, 'unknown'],
  ])('status %i -> %s', (status, expected) => {
    expect(kindForStatus(status as number)).toBe(expected)
  })
})

describe('ApiError', () => {
  it('carries validation errors from a 422', () => {
    const err = new ApiError({
      kind: 'validation',
      status: 422,
      message: 'The given data was invalid.',
      errors: { email: ['The email field is required.'] },
    })
    expect(err.errors?.email?.[0]).toContain('required')
    expect(err.isRetryable).toBe(false)
  })

  it('marks network / server / rate-limited as retryable', () => {
    expect(new ApiError({ kind: 'network', status: 0, message: '' }).isRetryable).toBe(true)
    expect(new ApiError({ kind: 'server', status: 500, message: '' }).isRetryable).toBe(true)
    expect(new ApiError({ kind: 'rate_limited', status: 429, message: '' }).isRetryable).toBe(true)
    expect(new ApiError({ kind: 'forbidden', status: 403, message: '' }).isRetryable).toBe(false)
  })
})
