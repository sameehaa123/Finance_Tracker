import 'package:flutter/material.dart';
import '../service/admin_service.dart';
import '../widgets/package_card.dart';

class ManagePackagesScreen extends StatefulWidget {
  const ManagePackagesScreen({super.key});

  @override
  State<ManagePackagesScreen> createState() =>
      _ManagePackagesScreenState();
}

class _ManagePackagesScreenState
    extends State<ManagePackagesScreen> {

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

Future<void> showAddPackageDialog() async {

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final cutPriceController = TextEditingController();
  final finalPriceController = TextEditingController();
  final buttonTextController = TextEditingController();
  final orderController = TextEditingController();

  bool isPopular = false;

  List<TextEditingController> featureControllers = [
    TextEditingController(),
  ];

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Package"),

            content: SizedBox(
              width: 400,

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                
                    // PACKAGE NAME                
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Package Name",
                      ),
                    ),

                    const SizedBox(height: 12),

                  
                    // DESCRIPTION
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),

                    const SizedBox(height: 12),

                    
                    // DURATION                 
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: "Duration",
                      ),
                    ),

                    const SizedBox(height: 12),

                  
                    // CUT PRICE
                    TextField(
                      controller: cutPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Cut Price",
                      ),
                    ),

                    const SizedBox(height: 12),

                    
                    // FINAL PRICE                    
                    TextField(
                      controller: finalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Final Price",
                      ),
                    ),

                    const SizedBox(height: 12),

                    
                    // BUTTON TEXT                   
                    TextField(
                      controller: buttonTextController,
                      decoration: const InputDecoration(
                        labelText: "Button Text",
                      ),
                    ),

                    const SizedBox(height: 12),

                  
                    // DISPLAY ORDER                   
                    TextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Display Order",
                      ),
                    ),

                    const SizedBox(height: 20),

                    
                    // POPULAR                   
                    CheckboxListTile(
                      value: isPopular,
                      title: const Text("Popular Package"),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setDialogState(() {
                          isPopular = value ?? false;
                        });
                      },
                    ),

                    const Divider(),

                    const SizedBox(height: 10),

                    
                    // FEATURES                   
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Features",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...featureControllers.asMap().entries.map((entry) {

                      final index = entry.key;

                      final controller = entry.value;

                      return Padding(

                        padding: const EdgeInsets.only(bottom: 10),

                        child: TextField(

                          controller: controller,

                          decoration: InputDecoration(

                            labelText:
                                "Feature ${index + 1}",

                            border:
                                const OutlineInputBorder(),

                          ),

                        ),

                      );

                    }),

                    ElevatedButton.icon(

                      onPressed: () {

                        setDialogState(() {

                          featureControllers.add(
                            TextEditingController(),
                          );

                        });

                      },

                      icon: const Icon(Icons.add),

                      label: const Text("Add Feature"),

                    ),

                  ],

                ),

              ),

            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(context);

                },

                child: const Text("Cancel"),

              ),

              ElevatedButton(

                onPressed: () async {

                  final features =
                      featureControllers
                          .map((e) => e.text.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  await AdminService().addPackage(

                    name: nameController.text.trim(),

                    description:
                        descriptionController.text.trim(),

                    duration:
                        durationController.text.trim(),

                    cutPrice:
                        int.parse(cutPriceController.text),

                    finalPrice:
                        int.parse(finalPriceController.text),

                    buttonText:
                        buttonTextController.text.trim(),

                    isPopular: isPopular,

                    order:
                        int.parse(orderController.text),

                    features: features,

                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(

                      content: Text(
                        "Package Added Successfully",
                      ),
                    ),
                  );
                },

                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> showEditPackageDialog(
  Map<String, dynamic> package,
) async{
final nameController = TextEditingController(text: package["name"],);
final descriptionController = TextEditingController(text: package["description"],);
final durationController = TextEditingController(text: package["duration"],);
final cutPriceController = TextEditingController(text: package["cutPrice"].toString(),);
final finalPriceController = TextEditingController(text: package["finalPrice"].toString(),);
final buttonTextController = TextEditingController(text: package["buttonText"],);
final orderController = TextEditingController(text: package["order"].toString(),);
bool isPopular = package["isPopular"] ?? false;

List<TextEditingController> featureControllers = (package["features"] as List<dynamic>)
.map(
  (feature)=> TextEditingController(text: feature.toString(),
  ),
).toList();

await showDialog(context: context, builder: (context) {
  return StatefulBuilder(builder: (context, setDialogState){
    return AlertDialog(
            title: const Text("Edit Package"),

            content: SizedBox(
              width: 400,

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                
                    // PACKAGE NAME                
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Package Name",
                      ),
                    ),

                    const SizedBox(height: 12),

                  
                    // DESCRIPTION
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),

                    const SizedBox(height: 12),

                    
                    // DURATION                 
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: "Duration",
                      ),
                    ),

                    const SizedBox(height: 12),

                  
                    // CUT PRICE
                    TextField(
                      controller: cutPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Cut Price",
                      ),
                    ),

                    const SizedBox(height: 12),

                    
                    // FINAL PRICE                    
                    TextField(
                      controller: finalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Final Price",
                      ),
                    ),

                    const SizedBox(height: 12),

                    
                    // BUTTON TEXT                   
                    TextField(
                      controller: buttonTextController,
                      decoration: const InputDecoration(
                        labelText: "Button Text",
                      ),
                    ),

                    const SizedBox(height: 12),

                  
                    // DISPLAY ORDER                   
                    TextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Display Order",
                      ),
                    ),

                    const SizedBox(height: 20),

                    
                    // POPULAR                   
                    CheckboxListTile(
                      value: isPopular,
                      title: const Text("Popular Package"),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setDialogState(() {
                          isPopular = value ?? false;
                        });
                      },
                    ),

                    const Divider(),

                    const SizedBox(height: 10),

                    
                    // FEATURES                   
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Features",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...featureControllers.asMap().entries.map((entry) {

                      final index = entry.key;

                      final controller = entry.value;

                      return Padding(

                        padding: const EdgeInsets.only(bottom: 10),

                        child: TextField(

                          controller: controller,

                          decoration: InputDecoration(

                            labelText:
                                "Feature ${index + 1}",

                            border:
                                const OutlineInputBorder(),

                          ),

                        ),

                      );

                    }),

                    ElevatedButton.icon(

                      onPressed: () {

                        setDialogState(() {

                          featureControllers.add(
                            TextEditingController(),
                          );

                        });

                      },

                      icon: const Icon(Icons.add),

                      label: const Text("Add Feature"),

                    ),

                  ],

                ),

              ),

            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(context);

                },

                child: const Text("Cancel"),

              ),

              ElevatedButton(

                onPressed: () async {

                  final features =
                      featureControllers
                          .map((e) => e.text.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  await AdminService().updatePackage(
                    packageId: package["id"],

                    name: nameController.text.trim(),

                    description:
                        descriptionController.text.trim(),

                    duration:
                        durationController.text.trim(),

                    cutPrice:
                        int.parse(cutPriceController.text),

                    finalPrice:
                        int.parse(finalPriceController.text),

                    buttonText:
                        buttonTextController.text.trim(),

                    isPopular: isPopular,

                    order:
                        int.parse(orderController.text),

                    features: features,

                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(

                      content: Text(
                        "Package Updated Successfully",
                      ),
                    ),
                  );
                },

                child: const Text("Save"),
              ),
            ],
          

    );
  },
  );
  },
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Manage Packages",

          style: TextStyle(

            color: Colors.white,
            fontWeight: FontWeight.bold,

          ),

        ),

        backgroundColor: const Color(0xFF00897B),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

      ),

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [

              Color(0xFFA8E6CF),

              Colors.white,

            ],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

          ),

        ),

        child: FutureBuilder<List<Map<String, dynamic>>>(

          future: AdminService().getAllPackages(),

          builder: (context, snapshot) {

            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child: CircularProgressIndicator(),
              );

            }

            if (snapshot.hasError) {

              return const Center(
                child: Text("Something went wrong"),
              );

            }

            final packages = snapshot.data ?? [];

            return Column(

              children: [

              
                // SEARCH BAR
                Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          "Search Package",
                      prefixIcon:
                          const Icon(Icons.search),
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                15),

                      ),

                    ),

                    onChanged: (value) {
                      setState(() {
                        searchText =
                            value.toLowerCase();
                      });
                    },
                  ),
                ),

                
                // PACKAGE LIST            
                Expanded(

                  child: ListView.builder(

                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 16),

                    itemCount: packages.length,

                    itemBuilder:
                        (context, index) {

                      final package =
                          packages[index];

                      final name =
                          package["name"]
                              .toString();

                      if (!name
                          .toLowerCase()
                          .contains(
                              searchText)) {

                        return const SizedBox();

                      }

                      return PackageCard(

                        name: name,

                        description:
                            package["description"]
                                ?? "",

                        duration:
                            package["duration"]
                                ?? "",

                        cutPrice:
                            package["cutPrice"]
                                ?? 0,

                        finalPrice:
                            package["finalPrice"]
                                ?? 0,

                        isPopular:
                            package["isPopular"]
                                ?? false,

                        onEdit: () {

                          showEditPackageDialog(package);

                        },

                        onDelete: () async {

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Delete Package"),
                                content: Text(
                                  "Delete ${package["name"]} ?",
                                ),
                                actions: [
                                  TextButton(onPressed: () {
                                    Navigator.pop(context,false);
                                  }, 
                                  
                                    child: const Text("Cancel"),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),

                                    onPressed: () {
                                      Navigator.pop(context,true);
                                    },

                                  child: const Text("Delete",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  ),
                                  ),
                               ],
                              );
                            },
                           );

                           if(confirm == true) {
                            await AdminService().deletePackage(
                              packageId: package["id"],
                              );
                              
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Package deleted successfully",
                                  ),
                                  ),
                              );
                           }

                        },

                      );

                    },

                  ),

                ),

              ],

            );

          },

        ),

      ),

      // ADD PACKAGE BUTTON
      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(0xFF00897B),

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        onPressed: () {

         showAddPackageDialog();

        },
      ),
    );
  }
}