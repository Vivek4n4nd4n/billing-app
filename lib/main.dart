import 'package:billing_app/cartPage.dart';
import 'package:billing_app/cart_provider.dart';
import 'package:billing_app/homepage.dart';
import 'package:billing_app/invoice.dart';

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const JewelryShopApp());
}

class JewelryShopApp extends StatelessWidget {
  const JewelryShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
            create: (context) => CartProvider(),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jewelry Shop App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: 
        JewelryShopHomePage(),
      ),
    );
  }
}
