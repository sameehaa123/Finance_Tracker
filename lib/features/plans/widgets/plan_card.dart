import 'package:flutter/material.dart';

import '../model/plan_model.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;

  const PlanCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final Color planColor = Color(
      int.parse(plan.color.replaceFirst('#', '0xff')),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: planColor.withOpacity(.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isPopular)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: planColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "POPULAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Text(
            plan.name,
            style: TextStyle(
              fontSize: 26,
              color: planColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            plan.description,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Text(
                "₹${plan.cutPrice}",
                style: const TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "₹${plan.finalPrice}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: planColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              child: Text(plan.buttonText),
            ),
          ),

          const SizedBox(height: 25),

          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: planColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}