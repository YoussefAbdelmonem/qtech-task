import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../live_stream/live_stream_screen.dart';

class PreJoinScreen extends StatefulWidget {
  const PreJoinScreen({super.key});

  @override
  State<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends State<PreJoinScreen> {
  final _nameController = TextEditingController();
  final _channelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _firebaseConnected = false;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channelController.dispose();
    super.dispose();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      // Test basic connectivity first
      final ref = FirebaseDatabase.instance.ref().child('test');
      await ref.set({
        'timestamp': ServerValue.timestamp,
        'message': 'Firebase connected!',
      });

      // Try to read the data back
      final snapshot = await ref.get();
      if (snapshot.exists) {
        debugPrint('✅ Firebase connection successful: ${snapshot.value}');
        if (mounted) {
          setState(() {
            _firebaseConnected = true;
            _errorMessage = null;
          });
        }
      } else {
        debugPrint('⚠️ Firebase write successful but read failed');
        if (mounted) {
          setState(() {
            _firebaseConnected = false;
            _errorMessage = "Firebase read operation failed";
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Firebase connection failed: $e');

      // Show user-friendly error
      if (mounted) {
        setState(() {
          _firebaseConnected = false;
          _errorMessage =
              "Firebase connection failed. Please check your internet connection.";
        });
      }
    }
  }

  Future<void> _checkChannelAndJoin() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_firebaseConnected) {
      setState(() {
        _errorMessage =
            "Firebase not connected. Please wait or retry connection.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final channelName = _channelController.text.trim();
      final userName = _nameController.text.trim();

      debugPrint('🔍 Checking channel: $channelName for user: $userName');

      // Check if channel exists and get host info
      final channelRef = FirebaseDatabase.instance
          .ref()
          .child('streams')
          .child(channelName);

      final snapshot = await channelRef.get();

      bool isHost = false;
      if (!snapshot.exists) {
        // Channel doesn't exist, this user will be the host
        isHost = true; // ← FIXED: Changed from false to true
        debugPrint('🎥 Creating new channel - User will be HOST');

        await channelRef.set({
          'host': {
            'name': userName,
            'uid': 0, // Will be updated when Agora assigns actual UID
            'joinedAt': ServerValue.timestamp,
          },
          'viewerCount': 0,
          'guests': {},
          'createdAt': ServerValue.timestamp,
        });

        debugPrint('✅ Channel created successfully');
      } else {
        // Channel exists, check if host is still active
        final hostSnapshot = await channelRef.child('host').get();
        if (!hostSnapshot.exists) {
          setState(() {
            _errorMessage =
                "Channel exists but no host found. Please try again.";
            _isLoading = false;
          });
          return;
        }

        debugPrint('👥 Joining existing channel as GUEST');

        // Check if username already exists as guest
        final existingGuest = await channelRef
            .child('guests')
            .child(userName)
            .get();
        if (existingGuest.exists) {
          setState(() {
            _errorMessage =
                "Username '$userName' is already taken in this channel. Please choose a different name.";
            _isLoading = false;
          });
          return;
        }

        // Add as guest
        await channelRef.child('guests').child(userName).set({
          'name': userName,
          'joinedAt': ServerValue.timestamp,
        });

        debugPrint('✅ Added as guest successfully');
      }

      // Navigate to live stream screen
      if (mounted) {
        debugPrint('🚀 Navigating to live stream screen...');
        debugPrint(
          '📱 User role: ${isHost ? "HOST" : "GUEST"}',
        ); // Add this debug line
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LiveStreamScreen(
              channelName: channelName,
              userName: userName,
              isHost: isHost,
            ),
          ),
        );
      }
      //test channel
    } catch (e) {
      debugPrint('❌ Error joining channel: $e');
      setState(() {
        _errorMessage = "Failed to join channel: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Join Live Stream'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Firebase Status Indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _firebaseConnected
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _firebaseConnected
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _firebaseConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: _firebaseConnected
                            ? Colors.green
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _firebaseConnected
                            ? "Connected to Firebase"
                            : "Connecting to Firebase...",
                        style: TextStyle(
                          color: _firebaseConnected
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (!_firebaseConnected)
                        GestureDetector(
                          onTap: _testFirebaseConnection,
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),

                // App Icon/Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Join Live Stream',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your details to join or create a live stream',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: 'Enter your display name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (value.trim().length > 20) {
                      return 'Name must be less than 20 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Channel Input
                TextFormField(
                  controller: _channelController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Channel Name',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: 'Enter or create channel name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.tv, color: Colors.grey),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a channel name';
                    }
                    if (value.trim().length < 3) {
                      return 'Channel name must be at least 3 characters';
                    }
                    if (value.trim().length > 15) {
                      return 'Channel name must be less than 15 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Join Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_firebaseConnected)
                        ? null
                        : _checkChannelAndJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _firebaseConnected
                          ? Colors.red
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _firebaseConnected
                                ? 'Join Stream'
                                : 'Connecting...',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Text(
                    '💡 If the channel doesn\'t exist, you\'ll become the host. Otherwise, you\'ll join as a guest.',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
