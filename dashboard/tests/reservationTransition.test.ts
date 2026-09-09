import { describe, expect, it, vi } from 'vitest'

// The reservation transition endpoint expects { target_status } — NOT
// { status }. This test pins that contract.
describe('reservationsService.transition — request shape', () => {
  it('POSTs { target_status } to /reservations/{id}/transition', async () => {
    const api = vi.fn().mockResolvedValue({ id: 7, status: 'deposit_held' })
    // services/index.ts calls the auto-imported useApi() at call time.
    vi.stubGlobal('useApi', () => api)

    const { reservationsService } = await import('~/services')
    await reservationsService.transition(7, 'deposit_held')

    expect(api).toHaveBeenCalledWith('/reservations/7/transition', {
      method: 'POST',
      body: { target_status: 'deposit_held' },
    })
    expect(api.mock.calls[0]?.[1]?.body).not.toHaveProperty('status')

    vi.unstubAllGlobals()
  })
})
