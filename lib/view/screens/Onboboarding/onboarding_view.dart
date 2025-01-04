import 'package:customer/controller/on_boarding_controller.dart';
import 'package:get/get.dart';
import '../../../app/generalImports.dart';

class OnboardingView extends StatelessWidget {
  OnboardingView({super.key});

  final controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Obx(
        () => Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: controller.isLastPage.value
              ? getStarted(context)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip Button
                    TextButton(
                      onPressed: controller.skipToLastPage,
                      child: const Text("Skip"),
                    ),

                    // Indicator
                    SmoothPageIndicator(
                      controller: controller.pageController,
                      count: controller.items.length,
                      onDotClicked: (index) =>
                          controller.pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeIn,
                      ),
                      effect: const WormEffect(
                        dotHeight: 12,
                        dotWidth: 12,
                        activeDotColor: Colors.blue,
                      ),
                    ),

                    // Next Button
                    TextButton(
                      onPressed: controller.nextPage,
                      child: const Text("Next"),
                    ),
                  ],
                ),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: PageView.builder(
            onPageChanged: controller.onPageChanged,
            itemCount: controller.items.length,
            controller: controller.pageController,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(controller.items[index].image),
                  const SizedBox(height: 15),
                  Text(
                    controller.items[index].title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    controller.items[index].descriptions,
                    style: const TextStyle(color: Colors.grey, fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getStarted(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue,
      ),
      width: MediaQuery.of(context).size.width,
      height: 55,
      child: TextButton(
        onPressed: controller.markOnboardingComplete,
        child: const Text(
          "Get started",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
