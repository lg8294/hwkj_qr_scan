library hwkj_qr_scan;

import 'package:flutter/material.dart';
import 'package:hwkj_qr_scan/src/qr_code_scan.dart';

/// 返回null代表取消
Future<String?> openQRScan(BuildContext context, {String? tip}) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => QRCodeScan(tip: tip)),
  );
}
