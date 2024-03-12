import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:live_video_call/constant/strings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constant/constants.dart';
import '../../widget/bottom_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late RtcEngineEventHandler _rtcEngineEventHandler;

  RtcEngine? _engine;
  VideoViewController? _myVideoViewController;
  VideoViewController? _otherVideoController;

  bool _localUserJoined = false;
  int? _otherUId;

  bool _isSwitch = false;

  @override
  void initState() {
    super.initState();
    _rtcEngineEventHandler = rtcEngineEventHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.LIVE_TEXT),
      ),
      body: FutureBuilder(
        future: initAgora(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final engine = snapshot.requireData;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ...videoViews(engine),
                    switchButton(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BottomButton(
                  text: Strings.LIVE_LEAVE_TEXT,
                  onPressed: leaveChannel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<RtcEngine> initAgora() async {
    await requestPermission();

    if (_engine == null) {
      final engine = createAgoraRtcEngine();

      await engine.initialize(const RtcEngineContext(
        appId: Constants.APP_ID,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      engine.registerEventHandler(_rtcEngineEventHandler);

      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.enableVideo();
      await engine.startPreview();
      await engine.joinChannel(
          token: Constants.TOKEN,
          channelId: Constants.CHANNEL_NAME,
          uid: 0,
          options: const ChannelMediaOptions());

      _engine = engine;
    }

    return _engine!;
  }

  Future<void> requestPermission() async {
    final response = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = response[Permission.camera];
    final microphonePermission = response[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted ||
        microphonePermission != PermissionStatus.granted) {
      throw Strings.PERMISSION_DENIED;
    }
  }

  RtcEngineEventHandler rtcEngineEventHandler() => RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            _localUserJoined = false;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _otherUId = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _otherUId = null;
          });
        },
      );

  List<Widget> videoViews(RtcEngine engine) => [
        _isSwitch ? myVideoView(engine) : otherVideoView(engine),
        if (_localUserJoined)
          Positioned(
            left: 8.0,
            top: 8.0,
            child: Container(
              color: Colors.grey,
              height: 160,
              width: 120,
              child: _isSwitch ? otherVideoView(engine) : myVideoView(engine),
            ),
          ),
      ];

  Widget otherVideoView(RtcEngine engine) {
    if (_otherUId == null) {
      return Center(
        child: Text(Strings.WAITING_TEXT),
      );
    }

    final mainVideoController = VideoViewController.remote(
      rtcEngine: engine,
      canvas: VideoCanvas(uid: _otherUId),
      connection: const RtcConnection(channelId: Constants.CHANNEL_NAME),
    );

    _otherVideoController?.dispose();
    _otherVideoController = mainVideoController;

    return AgoraVideoView(controller: mainVideoController);
  }

  Widget myVideoView(RtcEngine engine) {
    final myVideoController = VideoViewController(
      rtcEngine: engine,
      canvas: const VideoCanvas(uid: 0),
    );

    _myVideoViewController?.dispose();
    _myVideoViewController = myVideoController;

    return AgoraVideoView(
      controller: myVideoController,
    );
  }

  Widget switchButton() {
    return Positioned(
      right: 8.0,
      top: 8.0,
      child: FloatingActionButton(
        onPressed: onSwitchVideo,
        child: const Icon(Icons.switch_video),
      ),
    );
  }

  void onSwitchVideo() {
    setState(() {
      _isSwitch = !_isSwitch;
    });
  }

  void leaveChannel() {
    Navigator.pop(context);
  }

  Future<void> _dispose() async {
    _engine?.unregisterEventHandler(_rtcEngineEventHandler);
    await _otherVideoController?.dispose();
    await _myVideoViewController?.dispose();
    await _engine?.leaveChannel();
    await _engine?.release();
  }
}
