import 'package:flutter/material.dart';
import '../service/admin_service.dart';
import '../widgets/user_card.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() =>
      _ManageUsersScreenState();
}

class _ManageUsersScreenState
    extends State<ManageUsersScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  Future<void> showRoleDialog(
  String userId,
  String? currentRole,
) async {

  String selectedRole = (currentRole ?? "").trim();

  const roles = [
    "Admin",
    "Student",
    "Professional",
    "Senior Citizen",
  ];

  if (!roles.contains(selectedRole)) {
    selectedRole = "Student";
  }
  print("Selected Role = '$selectedRole'");


  await showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(

        title: const Text("Change Role"),

       content: DropdownButtonFormField<String>(
  value: selectedRole,
  isExpanded: true,
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
  ),
  items: roles.map((role) {
    return DropdownMenuItem<String>(
      value: role,
      child: Text(role),
    );
  }).toList(),
  onChanged: (value) {
    if (value != null) {
      selectedRole = value;
    }
  },
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

              await AdminService().updateUserRole(

                userId: userId,

                newRole: selectedRole,

              );

              if (!mounted) return;

              Navigator.pop(context);

              setState(() {});

            },

            child: const Text("Save"),

          ),

        ],

      );

    },

  );

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Users",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00897B),
        iconTheme: const IconThemeData(
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
          future: AdminService().getAllUsers(),

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

            final users = snapshot.data ?? [];

            return Column(
              children: [

              
                Padding(
                  padding: const EdgeInsets.all(16),

                  child: TextField(
                    controller: searchController,

                    decoration: InputDecoration(
                      hintText: "Search user by email",

                      prefixIcon: const Icon(Icons.search),

                      filled: true,

                      // CHANGED
                      fillColor:
                          Colors.white.withOpacity(0.95),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
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

                
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    itemCount: users.length,

                    itemBuilder: (context, index) {
                      final user = users[index];

                      final email =
                          user["email"].toString();

                      if (!email
                          .toLowerCase()
                          .contains(searchText)) {
                        return const SizedBox();
                      }

                      return UserCard(
                        userId: user["id"],

                        name: email
                            .split("@")
                            .first,

                        email: email,

                        role:
                            user["role"] ?? "Student",

                        isPremium:
                            user["isPremium"] ?? false,

                        status: user["status"] ?? 1,

                        onEditRole: () {
                          print("Email: ${user["email"]}");
                          print("Role: '${user["role"]}'");

                          showRoleDialog(
                            user["id"], 
                            user["role"]?.toString(),
                          );
                        },

                        onTogglePremium: () async {
                           await AdminService().updatePremiumStatus(
                            userId: user["id"],
                            status: !(user["isPremium"] ?? false),
                           );

                           setState(() {});
                        },
onDelete: () async {

  final isBlocked = (user["status"] ?? 1) == 0;

  final confirm = await showDialog<bool>(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: Text(
          isBlocked ? "Unblock User" : "Block User",
        ),

        content: Text(

          isBlocked
              ? "Do you want to unblock ${user["email"]}?"
              : "Do you want to block ${user["email"]}?",

        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context, false);

            },

            child: const Text("Cancel"),

          ),

          ElevatedButton(

            style: ElevatedButton.styleFrom(

              backgroundColor:
                  isBlocked
                      ? Colors.green
                      : Colors.red,

            ),

            onPressed: () {

              Navigator.pop(context, true);

            },

            child: Text(

              isBlocked
                  ? "Unblock"
                  : "Block",

              style: const TextStyle(
                color: Colors.white,
              ),

            ),

          ),

        ],

      );

    },

  );

  if (confirm == true) {

    await AdminService().UpdateUserStatus(

      userId: user["id"],

      status: isBlocked ? 1 : 0,

    );

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(

          isBlocked
              ? "User unblocked successfully"
              : "User blocked successfully",

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
    );
  }
}