# Wajbati DZ - Food Delivery App for Algeria 🍔🇩🇿

A modern, high-performance food delivery application built with **Flutter** and powered by **Appwrite**. Wajbati DZ provides a seamless experience for users to browse local Algerian restaurants, order their favorite meals, and track them in real-time.

## ✨ Key Features

- 👤 **Seamless Authentication**: Login, Sign up, and **Anonymous Guest Login** (persists session on the same device).
- 🏘️ **Location-Based Browsing**: Full support for **58 Algerian Wilayas** with a custom province selector.
- 🍱 **Smart Restaurant Discovery**: Filter by categories (Algerian, Pizza, Burger, etc.) and search by name or dish.
- 🛒 **Efficient Cart System**: Real-time quantity control, promo code support, and automatic calculation of subtotal/delivery fees.
- ✅ **Professional Checkout**: Choice between manual address entry or GPS-based location detection.
- 📦 **Order Tracking**: Visual "stepper" progress bar with estimated arrival, status updates, and courier contact details.
- ❤️ **Personalized Experience**: Sync favorites to the cloud, view order history, and toggle between **Light/Dark modes**.
- 🚀 **Modern UI**: Polished layout using Cairo Google Fonts and Lottie animations.

## 🛠️ Technology Stack

- **Frontend**: Flutter (v3.0+)
- **Backend**: Appwrite (Auth, Database, Storage)
- **State Management**: **Provider** (Clean, stable, and professional architecture)
- **Image Handling**: CachedNetworkImage for smooth performance.
- **Animations**: Lottie for a premium feel.

## 🔌 Setup & Configuration

### 1. Backend Credentials
Update `lib/utils/environment.dart` with your Appwrite project info:
- **Project ID**: `69c6e959001a8e4f9efa`
- **Database ID**: `69c710a6001785cc4162`

### 2. Required Appwrite Collections & Attributes
Ensure your database has the following attributes defined:

| Collection | Attributes (Keys) |
| --- | --- |
| **`restaurants`** | `name`, `nameAr`, `category`, `imageUrl`, `rating`, `reviewCount`, `deliveryTime`, `deliveryFee`, `isOpen`, `address`, `wilaya` |
| **`menu_items`** | `restaurantId`, `name`, `nameAr`, `description`, `price`, `category`, `imageUrl`, `isPopular` |
| **`orders`** | `userId`, `orderNumber`, `restaurantName`, `restaurantId`, `items` (string/json), `subtotal`, `deliveryFee`, `discount`, `total`, `status`, `createdAt` |
| **`favorites`** | `userId`, `restaurantId` |

### 3. Installation & App Icon
```bash
# Install dependencies
flutter pub get

# Generate App Launcher Icons
flutter pub run flutter_launcher_icons

# Run the app
flutter run
```

## 📦 Project Structure

```text
lib/
├── main.dart                # App entry, Routing & Provider setup
├── models/                  # AppOrder, Restaurant models & Provider logic
├── screens/                 # UI Screens (Home, Auth, Cart, Tracking, etc.)
├── theme/                   # AppTheme (Light/Dark configurations)
├── utils/                   # Appwrite Service, Environment & Initializer
└── widgets/                 # Reusable UI components (Cards, Chips, etc.)
```

---
**Wajbati DZ** - Bring the best of Algeria to your doorstep. 🚀
