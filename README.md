# Wigu - Career Insight Engine

A reflective Flutter application for career exploration and development, built with Australian English in mind.

## Overview

Wigu is a career insight engine designed to help individuals explore their career paths through thoughtful reflection and structured exploration. The app features a calm, reflective interface with a black background and two muted tones, promoting deep thinking about career goals and aspirations.

## Features

### Core Functionality
- **Career Exploration Sessions**: Create and manage multiple career exploration journeys
- **Domain-Based Exploration**: Explore eight career domains:
  - Technical & Engineering
  - Leadership & Management
  - Creative & Design
  - Analytical & Research
  - Social & Communication
  - Entrepreneurial & Business
  - Traditional & Service
  - Investigative & Academic

- **Reflective Responses**: Capture detailed responses to career-related questions
- **Insight Generation**: Generate and store insights based on exploration patterns
- **Progress Tracking**: Monitor completion across different career domains
- **Session Management**: Create, rename, and manage multiple exploration sessions

### Technical Features
- **Local Data Persistence**: Uses Hive for secure local storage
- **State Management**: Riverpod for reactive state management
- **Production-Ready**: Comprehensive error handling and logging
- **Australian English**: All text content optimised for Australian English
- **Accessible Design**: High contrast theme with thoughtful colour choices

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models with Hive adapters
│   ├── career_session.dart   # Career exploration session model
│   ├── career_response.dart  # User response model
│   └── career_insight.dart   # Generated insight model
├── services/                 # Business logic services
│   └── career_persistence_service.dart  # Local data persistence
├── providers/                # State management
│   └── career_provider.dart  # Career-related state providers
├── screens/                  # App screens
│   ├── splash_screen.dart    # Initial loading screen
│   └── career_home_screen.dart  # Main home screen
├── widgets/                  # Reusable UI components
│   ├── session_card.dart     # Session overview card
│   ├── domain_overview_card.dart  # Career domain card
│   └── quick_reflection_card.dart  # Quick reflection widget
└── utils/                    # Utilities and helpers
    ├── theme.dart            # App theme and colours
    ├── logger.dart           # Centralised logging
    └── error_handler.dart    # Error handling utilities
```

## Getting Started

### Prerequisites
- Flutter 3.5.3 or higher
- Dart SDK
- iOS/Android development environment (for mobile)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters:
   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the application:
   ```bash
   flutter run
   ```

### Development

To regenerate Hive adapters after model changes:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

To run tests:
```bash
flutter test
```

To analyse code quality:
```bash
flutter analyze
```
