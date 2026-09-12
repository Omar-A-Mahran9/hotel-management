import { describe, expect, it, vi } from 'vitest'
import { PROBLEM_STATUS_TONE, PROBLEM_STATUS_TRANSITIONS, PROBLEM_URGENCY_TONE } from '~/utils/statusMeta'

describe('problem report status transitions (UI mirror)', () => {
  it('offers in_progress + resolved from open', () => {
    expect(PROBLEM_STATUS_TRANSITIONS.open).toEqual(['in_progress', 'resolved'])
  })
  it('offers only resolved from in_progress', () => {
    expect(PROBLEM_STATUS_TRANSITIONS.in_progress).toEqual(['resolved'])
  })
  it('has no transition out of the terminal resolved state', () => {
    expect(PROBLEM_STATUS_TRANSITIONS.resolved).toEqual([])
  })
  it('every problem-report status has a tone', () => {
    for (const s of Object.keys(PROBLEM_STATUS_TRANSITIONS)) {
      expect(PROBLEM_STATUS_TONE[s as keyof typeof PROBLEM_STATUS_TONE]).toBeDefined()
    }
  })
})

describe('problem report urgency tones', () => {
  it('maps urgent to destructive, important to warning, normal to neutral', () => {
    expect(PROBLEM_URGENCY_TONE.urgent).toBe('destructive')
    expect(PROBLEM_URGENCY_TONE.important).toBe('warning')
    expect(PROBLEM_URGENCY_TONE.normal).toBe('neutral')
  })
})

// The status-transition endpoint expects { status } — not { target_status }
// like reservations — this test pins that contract.
describe('problemReportsService.transitionStatus — request shape', () => {
  it('PATCHes { status } to /problems/{id}/status', async () => {
    const api = vi.fn().mockResolvedValue({ id: 5, status: 'in_progress' })
    // services/index.ts calls the auto-imported useApi() at call time.
    vi.stubGlobal('useApi', () => api)

    const { problemReportsService } = await import('~/services')
    await problemReportsService.transitionStatus(5, 'in_progress')

    expect(api).toHaveBeenCalledWith('/problems/5/status', {
      method: 'PATCH',
      body: { status: 'in_progress' },
    })

    vi.unstubAllGlobals()
  })
})

describe('problemReportsService.list — request shape', () => {
  it('GETs /hotels/{hotelId}/problems with a cleaned query', async () => {
    const withMeta = vi.fn().mockResolvedValue({ data: [], meta: {} })
    vi.stubGlobal('useApi', () => ({ withMeta }))

    const { problemReportsService } = await import('~/services')
    await problemReportsService.list(3, { status: 'open', page: 2 })

    expect(withMeta).toHaveBeenCalledWith('/hotels/3/problems', {
      query: { status: 'open', page: 2 },
    })

    vi.unstubAllGlobals()
  })

  it('drops an undefined status filter from the query', async () => {
    const withMeta = vi.fn().mockResolvedValue({ data: [], meta: {} })
    vi.stubGlobal('useApi', () => ({ withMeta }))

    const { problemReportsService } = await import('~/services')
    await problemReportsService.list(3, { status: undefined, page: 1 })

    expect(withMeta).toHaveBeenCalledWith('/hotels/3/problems', {
      query: { page: 1 },
    })

    vi.unstubAllGlobals()
  })
})
