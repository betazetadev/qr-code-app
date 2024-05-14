import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';

class QRViewPage extends StatefulWidget {
  @override
  _QRViewPageState createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      final employeeData = json.decode(scanData.code ?? "{}");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Icon(Icons.account_circle, size: 64.0),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("ID: ${employeeData['id']}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "Name: ${employeeData['name']} ${employeeData['last_name']}"),
                SizedBox(height: 8),
                Text("Position: ${employeeData['position']}"),
                SizedBox(height: 8),
                Text("Work Center: ${employeeData['work_center']}"),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.resumeCamera();
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
