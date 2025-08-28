import 'package:flutter/material.dart';

class JoinLiveScreen extends StatelessWidget {
  const JoinLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Join live")),
          ],
        ),
      ),
    );
  }
}
