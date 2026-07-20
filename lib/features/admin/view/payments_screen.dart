import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {

  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Payments",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        backgroundColor: const Color(0xFF00897B),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

      ),

      body: const Center(

        child: Text(

          "Payments Screen",

          style: TextStyle(
            fontSize: 22,
          ),

        ),

      ),

    );

  }

}