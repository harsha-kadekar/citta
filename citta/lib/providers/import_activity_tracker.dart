/// Counts, not just flags, active imports: `StorageService`'s shared lock
/// queues rather than rejects concurrent imports, so a single boolean
/// cleared by whichever import finishes first would wrongly report "no
/// import in flight" while another is still queued or running.
class ImportActivityTracker {
  int _activeCount = 0;

  bool get isActive => _activeCount > 0;

  void begin() => _activeCount++;

  void end() => _activeCount--;
}
