import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_gps_device_tracking_app/screens/login_screen.dart';
import 'package:flutter_gps_device_tracking_app/screens/register_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 3,
      controller: _pageController,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return LoginScreen(
              pageController: _pageController,
            );
          case 1:
            return WelcomeScreen(pageController: _pageController);
          case 2:
            return RegisterScreen(pageController: _pageController);
          default:
            return const Center(
              child: SizedBox(
                child: Text("Not Valid Page"),
              ),
            );
        }
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  final PageController pageController;
  const WelcomeScreen({super.key, required this.pageController});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome!",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      widget.pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn);
                    },
                    child: const Text("Login")),
                ElevatedButton(
                    onPressed: () {
                      widget.pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn);
                    },
                    child: const Text("Register"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
