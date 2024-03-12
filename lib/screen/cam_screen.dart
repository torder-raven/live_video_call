import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import '../const/agora.dart';
import '../const/strings.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({super.key});

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? engine;
  int? uid = 0;
  int? otherUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.LIVE),
      ),
      body: FutureBuilder<bool>(
          future: init(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
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
                    child: Stack(children: [
                  renderMainView(),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Colors.green,
                      height: 160,
                      width: 120,
                      child: renderSubView(),
                    ),
                  ),
                ])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (engine != null) {
                        await engine!.leaveChannel();
                        engine = null;
                      }
                    },
                    child: const Text(
                      Strings.EXIT_CHANNEL,
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }

  renderMainView() {
    if (uid == null) {
      return const Center(
        child: Text(
          Strings.CHANNEL_MSG_PLEASE_ENTER_CHANNEL,
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine!,
          canvas: const VideoCanvas(
            uid: 0,
          ),
        ),
      );
    }
  }

  renderSubView() {
    if (otherUid == null) {
      return const Center(
        child: Text(
          Strings.CHANNEL_MSG_NO_USER_IN_CHANNEL,
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine!!,
          canvas: VideoCanvas(uid: otherUid),
          connection: const RtcConnection(channelId: CHANNEL_NAME),
        ),
      );
    }
  }

  Future<bool> init() async {
    final resp = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = resp[Permission.camera];
    final microphonePermission = resp[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted ||
        microphonePermission != PermissionStatus.granted) {
      throw Strings.PERMISSION_MSG_NO_CAMERA_OR_MIC_PERMISSION;
    }

    if (engine == null) {
      engine = createAgoraRtcEngine();

      await engine!.initialize(
        RtcEngineContext(
          appId: dotenv.env[Strings.APP_ID],
        ),
      );

      engine!.registerEventHandler(
        RtcEngineEventHandler(
            onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print(
              "${Strings.CHANNEL_INFO_ENTER_CHANNEL} ${Strings.UID}: ${connection.localUid}");
          setState(() {
            uid = connection.localUid;
          });
        },
            // 내가 채널에서 나갔을 때
            onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          log(Strings
              .CHANNEL_INFO_EXIT_CHANNEL); // cf. debugprint가 있는데 이건 디버그 모드에서만 활용 가능!
          setState(() {
            uid = null;
          });

          onUserJoined:
          (RtcConnection connection, int remoteUid, int elapsed) {
            log(
              "${Strings.CHANNEL_INFO_OTHER_USER_ENTER_CHANNEL} ${Strings.OTHRER_UID}:$remoteUid",
            );
          };

          onUserOffline:
          (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            log(
              "${Strings.CHANNEL_INFO_OTHER_USRE_EXIT_CHANNEL} ${Strings.OTHRER_UID}:$remoteUid",
            );
          };

          setState(() {
            otherUid = null;
          });
        }),
      );

      await engine!.enableVideo();

      await engine!.startPreview();

      ChannelMediaOptions options = const ChannelMediaOptions();

      await engine!.joinChannel(
        token: TEMP_TOKEN,
        channelId: CHANNEL_NAME,
        uid: 0,
        options: options,
      );
    }

    return true;
  }
}
