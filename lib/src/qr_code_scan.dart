import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScan extends StatefulWidget {
  const QRCodeScan({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeScanState();
}

class _QRCodeScanState extends State<QRCodeScan> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              _buildQrView(context),
              _buildBackButton(context),
              // _buildToolOverlay(),
            ],
          ),
        ),
        onWillPop: () async {
          return true;
        });
  }

  Widget _buildToolOverlay() {
    return Positioned(
      bottom: 0,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (result != null)
              Text(
                  'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
            else
              Text('Scan a code'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
                  child: RaisedButton(
                      onPressed: () => setState(() {
                            controller?.toggleFlash();
                          }),
                      child: FutureBuilder(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return Text('Flash: ${snapshot.data}');
                        },
                      )),
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  child: RaisedButton(
                      onPressed: () => setState(() {
                            controller?.flipCamera();
                          }),
                      child: FutureBuilder(
                        future: controller?.getCameraInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Text(
                                'Camera facing ${describeEnum(snapshot.data)}');
                          } else {
                            return Text('loading');
                          }
                        },
                      )),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
                  child: RaisedButton(
                    onPressed: () {
                      controller?.pauseCamera();
                    },
                    child: Text('pause', style: TextStyle(fontSize: 20)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  child: RaisedButton(
                    onPressed: () {
                      controller?.resumeCamera();
                    },
                    child: Text('resume', style: TextStyle(fontSize: 20)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: SafeArea(
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: [BarcodeFormat.qrcode],
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).primaryColor,
        // borderRadius: 10,
        // borderLength: 300,
        borderWidth: 5,
        cutOutSize: scanArea,
      ),
    );
  }

  StreamSubscription _scannedDataSubscription;
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    _scannedDataSubscription?.cancel();
    bool flag = true;
    _scannedDataSubscription = controller.scannedDataStream.listen((scanData) {
      if (flag) {
        flag = false;
        print(scanData.code);
        this.result = scanData;
        this.controller.pauseCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }

  @override
  void dispose() {
    _scannedDataSubscription?.cancel();
    controller.dispose();
    super.dispose();
  }
}
