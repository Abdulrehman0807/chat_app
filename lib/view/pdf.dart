import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class MyPdfViewer extends StatefulWidget {
  final String url;
  MyPdfViewer({required this.url});

  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  PdfControllerPinch? _pdfControllerPinch;

  @override
  void initState() {
    super.initState();
    _downloadFileAndLoadPdf(widget.url);
  }

  Future<void> _downloadFileAndLoadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp.pdf');
    await file.writeAsBytes(response.bodyBytes);
    if (mounted) {
      setState(() {
        _pdfControllerPinch = PdfControllerPinch(
          document: PdfDocument.openFile(file.path),
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My PDF Document"),
        backgroundColor: Colors.black,
      ),
      body: _pdfControllerPinch != null
          ? PdfViewPinch(controller: _pdfControllerPinch!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
