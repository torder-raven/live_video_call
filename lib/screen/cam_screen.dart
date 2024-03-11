import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:live_video_call/const/agora.dart';
import 'package:live_video_call/resource/strings.dart';
import 'package:permission_handler/permission_handler.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({super.key});

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? rtcEngine;
  RtcEngineEventHandler? rtcEngineEventHandler;

  // 내 ID
  int? uid = 0;

  // 상대방 ID
  int? otherUid;

  @override
  void initState() {
    super.initState();
    initRtcEngine();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.APP_TITLE,
        ),
      ),
      // setState 마다 future Block이 호출 됨!
      // FutureBuilder가 꼭 필요한가?
      body: FutureBuilder<bool>(
        future: checkPermission(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    renderMainView(),
                    renderSubView(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    Strings.LEAVE_CHANNEL,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    disposeRtcEngine();
    super.dispose();
  }

  renderMainView() {
    if (uid == null) {
      return const Center(
        child: Text(
          Strings.PLEASE_JOIN_CHANNEL,
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: getRtcEngine(),
          canvas: const VideoCanvas(
            uid: 0,
          ),
        ),
      );
    }
  }

  renderSubView() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        color: Colors.grey,
        height: 160,
        width: 160,
        child: renderOtherUserView(),
      ),
    );
  }

  renderOtherUserView() {
    if (otherUid == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Icon(
            Icons.no_accounts_rounded,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: getRtcEngine(),
          // View를 여러 개 관리하게 된다면 여러 명이서 영상 통화를 할 수 있을까?
          canvas: VideoCanvas(uid: otherUid),
          connection: const RtcConnection(
            channelId: CHANNEL_ID,
          ),
        ),
      );
    }
  }

  RtcEngine getRtcEngine() {
    return rtcEngine ??= createAgoraRtcEngine();
  }

  RtcEngineEventHandler getRtcEngineEventHandler() {
    return rtcEngineEventHandler ??= RtcEngineEventHandler(
      onJoinChannelSuccess: onJoinChannelSuccess,
      onLeaveChannel: onLeaveChannel,
      onUserJoined: onUserJoined,
      onUserOffline: onUserOffline,
    );
  }

  onJoinChannelSuccess(
    RtcConnection rtcConnection,
    int elapsed,
  ) {
    // 내가 채널에 입장했을 때
    // rtcConnection 연결 정보
    // elapsed 연결된 시간(연결된 지 얼마나 됐는지?)
    setState(() {
      uid = rtcConnection.localUid;
    });
  }

  onLeaveChannel(
    RtcConnection rtcConnection,
    RtcStats states,
  ) {
    setState(() {
      uid = null;
    });
  }

  onUserJoined(
    RtcConnection rtcConnection,
    int remoteUid,
    int elapsed,
  ) {
    setState(() {
      otherUid = remoteUid;
    });
  }

  onUserOffline(
    RtcConnection rtcConnection,
    int remoteUid,
    UserOfflineReasonType reasonType,
  ) {
    setState(() {
      otherUid = null;
    });
  }

  Future<bool> initRtcEngine() async {
    await disposeRtcEngine();
    await getRtcEngine().initialize(
      const RtcEngineContext(
        appId: APP_ID,
      ),
    );

    getRtcEngine().registerEventHandler(getRtcEngineEventHandler());

    await getRtcEngine().enableVideo();
    await getRtcEngine().startPreview();

    ChannelMediaOptions options = const ChannelMediaOptions();

    await getRtcEngine().joinChannel(
      token: TEMP_TOKEN,
      channelId: CHANNEL_ID,
      uid: 0,
      options: options,
    );

    return true;
  }

  Future<bool> checkPermission() async {
    final response = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = response[Permission.camera];
    final microphonePermission = response[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted) {
      throw Strings.ERROR_NOT_GRANT_CAMERA_PERMISSION;
    }

    if (microphonePermission != PermissionStatus.granted) {
      throw Strings.ERROR_NOT_GRANT_MICROPHONE_PERMISSION;
    }
    return true;
  }

  disposeRtcEngine() async {
    getRtcEngine().unregisterEventHandler(getRtcEngineEventHandler());
    disposeRtcEngineEventHandler();

    await getRtcEngine().leaveChannel();
    rtcEngine = null;
  }

  disposeRtcEngineEventHandler() {
    rtcEngineEventHandler = null;
  }
}
