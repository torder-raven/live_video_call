import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_video_call/screen/camera/camera_screen.dart';

import '../../const/path.dart';
import '../../const/strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        backgroundColor: Colors.blue[100],
        body: Column(
          children: [
            Expanded(
              child: _Logo(),
            ),
            Expanded(
              child: _Image(),
            ),
            Expanded(
              child: _Button(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.blue[300]!,
              blurRadius: 12.0,
              spreadRadius: 2.0,
            ),
          ],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [VideoIcon(), SizedBox(width: 12.0), LiveText()],
          ),
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(Paths.HOME_IMAGE),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CameraScreen(),
              ),
            );
          },
          child: Text(Strings.JOIN),
        ),
      ],
    );
  }
}


Icon VideoIcon() {
  return const Icon(
    Icons.videocam,
    color: Colors.white,
    size: 40.0,
  );
}

Text LiveText() {
  return Text(
    Strings.LIVE,
    style: TextStyle(
      color: Colors.white,
      fontSize: 30.0,
      letterSpacing: 4.0,
    ),
  );
}