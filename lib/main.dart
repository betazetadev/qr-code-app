import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_code_app/views/qr_view_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final idController = TextEditingController();
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final puestoController = TextEditingController();
  final centroTrabajoController = TextEditingController();
  String qrData = "Empty QR Code";
  final GlobalKey globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Access QR Reader & Generator'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => QRViewPage())),
        tooltip: 'Scan QR',
        child: Icon(Icons.qr_code),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
              key: globalKey,
              child: QrImageView(
                data: qrData,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: _captureAndSharePng,
              child: Text(
                "Share QR",
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: idController,
                decoration: InputDecoration(
                  hintText: "Employee ID",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  hintText: "First Name",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: apellidoController,
                decoration: InputDecoration(
                  hintText: "Last Name",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: puestoController,
                decoration: InputDecoration(
                  hintText: "Job Title",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: centroTrabajoController,
                decoration: InputDecoration(
                  hintText: "Work Center",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () async {
                  var employeeData = {
                    "id": idController.text,
                    "nombre": nombreController.text,
                    "apellidos": apellidoController.text,
                    "puesto": puestoController.text,
                    "centro_trabajo": centroTrabajoController.text
                  };
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('QR code generated successfully!'),
                    ),
                  );
                  setState(() {
                    qrData = json.encode(employeeData);
                  });
                },
                child: Text(
                  "Generate QR",
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr.png').create();
      await file.writeAsBytes(pngBytes);

      final result = await Share.shareXFiles([XFile(file.path)],
          text: 'Here is your QR code!');

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code shared successfully!'),
          ),
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code sharing dismissed!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing QR code: $e'),
        ),
      );
    }
  }
}
