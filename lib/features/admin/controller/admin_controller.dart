import '../service/admin_service.dart';

class AdminController {

  final AdminService _service = AdminService();

  Future<Map<String, dynamic>> getDashboardData() async {

    final users = await _service.getTotalUsers();

    final payments = await _service.getTotalPayments();

    final revenue = await _service.getTotalRevenue();
    
    final packages = await _service.getTotalPackages();

    return {

      "users": users,

      "payments": payments,

      "packages": packages,

      "revenue": revenue,

    };
  }

}