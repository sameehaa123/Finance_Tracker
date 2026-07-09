import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/plan_model.dart';

class PlanController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PlanModel>> getPlans() {
    return _firestore
        .collection('packages')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlanModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }
}