# BankFlow - Mobile Banking Application

<p align="center">
  <strong>A modern mobile banking solution built with Flutter and Supabase</strong>
</p>

---

## Authors

**Georgio Elias** & **Lucien Karam**

---

## Overview

BankFlow is a full-featured mobile banking application that demonstrates real-world banking functionality. Built with Flutter for cross-platform compatibility and Supabase for backend services, the app provides a seamless user experience for managing finances, transferring money, and tracking transactions.

---

## Features

### Authentication
- Secure email and password registration
- User login with session persistence
- Automatic session management

### Money Transfers
- Send money to contacts instantly
- Transfer by email address
- Real-time balance updates
- Transaction confirmation

### Transaction History
- Complete activity log
- Incoming and outgoing transactions
- Visual transaction indicators
- Time-based filtering

### Card Management
- Add Visa and Mastercard cards
- Visual card carousel display
- Set primary card
- Remove cards

### Financial Statistics
- Income and expense tracking
- Weekly, monthly, and yearly views
- Spending by category breakdown
- Visual charts and graphs

### Account Management
- View profile information
- Check account balance
- Refresh account data
- Secure logout

---

## Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **FL Chart** - Data visualization

### Backend
- **Supabase** - Backend-as-a-Service
- **PostgreSQL** - Database
- **Row Level Security** - Data protection

---

## Database Structure

The application uses four main tables:

| Table | Purpose |
|-------|---------|
| **users** | User profiles, balances, and account information |
| **transactions** | All money transfers, deposits, and payments |
| **cards** | Linked Visa and Mastercard cards |
| **notifications** | User alerts and transaction notifications |

All tables are protected with Row Level Security ensuring users can only access their own data.

---

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── pages/                 # All app screens
│   ├── auth/              # Login and registration
│   ├── home_page.dart     # Main dashboard
│   ├── wallet_page.dart   # Card management
│   ├── transfer_page.dart # Money transfers
│   ├── statistics_page.dart
│   └── account_page.dart
├── providers/             # State management
├── services/              # Supabase integration
├── theme/                 # Colors and styling
└── widgets/               # Reusable components
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Supabase account

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Supabase credentials in `lib/services/supabase_service.dart`
4. Run the database setup scripts from the `supabase/` folder
5. Run `flutter run` to start the app

### Test Accounts

| Email | Password |
|-------|----------|
| georgio@test.com | test123 |
| sarah@test.com | test123 |
| mike@test.com | test123 |

---

## Key Highlights

- **Real-time Updates** - Balances refresh instantly after transactions
- **Email Transfers** - Send money to anyone by their email address
- **Secure by Design** - Row Level Security protects all user data
- **Cross-platform** - Runs on iOS, Android, and Web
- **Modern UI** - Clean Material Design 3 interface

---

## Future Enhancements

- Biometric authentication
- Push notifications
- QR code payments
- Recurring transfers
- Multi-currency support

---

## Repository

**GitHub:** [github.com/georgioelias/BankFlow](https://github.com/georgioelias/BankFlow)

---

<p align="center">
  Built with Flutter & Supabase
</p>
