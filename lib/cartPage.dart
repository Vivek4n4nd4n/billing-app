import 'package:billing_app/homepage.dart';
import 'package:billing_app/main.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';

class CartInvoicePreviewScreen extends StatefulWidget {
  final pdfWidgets.Document pdf;

  const CartInvoicePreviewScreen({Key? key, required this.pdf})
      : super(key: key);

  @override
  State<CartInvoicePreviewScreen> createState() =>
      _CartInvoicePreviewScreenState();
}

class _CartInvoicePreviewScreenState extends State<CartInvoicePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
      ),
      body: PdfPreview(
        build: (format) => widget.pdf.save(),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  CartPage({required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _updateCartItem(int index, Map<String, dynamic> newItem) {
    setState(() {
      widget.cart[index] = newItem;
    });
  }

  Future<void> _showEditDialog(Map<String, dynamic> item, int index) async {
    final editedItem = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return EditItemDialog(initialItem: item);
      },
    );

    if (editedItem != null) {
      _updateCartItem(index, editedItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdf = generateCartInvoice(widget.cart);

    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartInvoicePreviewScreen(pdf: pdf),
                ),
              );
            },
            child: const Text("Preview Invoice"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          final item = widget.cart[index];
          return ListTile(
            title: Text("${item['metal']} - ${item['item']}"),
            subtitle:
                Text("Total Cost: ${item['totalCost'].toStringAsFixed(2)}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      _showEditDialog(item, index);
                    },
                    icon: Icon(Icons.edit)),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Item'),
                          content: const Text(
                              'Are you sure you want to delete this item?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                setState(() {
                                  widget.cart.removeAt(index);
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final Map<String, dynamic> initialItem;

  EditItemDialog({required this.initialItem});

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late Map<String, dynamic> _editedItem;

  @override
  void initState() {
    super.initState();
    _editedItem = Map.from(widget.initialItem);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: _editedItem['metal'] ?? '',
              onChanged: (value) {
                _editedItem['metal'] = value;
              },
              decoration: InputDecoration(labelText: 'Metal'),
            ),
            TextFormField(
              initialValue: _editedItem['item'] ?? '',
              onChanged: (value) {
                _editedItem['item'] = value;
              },
              decoration: InputDecoration(labelText: 'Item'),
            ),
            TextFormField(
              initialValue: _editedItem['gram'] != null
                  ? _editedItem['gram'].toString()
                  : '',
              onChanged: (value) {
                _editedItem['gram'] = double.tryParse(value) ?? 0.0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Gram'),
            ),
            TextFormField(
              initialValue: _editedItem['costPerGram'] != null
                  ? _editedItem['costPerGram'].toString()
                  : '',
              onChanged: (value) {
                _editedItem['costPerGram'] = double.tryParse(value) ?? 0.0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cost Per Gram'),
            ),
            TextFormField(
              initialValue: _editedItem['mcPerGram'] != null
                  ? _editedItem['mcPerGram'].toString()
                  : '',
              onChanged: (value) {
                _editedItem['mcPerGram'] = double.tryParse(value) ?? 0.0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Making Cost Per Gram'),
            ),
            TextFormField(
              initialValue: _editedItem['makingCost'] != null
                  ? _editedItem['makingCost'].toString()
                  : '',
              onChanged: (value) {
                _editedItem['makingCost'] = double.tryParse(value) ?? 0.0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Making Cost'),
            ),
            // Non-editable fields
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SGST:'),
                  Text('${_editedItem['sgst'].toStringAsFixed(2)}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CGST:'),
                  Text('${_editedItem['cgst'].toStringAsFixed(2)}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Cost:'),
                  Text('${_editedItem['totalCost'].toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            Navigator.of(context).pop(_editedItem);
          },
        ),
      ],
    );
  }
}

pdfWidgets.Document generateCartInvoice(List<Map<String, dynamic>> cart) {
  final pdf = pdfWidgets.Document();
  final DateTime now = DateTime.now();
  final String formattedDate = "${now.day}-${now.month}-${now.year}";

  double grandTotal = 0.0;
  double totalPrice = 0.0;
  double totalMakingCharge = 0.0;
  for (var item in cart) {
    double gram = item['gram'] ?? 0.0;
    double costPerGram = item['costPerGram'] ?? 0.0;

    double makingCost = item['mcPerGram'] ?? 0.0;
    double separateMC = item['makingCost'] ?? 0.0;
    double sgst = item['sgst'] ?? 0.0;
    double cgst = item['cgst'] ?? 0.0;
    print("object  $separateMC");
    double totalCost =
        gram * costPerGram + (gram * makingCost) + separateMC + sgst + cgst;
    item['totalCost'] = totalCost;

    grandTotal += totalCost;

    totalMakingCharge = makingCost * gram;
    totalPrice = costPerGram * gram + totalMakingCharge;
    // if (grandTotal % 1 >= 0.5) {
    //   grandTotal = grandTotal.ceilToDouble();
    // } else {
    //   grandTotal = grandTotal.floorToDouble();update
    // }

    print('Grand Total: $grandTotal');
  }

  pdf.addPage(
    pdfWidgets.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pdfWidgets.Context context) => pdfWidgets.Padding(
        padding: const pdfWidgets.EdgeInsets.all(8),
        child: pdfWidgets.Column(
          crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
          children: [
            pdfWidgets.Center(
              child: pdfWidgets.Text('Star Jewellery',
                  style: pdfWidgets.TextStyle(
                      fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold)),
            ),
            pdfWidgets.SizedBox(height: 10),
            pdfWidgets.Text('Invoice Date: $formattedDate',
                style: pdfWidgets.TextStyle(fontSize: 12)),
            pdfWidgets.SizedBox(height: 10),
            pdfWidgets.Divider(),
            pdfWidgets.SizedBox(height: 10),
            ...cart.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              return pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.only(bottom: 10),
                child: pdfWidgets.Column(
                  crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                  children: [
                    pdfWidgets.Text('Item #${index + 1}',
                        style: pdfWidgets.TextStyle(
                            fontSize: 12,
                            fontWeight: pdfWidgets.FontWeight.bold)),
                    buildRow('Metal', item['metal'] ?? ''),
                    buildRow('Item', item['item'] ?? ''),
                    buildRow('Gram', '${item['gram'].toStringAsFixed(2)}'),
                    buildRow('CostPerGram',
                        '${item['costPerGram'].toStringAsFixed(2)}'),
                    buildRow('MC/G', '${item['mcPerGram'].toStringAsFixed(2)}'),
                    // buildRow('MC/G', totalMakingCharge.toStringAsFixed(2)),
                    pdfWidgets.Divider(),

                    buildRow('Sub Total', totalPrice.toStringAsFixed(2)),
                    pdfWidgets.Divider(),

                    buildRow('MC', '${item['makingCost'].toStringAsFixed(2)}'),
                    buildRow('SGST', '${item['sgst'].toStringAsFixed(2)}'),
                    buildRow('CGST', '${item['cgst'].toStringAsFixed(2)}'),
                    pdfWidgets.Divider(),
                    buildRow('Total', item['totalCost'].toStringAsFixed(2)),
                    pdfWidgets.Divider(),

                  ],
                ),
              );
            }).toList(),
            pdfWidgets.Divider(),
            pdfWidgets.SizedBox(height: 10),
            buildRow('Grand Total', 'Rs ${grandTotal.toStringAsFixed(2)}',
                isBold: true),
          ],
        ),
      ),
    ),
  );
  return pdf;
}

pdfWidgets.Row buildRow(String label, String value, {bool isBold = false}) {
  return pdfWidgets.Row(
    mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
    children: [
      pdfWidgets.Text('$label:',
          style: pdfWidgets.TextStyle(
              fontSize: 10,
              fontWeight: isBold
                  ? pdfWidgets.FontWeight.bold
                  : pdfWidgets.FontWeight.normal)),
      pdfWidgets.Text(value,
          style: pdfWidgets.TextStyle(
              fontSize: 10,
              fontWeight: isBold
                  ? pdfWidgets.FontWeight.bold
                  : pdfWidgets.FontWeight.normal)),
    ],
  );
}


// pdfWidgets.Document generateCartInvoice(List<Map<String, dynamic>> cart) {
//   final pdf = pdfWidgets.Document();
//   final DateTime now = DateTime.now();
//   final String formattedDate = "${now.day}-${now.month}-${now.year}";

//   double grandTotal = 0.0;
//   for (var item in cart) {
//     grandTotal += item['totalCost'];
//   }

//   pdf.addPage(
//     pdfWidgets.Page(
//       pageFormat: PdfPageFormat.roll80,
//       build: (pdfWidgets.Context context) => pdfWidgets.Padding(
//         padding: pdfWidgets.EdgeInsets.all(8),
//         child: pdfWidgets.Column(
//           crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
//           children: [
//             pdfWidgets.Center(
//               child: pdfWidgets.Text('Star Jewellery',
//                   style: pdfWidgets.TextStyle(
//                       fontSize: 16, fontWeight: pdfWidgets.FontWeight.bold)),
//             ),
//             pdfWidgets.SizedBox(height: 10),
//             pdfWidgets.Text('Invoice Date: $formattedDate',
//                 style: pdfWidgets.TextStyle(fontSize: 12)),
//             pdfWidgets.SizedBox(height: 10),
//             pdfWidgets.Divider(),
//             pdfWidgets.SizedBox(height: 10),
//             ...cart.asMap().entries.map((entry) {
//               int index = entry.key;
//               Map<String, dynamic> item = entry.value;
//               return pdfWidgets.Padding(
//                 padding: pdfWidgets.EdgeInsets.only(bottom: 10),
//                 child: pdfWidgets.Column(
//                   crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
//                   children: [
//                     pdfWidgets.Text('Item #${index + 1}',
//                         style: pdfWidgets.TextStyle(
//                             fontSize: 12,
//                             fontWeight: pdfWidgets.FontWeight.bold)),
//                     buildRow('Metal', '${item['metal']}'),
//                     buildRow('Item', '${item['item']}'),
//                     buildRow('Gram', '${item['gram'].toStringAsFixed(2)}'),
//                     buildRow(
//                         'Cost/G', '${item['costPerGram'].toStringAsFixed(2)}'),
//                     
//                        buildRow( 'MC/G', '${item['makingCost'].toStringAsFixed(2)}'),
//                     buildRow('MC', '${item['separateMC'].toStringAsFixed(2)}'),
//                     buildRow('SGST', '${item['sgst'].toStringAsFixed(2)}'),
//                     buildRow('CGST', '${item['cgst'].toStringAsFixed(2)}'),
//                     pdfWidgets.Divider(),
//                     buildRow(
//                         'Total', '${item['totalCost'].toStringAsFixed(2)}'),
//                     pdfWidgets.Divider(),
//                   ],
//                 ),
//               );
//             }).toList(),
//             pdfWidgets.Divider(),
//             pdfWidgets.SizedBox(height: 10),
//             buildRow('Grand Total', 'Rs ${grandTotal.toStringAsFixed(2)}',
//                 isBold: true),
//           ],
//         ),
//       ),
//     ),
//   );
//   return pdf;
// }

// pdfWidgets.Row buildRow(String label, String value, {bool isBold = false}) {
//   return pdfWidgets.Row(
//     mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
//     children: [
//       pdfWidgets.Text('$label:',
//           style: pdfWidgets.TextStyle(
//               fontSize: 10,
//               fontWeight: isBold
//                   ? pdfWidgets.FontWeight.bold
//                   : pdfWidgets.FontWeight.normal)),
//       pdfWidgets.Text(value,
//           style: pdfWidgets.TextStyle(
//               fontSize: 10,
//               fontWeight: isBold
//                   ? pdfWidgets.FontWeight.bold
//                   : pdfWidgets.FontWeight.normal)),
//     ],
//   );
// }
