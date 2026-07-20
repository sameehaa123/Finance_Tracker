import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final String email;
  final String planName;
  final int amount;
  final String status;
  final String paymentId;
  final String orderId;
  final Timestamp? createdAt;

  const PaymentCard({
    super.key,
    required this.email,
    required this.planName,
    required this.amount,
    required this.status,
    required this.paymentId,
    required this.orderId,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final date = createdAt?.toDate();

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

            //-----------------------------------
            // EMAIL
            //-----------------------------------

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

            //-----------------------------------
            // PLAN
            //-----------------------------------

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

            //-----------------------------------
            // AMOUNT
            //-----------------------------------

            Row(
              children: [

                const Icon(
                  Icons.currency_rupee,
                  color: Colors.green,
                ),

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

            //-----------------------------------
            // STATUS
            //-----------------------------------

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

            //-----------------------------------
            // PAYMENT ID
            //-----------------------------------

            Text(
              "Payment ID : ${paymentId.isEmpty ? "-" : paymentId}",
            ),

            const SizedBox(height: 6),

            // ORDER ID
            Text(
              "Order ID : ${orderId.isEmpty ? "-" : orderId}",
            ),

            const SizedBox(height: 12),

            
            // DATE
            Text(

              date == null
                  ? "-"
                  : date.toString(),

              style: const TextStyle(
                color: Colors.grey,
              ),

            ),

          ],
        ),
      ),
    );
  }
}