library hwkj_qr_scan;

import 'package:flutter/material.dart';
import 'package:hwkj_qr_scan/src/qr_code_scan.dart';

Future<String> openQRScan(BuildContext context) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => QRCodeScan()),
  );
}
