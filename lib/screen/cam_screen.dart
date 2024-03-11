import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:live_video_call/const/agora.dart';
import 'package:permission_handler/permission_handler.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({super.key});

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? rtcEngine;

  // 내 ID
  int? uid = 0;

  // 상대방 ID
  int? otherUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LIVE",
        ),
      ),
      body: FutureBuilder<bool>(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return Center(
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        color: Colors.grey,
                        height: 160,
                        width: 160,
                        child: renderSubView(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (rtcEngine != null) {
                      await rtcEngine?.leaveChannel();
                      rtcEngine = null;
                    }

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "채널 나가기",
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  renderMainView() {
    if (uid == null) {
      return Center(
        child: Text(
          "채널에 참여해주세요.",
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: rtcEngine!,
          canvas: VideoCanvas(
            uid: 0,
          ),
        ),
      );
    }
  }

  renderSubView() {
    if (otherUid == null) {
      return Center(
        child: Text("채널에 유저가 없습니다."),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: rtcEngine!,
          canvas: VideoCanvas(uid: otherUid),
          connection: RtcConnection(
            channelId: CHANNEL_ID,
          ),
        ),
      );
    }
  }

  Future<bool> init() async {
    final response = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = response[Permission.camera];
    final microphonePermission = response[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted) {
      throw "카메라 권한이 없습니다.";
    }

    if (microphonePermission != PermissionStatus.granted) {
      throw "마이크 권한이 없습니다.";
    }

    if (rtcEngine == null) {
      rtcEngine = createAgoraRtcEngine();

      await rtcEngine?.initialize(
        RtcEngineContext(
          appId: APP_ID,
        ),
      );

      rtcEngine?.registerEventHandler(
        RtcEngineEventHandler(
            // 내가 채널에 입장했을 때
            // rtcConnection 연결 정보
            // elapsed 연결된 시간(연결된 지 얼마나 됐는지?)
            onJoinChannelSuccess: (RtcConnection rtcConnection, int elapsed) {
          print("채널에 입장 uid : ${rtcConnection.localUid}");
          setState(() {
            uid = rtcConnection.localUid;
          });
        }, onLeaveChannel: (RtcConnection rtcConnection, RtcStats states) {
          print("채널 퇴장");
          setState(() {
            uid = null;
          });
        }, onUserJoined:
                (RtcConnection rtcConnection, int remoteUid, int elapsed) {
          print("상대가 채널에 입장 uid : $remoteUid");
          setState(() {
            otherUid = remoteUid;
          });
        }, onUserOffline: (RtcConnection rtcConnection, int remoteUid,
                UserOfflineReasonType reasonType) {
          print("상대가 채널에서 나감 uid : $remoteUid");
          setState(() {
            otherUid = null;
          });
        }),
      );

      await rtcEngine?.enableVideo();
      await rtcEngine?.startPreview();

      ChannelMediaOptions options = ChannelMediaOptions();

      await rtcEngine?.joinChannel(
        token: TEMP_TOKEN,
        channelId: CHANNEL_ID,
        uid: 0,
        options: options,
      );
    }

    return true;
  }
}
