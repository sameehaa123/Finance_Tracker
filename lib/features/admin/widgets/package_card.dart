import 'package:flutter/material.dart';

class PackageCard extends StatelessWidget {
  final String name;
  final String description;
  final String duration;
  final int cutPrice;
  final int finalPrice;
  final bool isPopular;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PackageCard({
    super.key,
    required this.name,
    required this.description,
    required this.duration,
    required this.cutPrice,
    required this.finalPrice,
    required this.isPopular,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {

                    if (value == "edit") {
                      onEdit();
                    }

                    if (value == "delete") {
                      onDelete();
                    }

                  },

                  itemBuilder: (_) => const [

                    PopupMenuItem(
                      value: "edit",
                      child: Text("Edit"),
                    ),

                    PopupMenuItem(
                      value: "delete",
                      child: Text("Delete"),
                    ),

                  ],

                ),

              ],
            ),

            const SizedBox(height: 10),

            Text(description),

            const SizedBox(height: 10),

            Row(
              children: [

                const Icon(
                  Icons.schedule,
                  color: Colors.blue,
                ),

                const SizedBox(width: 8),

                Text(duration),

              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                Text(
                  "₹$cutPrice",
                  style: const TextStyle(
                    decoration:
                        TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 15),

                Text(
                  "₹$finalPrice",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            if (isPopular)
              Container(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(

                  color: Colors.orange.shade100,

                  borderRadius:
                      BorderRadius.circular(30),

                ),

                child: const Text(

                  "⭐ Popular",

                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),

                ),

              ),

          ],
        ),
      ),
    );
  }
}