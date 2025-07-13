# Smart Diary

A Flutter app for creating and sharing diary entries with family and friends. Features include real-time collaboration, voice-to-text input, Markdown formatting, and mood tracking.

## Features

- 🔐 **Authentication**: Email/password sign-up and login
- 📚 **Shared Diaries**: Create or join diaries with family and friends
- ✍️ **Rich Text Entries**: Markdown support for formatted diary entries
- 🎤 **Voice-to-Text**: Convert speech to text for easy entry creation
- 😊 **Mood Tracking**: Tag entries with your current mood
- 🏷️ **Tags & Filtering**: Organize and filter entries with custom tags
- 🔄 **Real-time Sync**: See updates from other diary members instantly
- 📱 **Offline Support**: Access your diaries even without internet

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project
- Android Studio/VS Code with Flutter extensions

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "smart-diary"

2. **Configure Authentication**
   - Enable Email/Password authentication in Firebase Console
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"

3. **Set up Firestore Database**
   - Create a Firestore database in test mode
   - Deploy the security rules from `firestore.rules`

4. **Add Your Apps**
   - **Android**: Add Android app with package name `com.example.echo`
     - Download `google-services.json` and place in `android/app/`
   - **iOS**: Add iOS app with bundle ID `com.example.echo`
     - Download `GoogleService-Info.plist` and place in `ios/Runner/`

5. **Update Firebase Configuration**
   - Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase config
   - You can get these values from your Firebase project settings

### Installation

1. **Clone and Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/           # Data models
│   ├── user_model.dart
│   ├── diary_model.dart
│   └── entry_model.dart
├── providers/        # State management
│   ├── auth_provider.dart
│   └── diary_provider.dart
├── services/         # Business logic
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/          # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── diary/
│   │   ├── diary_screen.dart
│   │   └── entry_editor_screen.dart
│   └── home_screen.dart
├── firebase_options.dart
└── main.dart
```

## Usage

### Creating a Diary

1. Sign up or log in to your account
2. Tap the "+" button on the home screen
3. Enter a title and optional description
4. Start adding entries!

### Joining a Diary

1. Ask a diary member to share the diary ID with you
2. Tap the group icon on the home screen
3. Enter the diary ID and join

### Writing Entries

1. Open a diary and tap the "+" button
2. Write your entry using Markdown formatting:
   - `**bold text**`
   - `*italic text*`
   - `# Heading`
   - `- List item`
3. Use the microphone button for voice input
4. Add tags and select your mood
5. Preview your entry before saving

### Voice Input

1. Tap the microphone button while writing an entry
2. Speak clearly into your device
3. The text will be automatically added to your entry

## Firestore Security Rules

The app uses these security rules to protect user data:

- Users can only access diaries where they are members
- Users can only edit/delete their own entries
- All operations require authentication

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

If you encounter any issues:
1. Check the Firebase configuration
2. Ensure all permissions are granted (microphone for voice input)
3. Verify Firestore security rules are deployed
4. Check the console for error messages

Happy diary writing! 📖✨
