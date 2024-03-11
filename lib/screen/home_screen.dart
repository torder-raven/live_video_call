import 'package:flutter/material.dart';
import 'package:live_video_call/const/formatter.dart';
import 'package:live_video_call/screen/cam_screen.dart';

import '../const/strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: _Logo()),
            Expanded(child: _Image()),
            Expanded(child: _Button()),
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
            color: Colors.purple,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.purple[300]!,
                blurRadius: 12.0,
                spreadRadius: 2.0,
              )
            ]),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam,
                color: Colors.white,
                size: 40.0,
              ),
              SizedBox(
                width: 12.0,
              ),
              Text(Strings.LIVE,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    letterSpacing: 4.0,
                  )),
            ],
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
      child: Image.asset("home_img".convertToFileFormat()),
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
                  MaterialPageRoute(builder: (_) => const CamScreen()),
                );
              },
              child: const Text(Strings.ENTER))
        ]);
  }
}
