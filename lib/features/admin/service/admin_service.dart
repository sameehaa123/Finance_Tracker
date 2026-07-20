import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {

  Future<int> getTotalUsers() async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .get();

    return snapshot.docs.length;
  }

Future<int> getTotalPayments() async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('payments')
            .where("status", isEqualTo: "Success")
            .get();

    return snapshot.docs.length;
  }

  Future<double> getTotalRevenue() async {
    final snapshot = await FirebaseFirestore.instance
    .collection("payments")
    .where("status", isEqualTo: "Success")
    .get();

    double totalRevenue = 0;
    for (var doc in snapshot.docs) {
      totalRevenue +=(doc["amount"] as num).toDouble();
    }

return totalRevenue;

  }

 Future<int> getTotalPackages() async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('packages')
            .get();

    return snapshot.docs.length;
  }

Future<List<Map<String,dynamic>>> getAllUsers() async {


    final snapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .get();

    return snapshot.docs.map((doc){

      return {
        // Firestore document ID
        "id": doc.id,
        // User fields
        ...doc.data(),

      };

    }).toList();



  }

Future<void> updateUserRole({
  required String userId,
  required String newRole,
}) async {

  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .update({

    "role": newRole,

  });

}

Future<void> updatePremiumStatus({
  required String userId,
  required bool status,
}) async {

  await FirebaseFirestore.instance
  .collection("users")
  .doc(userId)
  .update({

    "isPremium": status,
  });
}

Future<void> UpdateUserStatus({
  required String userId,
  required int status,
}) async {

  await FirebaseFirestore.instance
  .collection("users")
  .doc(userId)
  .update({
    "status": status,
  });
}

Future<List<Map<String, dynamic>>> getAllPayments() async {

  final snapshot = await FirebaseFirestore.instance
  .collection("payments")
  .orderBy(
    "createdAt",
    descending: true,
  )
  .get();

  return snapshot.docs.map((doc) {
    return {
      "id": doc.id,
      ...doc.data(),
    };
  }).toList();
}


}