import 'package:billing_app/cartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class JewelryShopHomePage extends StatefulWidget {
  @override
  _JewelryShopHomePageState createState() => _JewelryShopHomePageState();
}

class _JewelryShopHomePageState extends State<JewelryShopHomePage> {


  
  TextEditingController gramController = TextEditingController();
  TextEditingController costPerGramController = TextEditingController();
  TextEditingController newMetalController = TextEditingController();
  TextEditingController newItemController = TextEditingController();
  TextEditingController mcPerGramController = TextEditingController();
  TextEditingController makingCostController = TextEditingController();

  String selectedMetal = 'Gold';
  String selectedItem = '';
  double gram = 0.0;
  double costPerGram = 0.0;
  double makingCost = 0.0;
  double mcPerGram = 0.0;
  double sgstRate = 0.015;
  double cgstRate = 0.015;
  double totalCost = 0.0;
  var sgst;
  var cgst;
  bool includeGSTandSGST = true;

  Map<String, Map<String, double>> itemPrices = {
    'Gold': {'Chain': 100.0, 'Ring': 50.0},
    'Silver': {'Metti': 40.0, 'Bracelet': 20.0},
  };

  ValueNotifier<List<String>> metalListNotifier =
      ValueNotifier<List<String>>(['Gold', 'Silver']);

  @override
  void initState() {
    super.initState();
    updateSelectedItem();
    calculateTotalCost();
  }

  void updateSelectedItem() {
    selectedItem = '';
    if (itemPrices[selectedMetal] != null &&
        itemPrices[selectedMetal]!.isNotEmpty) {
      selectedItem = itemPrices[selectedMetal]!.keys.first;
    }
  }

void calculateTotalCost() {
  double itemPrice = costPerGram * gram;
  double totalMakingCost = (gram * mcPerGram) + makingCost; // Making cost based on weight and additional making cost
  
  // Calculate SGST and CGST on the combined item price and making cost
  sgst = includeGSTandSGST ? (itemPrice + totalMakingCost) * sgstRate : 0.0; 
  cgst = includeGSTandSGST ? (itemPrice + totalMakingCost) * cgstRate : 0.0; 
  
  double total = itemPrice + totalMakingCost + sgst + cgst;

  setState(() {
    totalCost = double.parse(total.toStringAsFixed(2));
  });
}


  List<Map<String, dynamic>> cart = [];

  bool isItemInCart(Map<String, dynamic> newItem) {
    for (var item in cart) {
      if (item['metal'] == newItem['metal'] &&
          item['item'] == newItem['item']) {
        return true;
      }
    }
    return false;
  }

  void addToCart() {
    Map<String, dynamic> newItem = {
      'metal': selectedMetal,
      'item': selectedItem,
      'gram': gram,
      'costPerGram': costPerGram,
      'makingCost': makingCost,
      'mcPerGram': mcPerGram,
      'sgst': sgst,
      'cgst': cgst,
      'totalCost': totalCost,
    };

    cart.add(newItem);
    setState(() {
     gramController.clear();
     costPerGramController.clear();
     mcPerGramController.clear();
     makingCostController.clear();
    costPerGram =0.0;
    mcPerGram = 0.0;
    makingCost=0.0;
    sgst = 0.0;
    cgst = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 235, 214, 159),
        elevation: 2,
        title: Text('Star Jewellery'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showMetalAndItemDialog();
              },
              icon: const Icon(
                Icons.add,
                color: Colors.greenAccent,
              ),
              label: const Text(
                'Manage Metals/Items',
                style: TextStyle(color: Colors.greenAccent),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to CartPage
                 Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      CartPage(cart: cart), // Navigate to CartPage
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red,
            ),
            child: const Text("Direct Bill"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              const Text(
                'Metal Type:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder<List<String>>(
                valueListenable: metalListNotifier,
                builder: (context, metalList, _) {
                  return DropdownButton<String>(
                    value: selectedMetal,
                    items: metalList.map((metal) {
                      return DropdownMenuItem(
                        value: metal,
                        child: Text(metal),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMetal = value!;
                        updateSelectedItem();
                        calculateTotalCost();
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Selected Item:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  showItemSelectionDialog();
                },
                child: Card(
                  child: ListTile(
                    title: Text(selectedItem),
                    subtitle: Text(
                      'Price per Gram: ₹${costPerGram.toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Additional Costs:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: gramController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Gram'),
                onChanged: (value) {
                  setState(() {
                    gram = double.tryParse(value) ?? 0.0;
                    calculateTotalCost();
                  });
                },
              ),
              TextFormField(
                controller: costPerGramController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost Per Gram'),
                onChanged: (value) {
                  setState(() {
                    costPerGram = double.tryParse(value) ?? 0.0;
                    calculateTotalCost();
                  });
                },
              ),
              TextFormField(
                controller: mcPerGramController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Making Cost per gram'),
                onChanged: (value) {
                  setState(() {
                    mcPerGram = double.tryParse(value) ?? 0.0;
                    calculateTotalCost();
                  });
                },
              ),
              TextFormField(
                controller: makingCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Making Cost '),
                onChanged: (value) {
                  setState(() {
                    makingCost = double.tryParse(value) ?? 0.0;
                    calculateTotalCost();
                  });
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  const Text(
                    'Calculations:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  FlutterSwitch(
                    height: 20,
                    value: includeGSTandSGST,
                    onToggle: (value) {
                      setState(() {
                        includeGSTandSGST = value;
                        if (!includeGSTandSGST) {
                          totalCost = totalCost - (cgst + sgst);
                          cgst = 0.0;
                          sgst = 0.0;
                        } else {
                          calculateTotalCost();
                        }
                      });
                    },
                    activeText: "Include GST/SGST",
                    inactiveText: "Exclude GST/SGST",
                    activeTextColor: Colors.white,
                    inactiveTextColor: Colors.white,
                    activeColor: Colors.green,
                    inactiveColor: Colors.red,
                  ),
                ],
              ),
              Text(
                'Item Price: ₹${(costPerGram * gram).toStringAsFixed(2)}',
              ),
              Text(
                'MC/G: ₹${(mcPerGram*gram).toStringAsFixed(2)}',
              ),
              Text(
                'Mc: ₹${(makingCost).toStringAsFixed(2)}',
              ),
              Text(
                'SGST @ ${sgstRate * 100}%: ₹${(sgst).toStringAsFixed(2)}',
              ),
              Text(
                'CGST @ ${cgstRate * 100}%: ₹${(cgst).toStringAsFixed(2)}',
              ),
              const Divider(height: 16.0, thickness: 1.0),
              const Text(
                'NETT:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addToCart,
        child: Icon(Icons.save),
        tooltip: 'Save to Cart',
      ),
    );
  }

  Future<void> showItemSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Metal Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: itemPrices[selectedMetal]!.keys.map((item) {
              return ListTile(
                title: Text(item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Show an edit dialog for the item name
                        showEditItemDialog(item);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Show a confirmation dialog for item deletion
                        showDeleteItemDialog(item);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    selectedItem = item;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  calculateTotalCost(); // Recalculate the total cost
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> showDeleteItemDialog(String item) async {
    bool confirmDelete = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Delete Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to delete the item "$item"?'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemPrices[selectedMetal]!.remove(item);
                        if (selectedItem == item) {
                          selectedItem = '';
                        }
                        confirmDelete =
                            true; // Set to true to confirm the deletion
                      });
                      Navigator.of(context).pop(); // Close the dialog
                      calculateTotalCost(); // Recalculate the total cost
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // If the user confirmed the deletion, you can also update the selected item
    if (confirmDelete) {
      setState(() {
        selectedItem = '';
      });
    }
  }

  Future<void> showEditItemDialog(String item) async {
    TextEditingController itemController = TextEditingController(text: item);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Item Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: itemController,
                decoration: InputDecoration(labelText: 'Item Name'),
                onChanged: (value) {
                  setState(() {
                    item = value; // Update the item name as the user types
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Remove the old item and add the new one
                    itemPrices[selectedMetal]!.remove(item);
                    itemPrices[selectedMetal]![item] = 0.0;
                    selectedItem = item; // Update the selected item if needed
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  calculateTotalCost(); // Recalculate the total cost
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showMetalAndItemDialog() async {
    String newMetal = selectedMetal; // Default to the current selected metal
    String newItem = '';
    List<String> newItems = [];
    TextEditingController metalController = TextEditingController();
    TextEditingController itemController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Manage Metals and Items'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: newMetal,
                    items: [
                      ...metalListNotifier.value.map((metal) {
                        return DropdownMenuItem(
                          value: metal,
                          child: Text(metal),
                        );
                      }),
                      DropdownMenuItem(
                        value: 'Add New Metal',
                        child: Text('Add New Metal'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        newMetal = value!;
                        if (newMetal == 'Add New Metal') {
                          metalController.clear();
                          itemController.clear();
                          newItems.clear();
                        }
                      });
                    },
                  ),
                  if (newMetal == 'Add New Metal')
                    TextFormField(
                      controller: metalController,
                      decoration: InputDecoration(labelText: 'New Metal Name'),
                      onChanged: (value) {
                        newMetal = value;
                      },
                    ),
                  TextFormField(
                    controller: itemController,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    onChanged: (value) {
                      newItem = value;
                    },
                  ),
                  if (newItems.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Items:'),
                        ...newItems.map((newItem) {
                          return Text('- $newItem');
                        }),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (newMetal.isNotEmpty && newItem.isNotEmpty) {
                          if (!itemPrices.containsKey(newMetal)) {
                            itemPrices[newMetal] = {};
                            metalListNotifier.value = itemPrices.keys
                                .toList(); // Update the metal list
                          }
                          itemPrices[newMetal]![newItem] =
                              0.0; // Set the initial price
                        }
                      });
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
