/// The service-order lifecycle, mirroring the Laravel `ServiceOrder` status
/// vocabulary **exactly** (backend `App\Domain\StayServices\Models\ServiceOrder`
/// constants and `ServiceOrderStateMachine`; Phase 8). No new statuses are
/// invented (mobile/docs/architecture.md §6).
///
/// ```
/// requested → confirmed, cancelled
/// confirmed → fulfilled, cancelled
/// fulfilled / cancelled → (terminal)
/// ```
enum ServiceOrderStatus {
  requested('requested'),
  confirmed('confirmed'),
  fulfilled('fulfilled'),
  cancelled('cancelled');

  const ServiceOrderStatus(this.wireValue);

  final String wireValue;

  static ServiceOrderStatus fromWire(String value) {
    for (final ServiceOrderStatus s in ServiceOrderStatus.values) {
      if (s.wireValue == value) return s;
    }
    return ServiceOrderStatus.requested;
  }

  bool get isTerminal =>
      this == ServiceOrderStatus.fulfilled ||
      this == ServiceOrderStatus.cancelled;

  bool get isCancelled => this == ServiceOrderStatus.cancelled;

  /// The guest may cancel a request only before the hotel has confirmed it
  /// (`requested → cancelled` is an approved edge; a `confirmed` order is
  /// already being actioned). The backend remains the final authority.
  bool get isGuestCancellable => this == ServiceOrderStatus.requested;

  /// Whether this order still counts as "open" for the guest's active list.
  bool get isOpen => !isTerminal;
}
