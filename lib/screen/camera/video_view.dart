import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_video_call/const/env_keys.dart';
import '../../common.dart';
import '../../const/strings.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  final defaultUserid = 0;
  RtcEngine? engine;
  int? uid = 0;
  int? otherUid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: init(),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [renderMainView(), renderSubView()],
              ),
            ),
            GoOutButton()
          ],
        );
      },
    );
  }

  @override void dispose() {
    super.dispose();
    clearAllInfo();
  }

  Padding GoOutButton() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          exitChannel();
        },
        child: Text(Strings.EXIT),
      ),
    );
  }

  renderMainView() {
    if (uid == null) {
      return Center(
        child: Text(Strings.PLEASE_JOIN),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine!,
          canvas: VideoCanvas(
            uid: defaultUserid,
          ),
        ),
      );
    }
  }

  renderSubView() {
    if (otherUid == null) {
      return Center(
        child: Text(Strings.NO_USER_IN_CHANNEL),
      );
    } else {
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          color: Colors.grey,
          height: 160,
          width: 120,
          child: AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine!,
              canvas: VideoCanvas(uid: otherUid),
              connection: RtcConnection(
                  channelId: dotenv.env[EnvKeys.CHANNEL_NAME].toString()),
            ),
          ),
        ),
      );
    }
  }

  Future<bool> init() async {
    checkPermission();

    if (engine == null) {
      initEngine();
      setEventHandler();
      await engine!.enableVideo();
      await engine!.startPreview();
      joinChannel();
    }
    return true;
  }

  initEngine() async {
    engine = createAgoraRtcEngine();
    await engine!.initialize(
      RtcEngineContext(appId: dotenv.env[EnvKeys.APP_ID].toString()),
    );
  }

  setEventHandler() {
    engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapesd) {
          setState(() {
            uid = connection.localUid;
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            uid == null;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapesd) {
          setState(() {
            otherUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            otherUid = null;
          });
        },
      ),
    );
  }

  joinChannel() async {
    ChannelMediaOptions options = ChannelMediaOptions();

    await engine!.joinChannel(
        token: dotenv.env[EnvKeys.TEMP_TOKEN].toString(),
        channelId: dotenv.env[EnvKeys.CHANNEL_NAME].toString(),
        uid: defaultUserid,
        options: options);
  }

  exitChannel() async {
    if (engine != null) {
      await engine!.leaveChannel();
      engine = null;
    }
    Navigator.of(context).pop();
  }

  clearAllInfo() {
    engine = null;
    uid = null;
    otherUid = null;
  }
}
