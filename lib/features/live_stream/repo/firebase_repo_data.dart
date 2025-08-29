import 'package:firebase_database/firebase_database.dart';

import '../model/reactions_model.dart';
/////TODO : handle it properly // -----------enhance Error in whole app --------

class LiveStreamRepository {
  static final LiveStreamRepository _instance =
      LiveStreamRepository._internal();
  factory LiveStreamRepository() => _instance;
  LiveStreamRepository._internal();

  late DatabaseReference _channelRef;
  late DatabaseReference _viewerCountRef;
  late DatabaseReference _guestsRef;
  late DatabaseReference _reactionsRef;

  void initializeReferences(String channelName) {
    _channelRef = FirebaseDatabase.instance
        .ref()
        .child('streams')
        .child(channelName);

    _viewerCountRef = _channelRef.child('viewerCount');
    _guestsRef = _channelRef.child('guests');
    _reactionsRef = _channelRef.child('reactions');
  }

  Stream<int> getViewerCountStream() {
    return _viewerCountRef.onValue.map((event) {
      return event.snapshot.exists ? event.snapshot.value as int? ?? 0 : 0;
    });
  }

  Stream<Map<String, dynamic>> getGuestsStream() {
    return _guestsRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return <String, dynamic>{};
    });
  }

  Stream<Reaction> getReactionsStream() {
    return _reactionsRef.limitToLast(50).onChildAdded.map((event) {
      return Reaction.fromMap(
        event.snapshot.value as Map<dynamic, dynamic>,
        event.snapshot.key!,
      );
    });
  }

  Future<void> updateViewerCount(bool increment) async {
    try {
      if (increment) {
        await _viewerCountRef.set(ServerValue.increment(1));
      } else {
        await _viewerCountRef.set(ServerValue.increment(-1));
      }
    } catch (e) {
      throw Exception("Error updating viewer count: $e");
    }
  }

  Future<void> sendReaction(Reaction reaction) async {
    try {
      await _reactionsRef.push().set(reaction.toMap());
    } catch (e) {
      throw Exception('Error sending reaction: $e');
    }
  }

  Future<void> removeGuest(String userName) async {
    try {
      await _guestsRef.child(userName).remove();
    } catch (e) {
      throw Exception('Error removing guest: $e');
    }
  }

  Future<void> cleanupOldReactions() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(minutes: 2));
      final snapshot = await _reactionsRef
          .orderByChild('timestamp')
          .endAt(cutoffTime.millisecondsSinceEpoch)
          .once();

      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        for (final key in data.keys) {
          await _reactionsRef.child(key).remove();
        }
      }
    } catch (e) {
      throw Exception('Error cleaning up reactions: $e');
    }
  }

  Future<void> sendStreamStatus(String channelName, String status) async {
    try {
      final statusRef = FirebaseDatabase.instance
          .ref()
          .child('streams')
          .child(channelName)
          .child('status');

      await statusRef.set({
        'status': status,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Error updating stream status: $e');
    }
  }

  Stream<String> getStreamStatusStream(String channelName) {
    return FirebaseDatabase.instance
        .ref()
        .child('streams')
        .child(channelName)
        .child('status')
        .child('status')
        .onValue
        .map((event) {
          return event.snapshot.exists
              ? event.snapshot.value as String
              : 'live';
        });
  }
}
