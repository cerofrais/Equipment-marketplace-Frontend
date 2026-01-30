
# Project Blueprint: Equipverse

## Overview

Equipverse is a Flutter-based mobile application for an equipment rental marketplace. It connects customers who need to rent equipment with local vendors who can provide it. The app facilitates the entire rental process, from browsing equipment and submitting requests to receiving and accepting quotes from vendors.

## Style and Design

The application will follow modern Material Design principles to ensure a clean, intuitive, and aesthetically pleasing user experience.

*   **Colors:** The primary color will be a deep purple, creating a sense of trust and reliability. This will be complemented by a vibrant accent color for interactive elements.
*   **Typography:** We will use the `google_fonts` package to implement a clean and readable font scheme.
*   **Layout:** The layout will be spacious and visually balanced, with clear hierarchies for information.
*   **Iconography:** We will use Material Design icons to enhance usability and visual communication.

## Implemented Features

### Core
- **Environment Configuration:** The app uses a `.env` file to manage the backend API's base URL, allowing for easy switching between development and production environments.
- **Firebase Integration:** The project is connected to a Firebase project, with the web app configuration set up in `firebase_options.dart`.

### Authentication
- **OTP-Based Login:** Users can authenticate using their phone number via a one-time password (OTP) sent from the backend.
- **Secure Token Storage:** JWT access and refresh tokens are securely stored on the device using the `shared_preferences` package.
- **Session Management:** The app can check if a user is logged in and handle token refresh and logout.

### API Integration
- **`AuthService`:** A dedicated service at `lib/core/services/auth_service.dart` handles all authentication-related API calls (send OTP, verify OTP, logout).
- **`ApiService`:** A service at `lib/core/services/api_service.dart` is set up for general API interactions, starting with fetching equipment types.

### Data Models
- **`Equipment` Model:** A data model at `lib/core/models/equipment.dart` represents an equipment type, matching the structure of the backend API's response.

## Current Plan

The immediate next steps are to build out the core user interface and connect it to the services we've just created.

### 1. Create Rental Service
- **Action:** Create a `lib/core/services/rental_service.dart` file.
- **Purpose:** This service will encapsulate all API calls related to rental requests, such as creating a new request and fetching a user's request history.

### 2. Build the User Interface
- **Login Screen:** Create a simple UI for users to enter their phone number and the received OTP. This will be the entry point for unauthenticated users.
- **Equipment List Screen:** Design a screen that displays a list of available equipment types fetched from the backend. This will likely be the home screen for authenticated users.
- **Rental Request Screen:** Develop a form where users can select an equipment type, specify a date range, and provide their ZIP code to submit a new rental request.

### 3. Connect UI to Services
- **State Management:** Implement a state management solution (like `provider`) to manage the application's state and facilitate communication between the UI and the services.
- **Data Flow:** Wire up the UI components to call the appropriate service methods (e.g., the login button will call `AuthService.login`, and the equipment list will be populated by `ApiService.getEquipmentTypes`).
- **Error Handling:** Implement user-friendly error messages for failed API calls (e.g., "Invalid OTP," "Failed to load equipment").
