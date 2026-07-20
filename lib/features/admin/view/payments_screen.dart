import 'package:ai_poweredfinancetracker/features/admin/service/admin_service.dart';
import 'package:ai_poweredfinancetracker/features/admin/widgets/payment_card.dart';
import 'package:flutter/material.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payments",
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
          future: AdminService().getAllPayments(),

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

            final payments = snapshot.data ?? [];

            return Column(
              children: [

                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(16),

                  child: TextField(
                    controller: searchController,

                    decoration: InputDecoration(
                      hintText: "Search by email",

                      prefixIcon:
                          const Icon(Icons.search),

                      filled: true,

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

                
                // PAYMENT LIST
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    itemCount: payments.length,

                    itemBuilder: (context, index) {
                      final payment = payments[index];

                      final email =
                          payment["email"]
                              .toString();

                      if (!email
                          .toLowerCase()
                          .contains(searchText)) {
                        return const SizedBox();
                      }

                      return PaymentCard(
                        email: email,

                        planName:
                            payment["planName"] ?? "-",

                        amount:
                            payment["amount"] ?? 0,

                        status:
                            payment["status"] ?? "-",

                        paymentId:
                            payment["paymentId"] ?? "",

                        orderId:
                            payment["orderId"] ?? "",

                        errorMessage: 
                            payment["errorMessage"] ?? "",

                        createdAt:
                            payment["createdAt"],

                        completedAt: 
                            payment["completedAt"],
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