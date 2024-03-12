import 'package:flutter/material.dart';
import 'package:live_video_call/screen/camera/video_view.dart';

import '../../const/strings.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: CamScreenAppbar(),
      body: VideoView()
    );
  }

  AppBar CamScreenAppbar() {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Text(Strings.LIVE),
    );
  }
}