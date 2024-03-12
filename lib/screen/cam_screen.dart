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
  RtcEngine? _rtcEngine;
  RtcEngineEventHandler? _rtcEngineEventHandler;
  VideoViewController? _localVideoViewController;
  final Map<int, VideoViewController> _remoteVideoViewControllers = {};

  // 내 ID
  int? myUserId;
  final Set<int> userIds = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.APP_TITLE,
        ),
      ),
      // setState 마다 future Block이 호출 됨!
      // FutureBuilder가 꼭 필요한가?
      body: FutureBuilder<bool>(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || myUserId == null) {
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
                  onPressed: onPressExit,
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
    if (myUserId == null) {
      return const Center(
        child: Text(
          Strings.PLEASE_JOIN_CHANNEL,
        ),
      );
    } else {
      return AgoraVideoView(
        controller: getVideoViewController(),
      );
    }
  }

  renderSubView() {
    return Align(
      alignment: Alignment.topLeft,
      child: renderOtherUserView(),
    );
  }

  renderOtherUserView() {
    if (userIds.isNotEmpty) {
      return Row(
        children: userIds
            .map(
              (userId) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: AgoraVideoView(
                    controller: createRemoteVideoViewController(
                      userId: userId,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Container();
    }
  }

  VideoViewController createRemoteVideoViewController({
    required int userId,
  }) {
    return _remoteVideoViewControllers[userId] ??= VideoViewController.remote(
      rtcEngine: getRtcEngine(),
      canvas: VideoCanvas(
        uid: userId,
      ),
      connection: const RtcConnection(
        channelId: CHANNEL_ID,
      ),
    );
  }

  RtcEngine getRtcEngine() {
    return _rtcEngine ??= createAgoraRtcEngine();
  }

  RtcEngineEventHandler getRtcEngineEventHandler() {
    return _rtcEngineEventHandler ??= RtcEngineEventHandler(
      onJoinChannelSuccess: onJoinChannelSuccess,
      onLeaveChannel: onLeaveChannel,
      onUserJoined: onUserJoined,
      onUserOffline: onUserOffline,
    );
  }

  VideoViewController getVideoViewController() {
    return _localVideoViewController ??= VideoViewController(
      rtcEngine: getRtcEngine(),
      canvas: VideoCanvas(
        uid: myUserId ??= 0,
      ),
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
      myUserId = rtcConnection.localUid;
    });
  }

  onLeaveChannel(
    RtcConnection rtcConnection,
    RtcStats states,
  ) {
    setState(() {
      myUserId = null;
    });
  }

  onUserJoined(
    RtcConnection rtcConnection,
    int remoteUid,
    int elapsed,
  ) {
    setState(() {
      userIds.add(remoteUid);
    });
  }

  onUserOffline(
    RtcConnection rtcConnection,
    int remoteUid,
    UserOfflineReasonType reasonType,
  ) {
    setState(() {
      userIds.remove(remoteUid);
    });

    _remoteVideoViewControllers[remoteUid]?.dispose();
    _remoteVideoViewControllers.remove(remoteUid);
  }

  checkPermission() async {
    final response = await [Permission.camera, Permission.microphone].request();

    if (response[Permission.camera] != PermissionStatus.granted) {
      throw Strings.ERROR_NOT_GRANT_CAMERA_PERMISSION;
    }

    if (response[Permission.microphone] != PermissionStatus.granted) {
      throw Strings.ERROR_NOT_GRANT_MICROPHONE_PERMISSION;
    }
  }

  Future<bool> initRtcEngine() async {
    if (_rtcEngine == null) {
      await getRtcEngine().initialize(
        const RtcEngineContext(
          appId: APP_ID,
        ),
      );

      getRtcEngine().registerEventHandler(getRtcEngineEventHandler());

      await getRtcEngine().enableVideo();
      await getRtcEngine().startPreview();
    }

    return true;
  }

  joinChannel() async {
    if (myUserId != null) return;

    ChannelMediaOptions options = const ChannelMediaOptions();

    await getRtcEngine().joinChannel(
      token: TEMP_TOKEN,
      channelId: CHANNEL_ID,
      uid: myUserId ??= 0,
      options: options,
    );
  }

  Future<bool> init() async {
    await checkPermission();
    await initRtcEngine();
    await joinChannel();
    return true;
  }

  onPressExit() async {
    await disposeRtcEngine();
    Navigator.of(context).maybePop();
  }

  disposeVideoViewController() async {
    if (_localVideoViewController != null) {
      await _localVideoViewController?.dispose();
      _localVideoViewController = null;
    }

    if (_remoteVideoViewControllers.isNotEmpty) {
      _remoteVideoViewControllers.forEach((userId, controller) async {
        await controller.dispose();
        _remoteVideoViewControllers.remove(userId);
      });
    }
  }

  disposeRtcEngineEventHandler() {
    if (_rtcEngineEventHandler != null) {
      getRtcEngine().unregisterEventHandler(getRtcEngineEventHandler());
      _rtcEngineEventHandler = null;
    }
  }

  disposeRtcEngine() async {
    await disposeVideoViewController();
    await disposeRtcEngineEventHandler();

    if (_rtcEngine != null) {
      await getRtcEngine().leaveChannel();
      await getRtcEngine().release();
      _rtcEngine = null;
    }
  }
}
