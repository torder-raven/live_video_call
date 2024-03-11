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
  VideoViewController? _mainVideoViewController;
  VideoViewController? _subVideoViewController;
  RtcEngine? _engine;
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
        }
    );
  }

  @override
  void dispose() {
    clearAllInfo();
    super.dispose();
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
      _mainVideoViewController = VideoViewController(
        rtcEngine: _engine!,
        canvas: VideoCanvas(
          uid: defaultUserid,
        ),
      );
      return AgoraVideoView(
        controller: _mainVideoViewController!,
      );
    }
  }

  renderSubView() {
    if (otherUid == null) {
      return Center(
        child: Text(Strings.NO_USER_IN_CHANNEL),
      );
    } else {
      _subVideoViewController = VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: otherUid),
        connection: RtcConnection(
            channelId: dotenv.env[EnvKeys.CHANNEL_NAME].toString()),
      );
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          color: Colors.grey,
          height: 160,
          width: 120,
          child: AgoraVideoView(
            controller: _subVideoViewController!,
          ),
        ),
      );
    }
  }

  Future<bool> init() async {
    checkPermission();

    if (_engine == null) {
      initEngine();
      setEventHandler();
      await _engine!.enableVideo();
      await _engine!.startPreview();
      joinChannel();
    }
    return true;
  }

  initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(appId: dotenv.env[EnvKeys.APP_ID].toString()),
    );
  }

  setEventHandler() {
    _engine!.registerEventHandler(
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

    await _engine!.joinChannel(
        token: dotenv.env[EnvKeys.TEMP_TOKEN].toString(),
        channelId: dotenv.env[EnvKeys.CHANNEL_NAME].toString(),
        uid: defaultUserid,
        options: options);
  }

  exitChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      _engine = null;
    }
    Navigator.of(context).pop();
  }

  clearAllInfo() {
    uid = null;
    otherUid = null;
    _engine = null;
    _mainVideoViewController?.dispose();
    _subVideoViewController?.dispose();
  }
}
