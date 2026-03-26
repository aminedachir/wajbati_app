# وجبتي DZ — Wajbati DZ
## Food Delivery App for Algeria

### Brand Colors
- **Red (Primary):** #E8231A  
- **Blue (Secondary):** #1B4FA8

---

## Project Structure

```
wajbati_dz/
├── lib/
│   ├── main.dart                        ← App entry point
│   ├── theme/
│   │   └── app_theme.dart               ← Brand colors, fonts, theme
│   ├── models/
│   │   ├── models.dart                  ← Restaurant, MenuItem, CartItem
│   │   └── providers.dart               ← CartProvider, FavoritesProvider
│   ├── widgets/
│   │   └── widgets.dart                 ← RestaurantCard, MenuItemTile, etc.
│   └── screens/
│       ├── splash_screen.dart           ← Animated splash
│       ├── home_screen.dart             ← Browse + search + categories
│       ├── restaurant_screen.dart       ← Menu + order
│       ├── cart_screen.dart             ← Cart + summary
│       ├── order_confirmation_screen.dart
│       └── other_screens.dart           ← Favorites, Orders, Profile
├── assets/
│   └── images/                          ← Place logo.png here
└── pubspec.yaml
```

---

## Setup in Android Studio

### 1. Open the project
```
File → Open → select the wajbati_dz folder
```

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Place the logo
Put the Wajbati DZ logo image as:
```
assets/images/logo.png
```

### 4. Run on Android emulator or device
```bash
flutter run
```

---

## Screens Overview

| Screen | Description |
|--------|-------------|
| Splash | Animated intro with brand logo |
| Home | Search, categories, restaurant cards, promo banner |
| Restaurant | Full menu with categories, add to cart |
| Cart | Items, quantity control, order summary |
| Confirmation | Success animation, ETA |
| Favorites | Saved restaurants |
| Orders | Order history with reorder |
| Profile | User info, addresses, settings |

---

## Next Steps to Add
- [ ] User login / registration (Firebase Auth)
- [ ] Real backend (Firebase Firestore / Supabase)
- [ ] Live order tracking with Google Maps
- [ ] Push notifications (FCM)
- [ ] Payment integration (CIB card / cash on delivery)
- [ ] Restaurant admin panel
- [ ] Arabic RTL full support
