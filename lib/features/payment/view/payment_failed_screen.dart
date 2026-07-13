import 'package:ai_poweredfinancetracker/features/plans/view/plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Lottie.asset(
                  'assets/lottie/failed.json',
                  height: 250,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Payment Failed",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Your payment could not be completed.\nPlease try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PlansScreen(),
      ),
    );
  },
  child: const Text("Try Again"),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}