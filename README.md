# SwiftUI Client App for Gr4vy Swift SDK

<div align="left">
    <img alt="Platforms" src="https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=for-the-badge">
    <img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/gr4vy/gr4vy-swift-client-app/ios.yml?branch=main&style=for-the-badge">
</div>

## Summary

A SwiftUI sample application demonstrating integration with the [Gr4vy Swift SDK](https://github.com/gr4vy/gr4vy-swift). This app provides a testing interface for the SDK endpoints with persistent configuration management, including comprehensive 3DS authentication support with customizable UI themes. A [UIKit client app](https://github.com/gr4vy/gr4vy-uikit-client-app) is also available.

- [Summary](#summary)
- [Architecture](#architecture)
- [App Structure](#app-structure)
  - [Tab Navigation](#tab-navigation)
  - [API Screens (4 Endpoints)](#api-screens-4-endpoints)
- [Admin Panel](#admin-panel)
  - [Core Configuration](#core-configuration)
  - [How Configuration Works](#how-configuration-works)
- [Key Features](#key-features)
  - [3DS Authentication Support](#3ds-authentication-support)
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
  - [3DS UI Customization](#3ds-ui-customization)
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

4. **Tokenize** - `PUT /tokenize`
   - Tokenize payment methods (card or stored payment method ID)
   - 3DS authentication support
   - Test card selection for frictionless and challenge flows
   - Customizable 3DS UI themes (light/dark mode support)
   - SDK timeout configuration
   - Secure payment method storage

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

### 3DS Authentication Support
The Tokenize screen includes comprehensive 3DS authentication features:
- **Authentication Toggle**: Enable/disable 3DS authentication
- **Test Cards**: Pre-configured test cards for both flows:
  - **Frictionless Flow**: Cards that complete authentication without challenge (Visa, Mastercard, Amex, Diners, JCB)
  - **Challenge Flow**: Cards that trigger authentication challenge screens (Visa, Mastercard, Amex, Diners, JCB)
- **UI Customization**: Three built-in themes for 3DS challenge screens:
  - Red/Blue theme
  - Orange/Purple theme
  - Green/Yellow theme
  - Each theme supports both light and dark modes
- **Timeout Configuration**: Configurable SDK max timeout (in seconds)
- **Enhanced Response Data**: Returns authentication details including:
  - `tokenized`: Whether the payment method was successfully tokenized
  - `authentication.attempted`: Whether 3DS authentication was attempted
  - `authentication.user_cancelled`: Whether the user cancelled the authentication
  - `authentication.timed_out`: Whether the authentication timed out
  - `authentication.type`: The type of authentication performed
  - `authentication.transaction_status`: The final status of the 3DS transaction

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
- SDK error type handling including 3DS-specific errors:
  - `threeDSError`: 3DS authentication failures
  - `uiContextError`: UI context-related issues
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
- **For Tokenize**: Select test cards for 3DS testing (frictionless or challenge flows), choose a theme, and configure authentication settings
- Tap the action button (GET/POST/PUT) to make requests
- View responses with authentication details (for 3DS-enabled requests) 

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

### 3DS UI Customization

The app demonstrates comprehensive 3DS UI theming capabilities:

```swift
private func buildRedBlueTheme() -> Gr4vyThreeDSUiCustomizationMap {
    let light = Gr4vyThreeDSUiCustomization(
        label: .init(
            textFontName: "HelveticaNeue",
            textFontSize: 16,
            textColorHex: "#1c1c1e",
            headingTextFontName: "HelveticaNeue-Bold",
            headingTextFontSize: 24,
            headingTextColorHex: "#0a0a0a"
        ),
        toolbar: .init(
            textFontName: "AvenirNext-DemiBold",
            textFontSize: 17,
            textColorHex: "#ffffff",
            backgroundColorHex: "#007aff",
            headerText: "Secure Checkout",
            buttonText: "Cancel"
        ),
        // ... additional customizations
    )
    // Separate dark mode customization
    let dark = Gr4vyThreeDSUiCustomization(...)
    
    return Gr4vyThreeDSUiCustomizationMap(default: light, dark: dark)
}
```

Customizable elements include:
- Labels (text font, size, color for both body and heading)
- Toolbar (font, colors, button text, header text)
- Text boxes (font, colors, border width, corner radius)
- View backgrounds (challenge and progress views)
- Buttons (submit, continue, next, resend, etc. - each with individual styling)

### SDK Integration

Basic SDK initialization:
```swift
let server: Gr4vyServer = serverEnvironment == "production" ? .production : .sandbox
let timeoutInterval = TimeInterval(Double(timeout) ?? 30.0)

guard let gr4vy = try? Gr4vy(
    gr4vyId: gr4vyID,
    token: trimmedToken, 
    server: server,
    timeout: timeoutInterval,
    debugMode: true
) else {
    errorMessage = "Failed to configure Gr4vy SDK"
    return
}
```

Tokenize with 3DS authentication:
```swift
gr4vy.tokenize(
    checkoutSessionId: checkoutSessionId,
    cardData: cardData,
    sdkMaxTimeoutMinutes: 5,
    authenticate: true,
    uiCustomization: customTheme
) { result in
    switch result {
    case .success(let tokenizeResult):
        // Access tokenizeResult.tokenized and tokenizeResult.authentication
    case .failure(let error):
        // Handle error
    }
}
```

## Requirements

- iOS 16.0+
- Xcode 16.0+
- Swift 5.7+
- Gr4vy Swift SDK
