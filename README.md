# StudyMate - Educational Platform

## Overview

**StudyMate** is an educational platform where users can register as either students or teachers. The platform facilitates content sharing, learning, and interaction between students and teachers through video lessons, playlists, subscriptions, and performance tracking.

### Features

- **Teacher Features**:  
  - Upload educational videos and organize them into playlists.
  - Track video performance metrics, such as views and student interactions.
  - Access detailed profiles to manage content and view statistics.

- **Student Features**:  
  - Watch a limited number of free videos.
  - Purchase subscriptions for full access to premium content.
  - Access a personal profile to view billing history, watched videos, and remaining subscription time.

- **Subscription System**:  
  - Students can purchase subscriptions for additional content beyond the free limit.
  - Integrated billing history and payment tracking.

- **Live Chat System**:  
  - Real-time communication between students and teachers using WebSockets.
  - Teachers can interact with students directly and answer questions or provide guidance.

- **Video Playback and Controls**:  
  - Styled video player with playback controls.
  - Organized course structure to enhance learning experiences.

### Tech Stack

- **Frontend**:  
  Flutter for mobile applications (Android/iOS) and web support.

- **Backend**:  
  - Node.js with Express.js for the core application logic and API management.
  - MongoDB for storing user, video, and subscription data.

- **Payment Integration**:  
  - Stripe integration for handling subscriptions and payments.

- **WebSockets**:  
  - Live chat feature powered by WebSockets for real-time messaging.

### Setup and Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/DrLivesey-Shura/StudyMate.git
   cd StudyMate
   ```

2. Install dependencies for the backend:
   ```bash
   cd server
   npm install
   ```

3. Install dependencies for the Flutter app:
   ```bash
   cd client
   flutter pub get
   ```

4. Set up environment variables:
   - MongoDB connection string
   - Stripe API keys
   - JWT secret for authentication

5. Start the servers:
   - **Backend**:
     ```bash
     cd server
     npm start
     ```

6. Start the Flutter app:
   ```bash
   flutter run
   ```

### Contributing

Contributions are welcome! Feel free to submit issues, feature requests, or pull requests.
