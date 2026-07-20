import 'package:ai_poweredfinancetracker/core/Services/sharedpref_service.dart';
import 'package:ai_poweredfinancetracker/features/admin/controller/admin_controller.dart';
import 'package:ai_poweredfinancetracker/features/admin/view/manage_users_screen.dart';
import 'package:ai_poweredfinancetracker/features/admin/view/payments_screen.dart';
import 'package:ai_poweredfinancetracker/features/admin/widgets/dashboard_card.dart';
import 'package:ai_poweredfinancetracker/features/auth/view/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00897B),
        title: const Text("Spendly Admin",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),),
    
        actions: [

  IconButton(

    icon: const Icon(Icons.logout_rounded,
    color: Colors.white,
    ),

    onPressed: () async {

      await FirebaseAuth.instance.signOut();

      await SharedprefService.clearRole();

      Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),

        (route) => false,

      );

    },

  ),

],
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

  child: FutureBuilder<Map<String, dynamic>>(

    future: AdminController().getDashboardData(),

    builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.waiting) {

        return const Center(
          child: CircularProgressIndicator(),
        );

      }

      final data = snapshot.data ?? {} ;
      final totalUsers = data["users"] ?? 0;
      final totalPayments = data ["payments"] ?? 0;
      final totalRevenue = data ["revenue"] ?? 0;
      final totatPackages = data ["packages"] ?? 0;

      return Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              width: double.infinity,

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: const [

                  BoxShadow(

                    color: Colors.black12,

                    blurRadius: 8,

                  )

                ],

              ),

              child: Padding(

                padding: const EdgeInsets.all(18),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Text(

                      "Welcome Admin 👋",

                      style: TextStyle(

                        color: Color(0xFF00897B),

                        fontWeight: FontWeight.bold,

                        fontSize: 24,

                      ),

                    ),

                    const SizedBox(height: 20),

                    GridView.count(

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      crossAxisCount: 2,

                      crossAxisSpacing: 15,

                      mainAxisSpacing: 15,

                      childAspectRatio: 1,

                      children: [

                        DashboardCard(

                          icon: Icons.people,

                          title: "Users",

                          value: totalUsers.toString(),

                          color: Colors.green,

                        ),

                        DashboardCard(

                          icon: Icons.payment,

                          title: "Payments",

                          value: totalPayments.toString(),

                          color: Colors.blue,

                        ),

                        DashboardCard(

                          icon: Icons.inventory,

                          title: "Packages",

                          value: totatPackages.toString(),

                          color: Colors.orange,

                        ),

                        DashboardCard(

                          icon: Icons.currency_rupee,

                          title: "Revenue",

                          value: "₹${totalRevenue.toStringAsFixed(0)}",

                          color: Colors.purple,

                        ),

                      ],

                    ),

    const SizedBox(height: 25),


Column(
children: [
SizedBox(
  width: double.infinity,

  child: ElevatedButton.icon(

    icon: const Icon(Icons.people),

    label: const Text("Manage Users"),

    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00897B),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),

    onPressed: () {
      Navigator.push( context,
      MaterialPageRoute(builder: (_) =>
      const ManageUsersScreen(),
      ),
      );

    },
  ),
),

const SizedBox(height: 15),
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.payment),
    label: const Text("View payments"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ), 
    ),

    onPressed: () {
      Navigator.push(context,
      MaterialPageRoute(builder: (_) => 
      const PaymentsScreen(),
      ),
      );

    },
  ),
),

const SizedBox(height: 15),
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.inventory),
    label: const Text("Manage Packages"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ), 
    ),

    onPressed: () {

    },
  ),
),

const SizedBox(height: 15),
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.bar_chart),
    label: const Text("Analytics"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ), 
    ),

    onPressed: () {

    },
  ),
),

 ],
                ),

              

                  ],

                ),

              ),

            ),

          ],

        ),

      );

    },

  ),

),     
    );
  }
}