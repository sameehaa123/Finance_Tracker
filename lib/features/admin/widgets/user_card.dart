import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final bool isPremium;
  final int status;
  final String userId;
  

  final VoidCallback onEditRole;
  final VoidCallback onTogglePremium;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.isPremium,
    required this.status,
    required this.userId,
    
    required this.onEditRole,
    required this.onTogglePremium,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF00897B),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(width: 10),

              Container(
                padding:const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:status == 1
                  ? Colors.green.shade50
                  : Colors.red.shade50,

                  borderRadius: 
                  BorderRadius.circular(30)
                ),

                child:Text(
                  status == 1
                  ?"Active"
                  :"Blocked",

                  style: TextStyle(
                    color: status == 1
                    ? Colors.green
                    : Colors.red,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        

                PopupMenuButton<String>(
  onSelected: (value) {
    if (value == "edit") {
      onEditRole();
    } else if (value == "premium") {
      onTogglePremium();
    } else if (value == "status") {
      onDelete();
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: "edit",
      child: Text("Edit Role"),
    ),
    PopupMenuItem(
      value: "premium",
      child: Text(
        isPremium
        ?"Remove Premium"
        :"Make Premium",
        ),
    ),
     PopupMenuItem(
      value: "status",
      child: Text(
        status == 1
        ? "Block User"
        :"Unblock User",
      ),
    ),
  ],
),

              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: isPremium
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Text(
                    isPremium ? "Premium" : "Free",
                    style: TextStyle(
                      color: isPremium
                          ? Colors.green
                          : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}