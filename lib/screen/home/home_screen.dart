import 'package:flutter/material.dart';
import 'package:live_video_call/screen/camera/camera_screen.dart';
import 'package:live_video_call/widget/bottom_button.dart';

import '../../constant/constants.dart';
import '../../constant/strings.dart';
import 'live_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Expanded(child: Center(child: LiveButton())),
              Expanded(child: Image.asset(Constants.LOGO_IMAGE_PATH)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomButton(
                      text: Strings.LIVE_ENTRY_TEXT,
                      onPressed: () {
                        goToCameraScreen(context);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void goToCameraScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (builderContext) => const CameraScreen()),
    );
  }
}
