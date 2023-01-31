enum QRCodeResultState {
  success,
  failure,
  cancel,
}

class QRCodeResult {
  final QRCodeResultState state;
  final String? data;

  QRCodeResult.success(this.data) : state = QRCodeResultState.success;
  QRCodeResult.cancel()
      : state = QRCodeResultState.cancel,
        data = null;
  QRCodeResult.failure()
      : state = QRCodeResultState.failure,
        data = null;
}
