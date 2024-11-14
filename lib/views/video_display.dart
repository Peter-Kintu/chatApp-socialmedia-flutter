// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late RTCPeerConnection _peerConnection;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _createPeerConnection();
  }

  void _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _createPeerConnection() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]
    });
    // Additional setup for peer connection
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer)),
          Expanded(child: RTCVideoView(_remoteRenderer)),
        ],
      ),
    );
  }
}
