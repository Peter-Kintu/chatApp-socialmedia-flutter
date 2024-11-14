// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;

  @override
  void initState() {
    super.initState();
    _createPeerConnection();
  }

  void _createPeerConnection() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]
    });
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});
    _peerConnection.addStream(_localStream);
    // Additional setup for peer connection
  }

  @override
  void dispose() {
    _localStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call')),
      body: const Center(child: Text('Audio Call in Progress')),
    );
  }
}
