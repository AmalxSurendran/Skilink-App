// ignore_for_file: deprecated_member_use, camel_case_types, file_names

import 'package:customer/controller/home_controller.dart';
import 'package:customer/view/screens/homeContainerScreens/bookingScreen.dart';
import 'package:customer/view/screens/homeContainerScreens/homeScreen.dart';
import 'package:customer/view/screens/homeContainerScreens/profileScreen.dart';
import '../../app/generalImports.dart';
import 'package:get/get.dart';

class homeContainer extends StatelessWidget {
  final int initialPage;

  const homeContainer({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    // Initialize the PageController with the initial page
    controller.pageController = PageController(initialPage: initialPage);

    return WillPopScope(
      onWillPop: () => controller.onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          leading: Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/skilinkmain.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          title: const Text(
            "SkiLink",
            style: TextStyle(color: Colors.black),
          ),
          titleSpacing: 1,
          automaticallyImplyLeading: false,
        ),
        body: PageView(
          controller: controller.pageController,
          onPageChanged: (index) {
            controller
                .updateIndex(index); // Synchronize with the BottomNavigationBar
          },
          children: [
            HomeScreen(),
            BookingScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            unselectedItemColor: Colors.black,
            currentIndex: controller.bottomNavIndex.value,
            onTap: (index) {
              controller.updateIndex(
                  index); // Sync page index with BottomNavigationBar
              controller.pageController
                  .jumpToPage(index); // Move PageView to the selected index
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
