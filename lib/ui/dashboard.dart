
Future<void> _connect() async {
  if (_isLoading) return;
  if (activeConfig == null) return;

  setState(() => _isLoading = true);

  try {
    final res = await CoreController.startCore(coreType, activeConfig!);

    if (!mounted) return;

    if (res == "Started") {
      setState(() => status = "CONNECTED");
    } else {
      setState(() => status = "ERROR");
    }
  } catch (e) {
    if (mounted) {
      setState(() => status = "ERROR");
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

