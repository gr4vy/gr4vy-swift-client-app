# SwiftUI Client App for Gr4vy Swift SDK

<div align="left">
    <img alt="Platforms" src="https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=for-the-badge">
    <img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/gr4vy/gr4vy-swift-client-app/ios.yml?branch=main&style=for-the-badge">
</div>

## Summary

A SwiftUI sample application demonstrating integration with the [Gr4vy Swift SDK](https://github.com/gr4vy/gr4vy-swift). This app provides a testing interface for the SDK endpoints with persistent configuration management. A seperate client app for [UIKit](https://github.com/gr4vy/gr4vy-uikit-client-app) is also available.

- [Summary](#summary)
- [Architecture](#architecture)
- [App Structure](#app-structure)
  - [Tab Navigation](#tab-navigation)
  - [API Screens (4 Endpoints)](#api-screens-4-endpoints)
- [Admin Panel](#admin-panel)
  - [Core Configuration](#core-configuration)
  - [How Configuration Works](#how-configuration-works)
- [Key Features](#key-features)
  - [Async/Await Implementation](#asyncawait-implementation)
  - [Error Handling](#error-handling)
  - [Response Handling](#response-handling)
  - [Data Persistence](#data-persistence)
- [Setup Instructions](#setup-instructions)
  - [1. Configure Admin Settings](#1-configure-admin-settings)
  - [2. Test API Endpoints](#2-test-api-endpoints)
  - [3. Development Usage](#3-development-usage)
- [Customization](#customization)
  - [Adding New Endpoints](#adding-new-endpoints)
  - [Modifying UI](#modifying-ui)
  - [SDK Integration](#sdk-integration)
- [Requirements](#requirements)


## Architecture

The app uses modern SwiftUI patterns with async/await for API calls calling the Gr4vy Swift SDK directly and `@AppStorage` for persistent configuration across app sessions.

## App Structure

### Tab Navigation
- **Home Tab**: Main navigation to API endpoint screens
- **Admin Tab**: Configuration management panel

### API Screens (4 Endpoints)

1. **Payment Options** - `POST /payment-options`
   - Configure metadata, country, currency, amount, locale, and cart items
   - Dynamic metadata key-value pairs
   - Cart items with detailed product information

2. **Card Details** - `GET /card-details`  
   - Test card BIN lookup and payment method validation
   - Supports intent, subsequent payments, and merchant-initiated transactions

3. **Payment Methods** - `GET /buyers/{buyer_id}/payment-methods`
   - Retrieve stored payment methods for buyers
   - Sorting and filtering options
   - Buyer identification by ID or external identifier

4. **Fields (Tokenize)** - `PUT /tokenize`
   - Tokenize payment methods (card, click-to-pay, or stored payment method ID)
   - Secure payment method storage
   - Multiple payment method types supported

## Admin Panel

The Admin tab provides centralized configuration for all API calls:

### Core Configuration
- **gr4vyId** - Your Gr4vy merchant identifier (required)
- **token** - API authentication token (required)  
- **server** - Environment selection (sandbox/production)
- **timeout** - Request timeout in seconds (optional)
- **merchantId** - Used in payment options requests

### How Configuration Works
- All settings persist across app restarts using `@AppStorage`
- Empty timeout field uses SDK default timeout
- Configuration is shared across all API screens
- Switch between sandbox and production environments instantly

## Key Features

### Async/Await Implementation
All API calls use modern Swift concurrency:
```swift
Button("GET") {
    Task {
        await sendRequest()
    }
}
```

### Error Handling
- SDK error type handling
- Network error detection and visual messages
- HTTP status code display with detailed error responses
- Tappable error messages show full JSON error details

### Response Handling
- Pretty-printed JSON responses
- Copy/share functionality for debugging
- Separate navigation for success and error responses

### Data Persistence
- Form data persists between app launches
- Admin settings stored securely in UserDefaults
- Complex data structures (metadata, cart items) serialized automatically

## Setup Instructions

### 1. Configure Admin Settings
- Open the **Admin** tab
- Enter your `gr4vyId` and optional `token`
- Select environment 
- Optionally set custom timeout

### 2. Test API Endpoints
- Navigate through the **Home** tab to each API screen
- Fill in required fields (marked with validation)
- Tap the action button (GET/POST/PUT) to make requests
- View responses 

### 3. Development Usage
- Use as reference implementation for SDK integration
- Test various parameter combinations
- Debug API responses with detailed error information

## Customization

### Adding New Endpoints
1. Create new view following existing patterns
2. Add admin settings storage with `@AppStorage`
3. Implement async request function with error handling
4. Add navigation link in `HomeView.swift`

### Modifying UI
- All views use standard SwiftUI form patterns
- Consistent styling with `ButtonView` component
- Error states handled with red background styling
- Loading states with `ProgressView` indicators

### SDK Integration

```swift
let server: Gr4vyServer = serverEnvironment == "production" ? .production : .sandbox
let timeoutInterval = TimeInterval(Double(timeout) ?? 30.0)

guard let gr4vy = try? Gr4vy(
    gr4vyId: gr4vyID,
    token: trimmedToken, 
    server: server,
    timeout: timeoutInterval
) else {
    errorMessage = "Failed to configure Gr4vy SDK"
    return
}
```

## Requirements

- iOS 16.0+
- Xcode 16.0+
- Swift 5.7+
- Gr4vy Swift SDK
