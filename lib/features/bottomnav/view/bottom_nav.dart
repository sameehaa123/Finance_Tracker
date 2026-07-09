import 'package:flutter/material.dart';

import '../../../core/Services/sharedpref_service.dart';
import '../../dashboard/view/professional_dashboard.dart';
import '../../dashboard/view/senior_dashboard.dart';
import '../../dashboard/view/student_dashboard.dart';
import '../../plans/view/plans_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

   List<Widget> pages =  [
    
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
bool isloading = true;
  initState() {
    super.initState();
    initdata();
  } 
  initdata() async {
   
    var role = await SharedprefService.getRole();
    if (role == 'Student') {
      pages.add(const StudentDashboard());
      pages.add( PlansScreen());
    } else if (role == 'Professional') {
      pages.add(const ProfessionalDashboard());
      pages.add( PlansScreen());
    } else if (role == 'Senior Citizen') {
      pages.add(const SeniorDashboard());
      pages.add( PlansScreen());
    }else {
      pages.add(const StudentDashboard());
      pages.add( PlansScreen());
    }
    isloading = false;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Plans",
          ),
        ],
      ),
    );
  }
}