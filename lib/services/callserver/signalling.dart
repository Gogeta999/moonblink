// import 'dart:async';
// import 'package:moonblink/services/chat_service.dart';

// enum SignalingState {
//   CallStateNew,
//   CallStateRinging,
//   CallStateInvite,
//   CallStateConnected,
//   CallStateBye,
//   ConnectionOpen,
//   ConnectionClosed,
//   ConnectionError,
// }

// /*
//  * callbacks for Signaling API.
//  */
// typedef void SignalingStateCallback(SignalingState state);
// typedef void StreamStateCallback();
// typedef void OtherEventCallback(dynamic event);
// typedef void DataChannelMessageCallback();
// typedef void DataChannelCallback();

// class Signaling {
//   ChatModel _socket;
//   // var _port = 3000;
//   var _remoteCandidates = [];
//   SignalingStateCallback onStateChange;
//   StreamStateCallback onLocalStream;
//   StreamStateCallback onAddRemoteStream;
//   StreamStateCallback onRemoveRemoteStream;
//   OtherEventCallback onPeersUpdate;
//   OtherEventCallback onEventUpdate;
//   DataChannelMessageCallback onDataChannelMessage;
//   DataChannelCallback onDataChannel;
//   //invite
//   void invite() {
//     if (this.onStateChange != null) {
//       this.onStateChange(SignalingState.CallStateNew);
//     }
//   }
//   //end call
//   void bye() {
//     if (this.onStateChange != null) {
//       this.onStateChange(SignalingState.CallStateBye);
//     }
//     _remoteCandidates.clear();
//   }

//   void onMessage(tag, message) async {
//     switch (tag) {
//       case OFFER_EVENT:
//         {

//         }
//         break;
//       case ANSWER_EVENT:
//         {
//         }
//         break;
//       case ICE_CANDIDATE_EVENT:
//         {
//         }
//         break;
//       case CLIENT_ID_EVENT:
//         {

//         }
//         break;
//       default:
//         break;
//     }
//   }


//   _createPeerConnection(id, media, userScreen, {isHost = false}) async {
//     if (media != 'data') _localStream = await createStream(media, userScreen);
//     RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
//     if (media != 'data') pc.addStream(_localStream);
//     pc.onIceCandidate = (candidate) {
//       final iceCandidate = {
//         'sdpMLineIndex': candidate.sdpMlineIndex,
//         'sdpMid': candidate.sdpMid,
//         'candidate': candidate.candidate,
//       };
//       emitIceCandidateEvent(isHost, iceCandidate);
//     };

//     pc.onIceConnectionState = (state) {
//       print('onIceConnectionState $state');
//       if (state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
//           state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
//         bye();
//       }
//     };

//     pc.onAddStream = (stream) {
//       if (this.onAddRemoteStream != null) this.onAddRemoteStream(stream);
//       //_remoteStreams.add(stream);
//     };

//     pc.onRemoveStream = (stream) {
//       if (this.onRemoveRemoteStream != null) this.onRemoveRemoteStream(stream);
//       _remoteStreams.removeWhere((it) {
//         return (it.id == stream.id);
//       });
//     };

//     pc.onDataChannel = (channel) {
//       _addDataChannel(id, channel);
//     };

//     return pc;
//   }

//   _addDataChannel(id, RTCDataChannel channel) {
//     channel.onDataChannelState = (e) {};
//     channel.onMessage = (RTCDataChannelMessage data) {
//       if (this.onDataChannelMessage != null)
//         this.onDataChannelMessage(channel, data);
//     };
//     dataChannel = channel;

//     if (this.onDataChannel != null) this.onDataChannel(channel);
//   }

//   _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
//     RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
//     RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
//     _addDataChannel(id, channel);
//   }

//   _createOffer(String id, RTCPeerConnection pc, String media) async {
//     try {
//       RTCSessionDescription s =
//           await pc.createOffer(media == 'data' ? _dcConstraints : _constraints);
//       pc.setLocalDescription(s);

//       final description = {'sdp': s.sdp, 'type': s.type};
//       emitOfferEvent(id, description);
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   _createAnswer(String id, RTCPeerConnection pc, media) async {
//     try {
//       RTCSessionDescription s = await pc
//           .createAnswer(media == 'data' ? _dcConstraints : _constraints);
//       pc.setLocalDescription(s);

//       final description = {'sdp': s.sdp, 'type': s.type};
//       emitAnswerEvent(description);
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   _send(event, data) {
//     _socket.send(event, data);
//   }

//   emitOfferEvent(peerId, description) {
//     _send(OFFER_EVENT, {'peerId': peerId, 'description': description});
//   }

//   emitAnswerEvent(description) {
//     _send(ANSWER_EVENT, {'description': description});
//   }

//   emitIceCandidateEvent(isHost, candidate) {
//     _send(ICE_CANDIDATE_EVENT, {'isHost': isHost, 'candidate': candidate});
//   }
// }
