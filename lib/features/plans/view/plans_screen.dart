import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controller/plan_controller.dart';
import '../model/plan_model.dart';
import '../widgets/plan_card.dart';

class PlansScreen extends StatelessWidget {
   PlansScreen({super.key});

  final PlanController controller = PlanController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
           colors: [
        Color.fromARGB(255, 144, 233, 202),
        Color .fromARGB(255, 144, 233, 202),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<PlanModel>>(
            stream: controller.getPlans(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No plans available",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final plans = snapshot.data!.map((plan) => plan).toList();

              return Column(
                children: [
                  const SizedBox(height: 25),

                  const Text(
                    "Choose Your Plan",
                    style: TextStyle(
                      fontSize: 34,
                      color: Color(0xFF00897B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      "Upgrade your Spendly experience with plans designed for every user.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                        ),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                      return Padding(padding: const EdgeInsets.only 
                      (bottom: 20),

                        child:  PlanCard(plan: plans[index]),
                      );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}