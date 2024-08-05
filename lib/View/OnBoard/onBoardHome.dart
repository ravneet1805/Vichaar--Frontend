import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vichaar/AuthPages/login.dart';
import 'package:vichaar/AuthPages/signup.dart';

import '../../constant.dart';
import '../linkedinLogin.dart';

class OnboardingHomeScreen extends StatefulWidget {
  @override
  State<OnboardingHomeScreen> createState() => _OnboardingHomeScreenState();
}



class _OnboardingHomeScreenState extends State<OnboardingHomeScreen> {
  final PageController _pageController = PageController();
  late Timer _timer;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.page!.round() == 2) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }
   void signInWithLinkedIn(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WebViewExample(),
    ));
  }
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/onboarding_image.png',
                    width: mq.width, // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      _buildPage(
                        title: 'Dreams take flight, Ideas ignite, Minds unite.',
                        description:
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean bibendum mi in lorem aliquam, vitae posuere odio suscipit.',
                      ),
                      _buildPage(
                        title: 'Share your vision, Build your future.',
                        description:
                            'Collaborate with like-minded individuals to turn your dreams into reality.',
                      ),
                      _buildPage(
                        title: 'Innovate together, Achieve success.',
                        description:
                            'Join forces to create innovative solutions and achieve greatness.',
                      ),

                      //SizedBox(height: 16),
                    ],
                  ),
                ),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      dotColor: kGreyColor,
                      activeDotColor: kPurpleColor,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Container(
                    
                   
                   width: mq.width*0.65,
                    child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: mq.width*0.3,
                          decoration: BoxDecoration(
                            border: Border.all(color: kGreyHeadTextcolor
                            ),
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: TextButton(onPressed: (){
                             Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LoginScreen()),

      );
                          
                          }, child: Text('Sign In', style: TextStyle(color: kGreyHeadTextcolor),)
                          ),
                        ),
                        Container(
                          width: mq.width*0.3,
                          decoration: BoxDecoration(
                            
                             color: kGreyHeadTextcolor,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: TextButton(onPressed: (){
                            Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SignupScreen()),

      );
                          
                          }, child: Text('Sign Up', style: TextStyle(color: Colors.black),)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                 padding: const EdgeInsets.only(left: 80.0),
                                child: Divider(
                                  color: Colors.white24,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "or",
                                style: TextStyle(color: Colors.white24, fontSize: 14),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                 padding: const EdgeInsets.only(right: 80.0),
                                child: Divider(
                                  color: Colors.white24,
                                  thickness: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: mq.width * 0.65,
                            decoration: BoxDecoration(
                              color: kGreyColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextButton(
                              onPressed: () {
                                signInWithLinkedIn(context);
                              },
                              child: Container(
                                width: mq.width * 0.5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.linkedin, size: (mq.width*0.055 <= 18)
                                    ? mq.width*0.055
                                    : 18,
                                    color: Color(0xff0072B1)),
                                    Text(
                                      'Continue with LinkedIn',
                                      style: TextStyle(color: kGreyHeadTextcolor,
                                      fontSize: (mq.width*0.04 <= 16)
                                      ?mq.width*0.04
                                      :14

                                      
                                      )
                                      ,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String description}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
