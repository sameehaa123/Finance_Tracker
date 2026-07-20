import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentCard extends StatelessWidget {
  final String email;
  final String planName;
  final int amount;
  final String status;
  final String paymentId;
  final String orderId;
  final String errorMessage;

  final Timestamp? createdAt;
  final Timestamp? completedAt;
  

  const PaymentCard({
    super.key,
    required this.email,
    required this.planName,
    required this.amount,
    required this.status,
    required this.paymentId,
    required this.orderId,
    required this.errorMessage,
    required this.createdAt,
    required this.completedAt,
  });

  @override
  Widget build(BuildContext context) {
    final createdDate = createdAt?.toDate();
    final completedDate = completedAt?.toDate();

    final formattedCreated = createdDate == null
    ? "-"
    : DateFormat("dd MMM yyyy • hh:mm a",).format(createdDate);

    final formattedCompleted = completedDate == null
    ? "-"
    : DateFormat("dd MMM yyyy • hh:mm a",).format(completedDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            
            // EMAIL
            Row(
              children: [

                const Icon(
                  Icons.email,
                  color: Color(0xFF00897B),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 15),

            
            // PLAN
            Row(
              children: [

                const Icon(
                  Icons.workspace_premium,
                  color: Colors.orange,
                ),

                const SizedBox(width: 10),

                Text(planName),

              ],
            ),

            const SizedBox(height: 10),

          
            // AMOUNT
            Row(
              children: [
                const SizedBox(width: 10),

                Text(
                  "₹${amount / 100}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

          
            // STATUS
            Container(

              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),

              decoration: BoxDecoration(

                color: status == "Success"
                    ? Colors.green.shade50
                    : Colors.red.shade50,

                borderRadius:
                    BorderRadius.circular(30),

              ),

              child: Text(

                status,

                style: TextStyle(

                  color: status == "Success"
                      ? Colors.green
                      : Colors.red,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

            const SizedBox(height: 12),

         
          // SUCCESS PAYMENT
        if (status == "Success") ...[
          const Text(
    "Payment ID",
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),

  Text(
    paymentId.isEmpty ? "-" : paymentId,
  ),


  const SizedBox(height: 10),
  Row(
    children: [
      const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 18,
      ),

      const SizedBox(width: 8),
      Expanded(
        child: Text(
          "Completed : $formattedCompleted",
        ),
      ),
    ],
  ),
]


// FAILED PAYMENT
else ...[

  const Text(

    "Error",

    style: TextStyle(

      fontWeight: FontWeight.bold,

      color: Colors.red,

    ),

  ),

  Text(

    errorMessage.isEmpty ||
            errorMessage == "undefined"
        ? "Unknown Error"

        : errorMessage,

    style: const TextStyle(

      color: Colors.red,

    ),

  ),

  const SizedBox(height: 10),

  Row(

    children: [

      const Icon(

        Icons.schedule,

        size: 18,

        color: Colors.grey,

      ),

      const SizedBox(width: 8),

      Expanded(

        child: Text(

          "Created : $formattedCreated",

        ),

      ),

    ],

  ),

],
          

          ],
        ),
      ),
    );
  }
}