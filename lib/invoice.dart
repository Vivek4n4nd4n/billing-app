import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final pdfWidgets.Document pdf;

  InvoicePreviewScreen({required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Preview'),
      ),
      body: PdfPreview(
        build: (format) => pdf.save(),
      ),
    );
  }
}
