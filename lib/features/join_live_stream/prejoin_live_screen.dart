import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtech_task/core/extensions/enums.dart';
import 'package:qtech_task/core/widgets/error_widget.dart';
import 'package:qtech_task/features/join_live_stream/widgets/header_widget.dart';
import '../../core/widgets/button_widget.dart';
import '../../core/widgets/app_input_widget.dart';
import '../live_stream/live_stream_screen.dart';
import 'cubit/join_live_stream_cubit.dart';

import 'cubit/join_live_stream_state.dart';
import 'widgets/firebase_status_widget.dart';


class PreJoinScreen extends StatefulWidget {
  const PreJoinScreen({super.key});

  @override
  State<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends State<PreJoinScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _channelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _channelController.dispose();
    super.dispose();
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
      body: BlocProvider(
        create: (context) => PreJoinCubit()..initialize(),
        child: BlocConsumer<PreJoinCubit, PreJoinState>(
          listener: (context, state) {
            if (state.status == RequestState.done) {
              // Navigate to live stream
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveStreamScreen(
                    channelName: state.channelName!,
                    userName: state.userName!,
                    isHost: state.isHost,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Firebase Status Indicator
                      FirebaseStatusWidget(
                        status: state.firebaseStatus,
                        onRetry: () => context
                            .read<PreJoinCubit>()
                            .retryFirebaseConnection(),
                      ),

                      // App Header
                      const AppHeaderWidget(),

                      const SizedBox(height: 40),

                      // Name Input
                      AppInput(
                        controller: _nameController,
                        hintText: 'Enter your display name',
                        labelText: 'Your Name',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Channel Input
                      AppInput(
                        controller: _channelController,
                        hintText: 'Enter or create channel name',
                        labelText: 'Channel Name',
                        prefixIcon: const Icon(Icons.tv, color: Colors.grey),
                      ),

                      const SizedBox(height: 30),

                      // Error Message
                      if (state.hasError && state.errorMessage != null)
                        CustomErrorWidget(
                          message: state.errorMessage!,
                          onRetry: () =>
                              context.read<PreJoinCubit>().clearError(),
                        ),

                      // Channel Status Indicator
                      if (state.channelStatus == ChannelCheckStatus.checking)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Checking channel availability...",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),

                      // Join Button
                      ButtonWidget(
                        getButtonText(state),
                        onPressed: state.canJoinChannel
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  context
                                      .read<PreJoinCubit>()
                                      .checkChannelAndJoin(
                                        _channelController.text,
                                        _nameController.text,
                                      );
                                }
                              }
                            : null,
                        loading: state.isLoading,
                        backgroundColor: state.canJoinChannel
                            ? Colors.red
                            : Colors.grey,
                      ),

                      const SizedBox(height: 20),

                      if (state.isFirebaseConnected)
                        const Text(
                          'If the channel doesn\'t exist, you\'ll become the host.\nOtherwise, you\'ll join as a guest.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String getButtonText(PreJoinState state) {
    if (state.isLoading) {
      switch (state.channelStatus) {
        case ChannelCheckStatus.checking:
          return 'Checking Channel...';
        default:
          return 'Joining...';
      }
    }

    if (!state.isFirebaseConnected) {
      return 'Connecting...';
    }

    return 'Join Stream';
  }
}
