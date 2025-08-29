# 🎥 QTech Live Streaming App

A feature-rich Flutter live streaming application with real-time video/audio broadcasting, interactive reactions, and Firebase integration. Built with clean architecture principles and BLoC state management.

## 📱 Demo Video

https://github.com/YoussefAbdelmonem/qtech-task/blob/master/video_record/record.mov


## ✨ Key Features

### 🎯 **Core Streaming Features**
- **Live Video Broadcasting** - Real-time video streaming with Agora SDK
- **Host-Guest System** - Automatic host assignment for channel creators
- **Multi-Platform Support** - iOS and Android compatibility
- **Real-time Audio/Video** - High-quality streaming with low latency

### 🎭 **Interactive Elements**
- **Live Reactions** - 7 emoji reactions (❤️👍😂😮😢👏🔥) with animations
- **Viewer Counter** - Real-time viewer count display
- **Guest Management** - Host can see all connected viewers
- **Channel System** - Create or join streams by channel name

### 🎛️ **Stream Controls**
- **Audio Controls** - Mute/unmute microphone
- **Video Controls** - Camera on/off toggle
- **Camera Switching** - Front/rear camera toggle
- **Stream Management** - Pause/resume streaming

### 🔄 **App Lifecycle Management**
- **Background Handling** - Auto-pause when app goes to background
- **Graceful Reconnection** - Smart reconnection on app resume
- **Exit Confirmation** - Prevents accidental stream termination
- **Resource Cleanup** - Proper cleanup on app termination

## 🏗️ Project Architecture

Built with **Clean Architecture** and **BLoC Pattern** for maintainable, scalable code.

```
lib/
├── core/                           # Shared core functionality
│   ├── config/
│   │   └── env_config.dart         # Environment configuration
│   ├── services/
│   │   ├── agora_service.dart      # Agora SDK integration
│   │   └── firebase_service.dart   # Firebase service layer
│   ├── utils/
│   │   └── constant.dart           # App constants & configs
│   └── widgets/                    # Reusable UI components
│       ├── app_input_widget.dart   # Custom input field
│       ├── button_widget.dart      # Custom button component
│       ├── custom_loading.dart     # Loading indicator
│       └── error_widget.dart       # Error display widget
│
├── features/                       # Feature-based modules
│   ├── pre_join_live/             # Pre-join functionality
│   │   ├── cubit/
│   │   │   ├── pre_join_cubit.dart # Pre-join business logic
│   │   │   └── pre_join_state.dart # Pre-join states with enums
│   │   ├── widgets/               # Pre-join specific widgets
│   │   │   ├── app_header_widget.dart
│   │   │   ├── error_display_widget.dart
│   │   │   └── firebase_status_widget.dart
│   │   └── prejoin_live_screen.dart # Pre-join screen UI
│   │
│   └── live_stream/               # Live streaming functionality
│       ├── cubit/
│       │   ├── live_stream_cubit.dart      # Main streaming logic
│       │   ├── live_stream_state.dart      # Streaming states
│       │   └── reaction_animation_cubit.dart # Reaction animations
│       ├── models/
│       │   ├── reaction_model.dart         # Reaction data model
│       │   └── stream_state_model.dart     # Stream state model
│       ├── widgets/                        # Live stream components
│       │   ├── guest_list_widget.dart      # Guest list display
│       │   ├── live_view.dart              # Main live view
│       │   ├── paused_video_widget.dart    # Pause indicator
│       │   ├── reactions_animation_widget.dart # Reaction animations
│       │   └── video_view_widget.dart      # Video display widget
│       └── live_stream_screen.dart         # Live stream entry point
│
├── firebase_options.dart           # Firebase configuration
└── main.dart                      # App entry point
```


## 🚀 Quick Start Guide


### 1. Clone & Setup
```bash
git clone https://github.com/YoussefAbdelmonem/qtech-task.git
cd qtech_task
flutter pub get
```



## 📖 User Guide

### 🎬 Creating a Live Stream (Host)
1. **Launch App** → Enter display name
2. **Create Channel** → Enter unique channel name
3. **Auto Host Mode** → You become the host automatically
4. **Stream Controls** → Use bottom controls to manage stream
5. **End Stream** → Confirmation dialog prevents accidental closure

### 👥 Joining as Viewer (Guest)
1. **Launch App** → Enter display name
2. **Join Channel** → Enter existing channel name
3. **Guest Mode** → Join as viewer automatically
4. **Send Reactions** → Tap emoji buttons to react
5. **Leave Stream** → Tap back or logout button

### 🎛️ Host Controls
| Control | Function | Icon |
|---------|----------|------|
| **Microphone** | Toggle audio on/off | 🎤 |
| **Camera** | Toggle video on/off | 📹 |
| **Switch Camera** | Front/back camera | 🔄 |

### 🎭 Available Reactions
| Emoji | Meaning | Usage |
|-------|---------|-------|
| ❤️ | Love/Heart | Show love for content |
| 👍 | Like/Thumbs up | Approve/agree |
| 😂 | Laugh | Content is funny |
| 😮 | Surprise | Amazed/shocked |
| 😢 | Sad | Emotional/touching |
| 👏 | Applause | Great performance |
| 🔥 | Fire | Awesome/cool |

## 🎯 Core Features Deep Dive

### Auto Host Detection System
```dart
// Smart host assignment logic
final snapshot = await channelRef.get();
if (!snapshot.exists) {
  // First user becomes host
  isHost = true;
  await channelRef.set({
    'host': {
      'name': userName,
      'joinedAt': ServerValue.timestamp,
      'isActive': true,
    },
    'createdAt': ServerValue.timestamp,
  });
} else {
  // Subsequent users join as guests
  isHost = false;
  await addUserAsGuest(userName);
}
```

### Real-time Reaction System
```dart
// Firebase real-time reaction streaming
Stream<Reaction> getReactionsStream(String channelName) {
  return FirebaseDatabase.instance
      .ref()
      .child('streams/$channelName/reactions')
      .orderByChild('timestamp')
      .limitToLast(20)
      .onChildAdded
      .map((event) => Reaction.fromSnapshot(event.snapshot));
}
```

### App Lifecycle Management
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  final cubit = context.read<LiveStreamCubit>();
  switch (state) {
    case AppLifecycleState.paused:
      if (widget.isHost) cubit.pauseStreaming();
      break;
    case AppLifecycleState.resumed:
      if (widget.isHost) cubit.resumeStreaming();
      break;
    case AppLifecycleState.detached:
      cubit.leaveStream();
      break;
  }
}
```




## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Supported | API 21+ required |
| **iOS** | ✅ Supported | iOS 11+ required |



## 📺 Channel Information

### Default Channel Configuration
- **Channel Name**: `Qtech` (Default recommended channel for testing)
- **Channel Creation**: Automatic when first user joins
- **Host Assignment**: First user to join becomes the host
- **Guest Limit**: No limit on concurrent viewers

### Recommended Testing Flow
1. **Host Setup**: Join channel `Qtech` as first user
2. **Guest Testing**: Have others join the same `Qtech` channel
3. **Feature Testing**: Test reactions, controls, and lifecycle management

---

## 🚀 Future Improvements & Roadmap

Given more development time, here are the planned enhancements:

### 🧪 **Enhanced Testing & Quality Assurance**
- **Stress Testing** - Test with multiple concurrent users (10+, 50+, 100+)
- **Network Scenarios** - Test under poor network conditions
- **Device Compatibility** - Test across various Android/iOS devices
- **Edge Cases** - Handle unexpected disconnections and reconnections
- **Performance Benchmarks** - Measure frame rates, latency, and resource usage

### 🎨 **User Experience Improvements**
- **Enhanced UI/UX** - More polished design with custom themes
- **Onboarding Flow** - Interactive tutorial for new users
- **Accessibility** - Screen reader support and keyboard navigation
- **Animations** - Smooth transitions and micro-interactions
- **Dark/Light Mode** - Theme switching capability
- **Custom Reactions** - Allow users to upload custom reaction emojis

### 🔍 **Performance & Memory Optimization**

### 🔐 **Enhanced Security Implementation**


### 🛡️ **Security & Privacy Enhancements**

#### **Environment Security** 
- ⏳ **Environment Variables** - Sensitive credentials in `.env` files
- ⏳ **Token Rotation** - Automatic Agora token refresh
- ⏳ **API Rate Limiting** - Prevent spam and abuse
- ⏳ **Input Sanitization** - Prevent injection attacks

#### **Firebase Security Rules** 


### 🌐 **Scalability Improvements** 
- **CDN Integration** - Distribute video streams globally
- **Load Balancing** - Handle thousands of concurrent users
- **Microservices** - Split backend into scalable services
- **Caching Strategy** - Redis for session management
- **Database Optimization** - Partitioning for large-scale data

### 🔧 **Development Tools** 
- **Automated Testing** - Unit, widget, and integration tests
- **CI/CD Pipeline** - Automated build and deployment
- **Code Coverage** - Maintain 80%+ test coverage
- **Performance Profiling** - Automated performance regression testing
- **Crash Reporting** - Firebase Crashlytics integration



## 🧪 Testing Scenarios

### Recommended Test Cases
1. **Single User Flow**
   - Create channel `Qtech` as host it will only be available for the next 24 houres 
   - if the time pass you can cannot with me on linkedIn and i will make a new channel which i will be updating agora token and send you the channel name 
   - Test all controls (mic, camera, switch)
   - Background/foreground app lifecycle

2. **Multi-User Flow**
   - Host creates `Qtech` channel
   - Multiple guests join simultaneously
   - Test reactions from all users
   - Host leaves, verify cleanup

3. **Edge Cases**
   - Poor network conditions
   - App termination during stream
   - Multiple rapid reactions
   - Very long channel/user names

4. **Performance Testing**
   - Memory usage during 30+ minute streams
   - CPU usage with 10+ concurrent viewers
   - Battery consumption analysis
   - Frame rate consistency

---
## 🚀 Performance Optimizations

### Implemented Optimizations
- **Lazy Loading** - Widgets load only when needed
- **Stream Disposal** - Proper stream cleanup
- **Memory Management** - Automatic resource cleanup
- **Background Optimization** - Pause streaming when not active



## 👨‍💻 Developer

**Youssef AbdElmonem**
- 📧 Email: youssefabdelmonem2000@gmail.com
- 🐙 GitHub: [@Youssef Abdelmonem](https://github.com/YoussefAbdelmonem)
- 💼 LinkedIn: [Youssef Abdelmonem](https://www.linkedin.com/in/youssef-abdelmonem-56a3bb1a2/)

## 📊 Project Stats

- **Lines of Code**: ~2,500+
- **Features**: 15+ core features
- **Architecture**: Clean Architecture + BLoC
- **Platform**: Cross-platform (iOS/Android)
- **Backend**: Firebase + Agora

---

## 🎬 Screenshots

| Pre-Join Screen | Live Stream Host | Live Stream Guest | Reactions |
|-----------------|------------------|-------------------|-----------|
| ![Pre-join](https://github.com/YoussefAbdelmonem/qtech-task/blob/master/screenshots/join_live_stream.png) | ![Host View](https://github.com/YoussefAbdelmonem/qtech-task/blob/master/screenshots/host_view.png) | ![Guest View](https://github.com/YoussefAbdelmonem/qtech-task/blob/master/screenshots/guest_view.png) | ![Paused App](https://github.com/YoussefAbdelmonem/qtech-task/blob/master/screenshots/paused_app.png) |


---

## 🎬 Screenshots of Dashboard

| Agora DashBoard |
|-----------------|
| ![Agora](https://github.com/YoussefAbdelmonem/qtech-task/blob/master/screenshots/agora_dashboard.png) 


| Firebase real-time  database |
|-----------------|
| ![Firebase](https://github.com/YoussefAbdelmonem/qtech-task/blob/master/screenshots/firebase_realtime_database.png) 


---



**Built with ❤️ using Flutter & Firebase**

