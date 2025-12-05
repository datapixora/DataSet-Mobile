# User Profile & Earnings Feature Implementation (M4)

## Overview
This document describes the implementation of the User Profile and Earnings tracking features for the DataSet Mobile app (Milestone 4).

## What Was Implemented

### 1. Data Models
**File**: `lib/features/profile/models/user.dart`

Created three model classes:

#### User Model
- Represents user profile and statistics
- Properties: id, email, fullName, role, createdAt, earnings stats, upload counts
- Helper properties:
  - `approvalRate`: Calculates percentage of approved uploads
  - `isAdmin`: Checks if user is admin
- Factory constructor for JSON deserialization

#### Transaction Model
- Represents financial transactions (earnings, withdrawals)
- Properties: id, userId, type, amount, status, description, timestamps
- Helper properties:
  - `isPending`, `isCompleted`: Status checks
  - `isEarning`, `isWithdrawal`: Type checks
- Supports linking to campaigns and uploads

#### EarningsStats Model
- Aggregated earnings and upload statistics
- Properties: totalEarnings, pendingEarnings, availableBalance, upload counts
- Includes list of recent transactions
- Helper property: `approvalRate`

### 2. User Service
**File**: `lib/features/profile/services/user_service.dart`

Comprehensive user management service:

#### Profile Management
- `getCurrentUser()` - Fetch authenticated user profile
- `updateProfile()` - Update user information

#### Earnings & Transactions
- `getEarningsStats()` - Get comprehensive earnings statistics
- `getTransactions()` - Fetch transaction history
- `requestWithdrawal()` - Request withdrawal (placeholder)

### 3. Profile Screen
**File**: `lib/features/profile/screens/profile_screen.dart`

Main profile dashboard with:

#### User Information Display
- Profile header with avatar (initial from name)
- Full name and email
- Role badge (User/Admin)
- Member since date

#### Statistics Cards
- Total earnings display
- Pending earnings display
- Color-coded visual hierarchy

#### Navigation Menu
- Earnings & Transactions navigation
- Upload History navigation
- Statistics popup dialog
- Settings placeholder
- Logout functionality

#### Features
- Pull-to-refresh
- Loading and error states
- Statistics dialog with detailed upload breakdown
- Secure logout with confirmation

### 4. Earnings Screen
**File**: `lib/features/profile/screens/earnings_screen.dart`

Comprehensive earnings dashboard:

#### Earnings Summary Card
- Total earnings (large, green)
- Pending earnings (orange)
- Available balance (blue)
- Withdraw button (conditional on balance)

#### Upload Statistics Card
- Total, approved, pending, rejected counts
- Color-coded stat columns
- Approval rate progress bar
- Visual progress indicator

#### Transactions List
- Recent transactions display
- Transaction type indicators (earning/withdrawal)
- Status badges (pending/completed)
- Amount display with +/- prefix
- Timestamp for each transaction
- Empty state for no transactions

#### Features
- Pull-to-refresh
- Withdrawal dialog (placeholder)
- Color-coded visual feedback
- Responsive layout

### 5. Upload History Screen
**File**: `lib/features/uploads/screens/upload_history_screen.dart`

Detailed upload tracking:

#### Summary Bar
- Total uploads count
- Approved uploads (green)
- Pending uploads (orange)
- Rejected uploads (red)
- Quick overview statistics

#### Upload Cards
- Status icons and badges
- Campaign ID display
- File key information
- Upload timestamp
- Approval/rejection dates
- Rejection reason display (if applicable)
- Color-coded status indicators

#### Filtering
- Filter by status (All/Pending/Approved/Rejected)
- Dropdown menu in app bar
- Dynamic list updates

#### Features
- Pull-to-refresh
- Empty state messaging
- Detailed rejection feedback
- Chronological display

### 6. Home Screen with Navigation
**File**: `lib/features/home/home_screen.dart`

Bottom navigation bar implementation:

#### Navigation Tabs
- Campaigns tab (campaign list)
- Profile tab (user profile)

#### Features
- Persistent navigation state
- Active tab highlighting
- Seamless tab switching

### 7. Auth Integration
**Files Updated**:
- `lib/features/auth/login_screen.dart`
- `lib/features/auth/signup_screen.dart`

Changes:
- Navigate to HomeScreen instead of CampaignListScreen
- Users land on campaigns tab by default
- Can navigate to profile via bottom nav

## Project Structure

```
lib/features/
├── auth/
│   ├── login_screen.dart           [UPDATED]
│   └── signup_screen.dart          [UPDATED]
├── home/
│   └── home_screen.dart            [NEW]
├── profile/                        [NEW]
│   ├── models/
│   │   └── user.dart
│   ├── services/
│   │   └── user_service.dart
│   └── screens/
│       ├── profile_screen.dart
│       └── earnings_screen.dart
└── uploads/
    └── screens/
        └── upload_history_screen.dart  [NEW]
```

## API Integration

The implementation uses the following backend endpoints:

### User Management
- **`GET /users/me`** - Get current user profile
- **`POST /users/me`** - Update user profile

### Earnings & Transactions
- **`GET /users/earnings`** - Get earnings statistics
- **`GET /users/transactions`** - Get transaction history
- **`POST /users/withdraw`** - Request withdrawal (placeholder)

### Uploads (existing)
- **`GET /uploads/me`** - Get user's uploads

## Features Summary

### Profile Screen
✅ User information display
✅ Earnings summary cards
✅ Upload statistics
✅ Navigation menu
✅ Statistics dialog
✅ Logout functionality
✅ Pull-to-refresh

### Earnings Screen
✅ Comprehensive earnings breakdown
✅ Upload statistics with progress bar
✅ Transaction history list
✅ Withdrawal dialog (placeholder)
✅ Color-coded visual hierarchy
✅ Status badges

### Upload History
✅ Upload list with status
✅ Filter by status
✅ Summary statistics bar
✅ Rejection reason display
✅ Chronological ordering
✅ Pull-to-refresh

### Navigation
✅ Bottom navigation bar
✅ Campaigns and Profile tabs
✅ Persistent navigation state
✅ Updated auth flow

## User Experience Flows

### Profile Flow
1. User navigates to Profile tab
2. Profile loads from `/users/me`
3. Displays user info and stats
4. Can navigate to:
   - Earnings & Transactions
   - Upload History
   - Statistics (dialog)
   - Settings (placeholder)
5. Can logout with confirmation

### Earnings Flow
1. User taps "Earnings & Transactions"
2. Loads earnings stats and transactions
3. Displays:
   - Total, pending, available earnings
   - Upload statistics with approval rate
   - Recent transactions
4. Can request withdrawal (if balance > 0)

### Upload History Flow
1. User taps "Upload History"
2. Loads all uploads from `/uploads/me`
3. Shows summary statistics
4. Displays uploads with:
   - Status badges
   - Approval/rejection dates
   - Rejection reasons
5. Can filter by status

## Testing

To test this implementation:

1. **Profile Screen**:
   ```bash
   - Login to app
   - Navigate to Profile tab
   - Verify user info displays
   - Check earnings cards
   - Test navigation to earnings/history
   - Test statistics dialog
   - Test logout
   ```

2. **Earnings Screen**:
   ```bash
   - Navigate from profile
   - Verify earnings summary
   - Check upload statistics
   - View transactions list
   - Test pull-to-refresh
   ```

3. **Upload History**:
   ```bash
   - Navigate from profile
   - View all uploads
   - Test status filter
   - Check rejection reasons
   - Verify summary bar
   ```

4. **Navigation**:
   ```bash
   - Login/signup
   - Verify lands on Campaigns tab
   - Switch to Profile tab
   - Switch back to Campaigns
   - Verify state persists
   ```

## Next Steps (Future Enhancements)

### Immediate Improvements:
1. **Profile Editing**
   - Edit name and email
   - Change password
   - Profile picture upload

2. **Withdrawal System**
   - Payment method selection
   - Account details input
   - Withdrawal history
   - Status tracking

3. **Settings Screen**
   - Notification preferences
   - Language selection
   - Theme toggle
   - Privacy settings

### Advanced Features:
4. **Analytics Dashboard**
   - Earnings charts
   - Upload trends
   - Performance metrics
   - Leaderboards

5. **Gamification**
   - User levels/badges
   - Achievements
   - Streaks
   - Challenges

6. **Notifications**
   - Upload status updates
   - Payment notifications
   - Campaign recommendations

## Notes

- All profile features require authentication
- Withdrawal is placeholder (needs backend implementation)
- Settings screen is placeholder
- Profile avatar uses first letter of name
- All monetary values display with 2 decimal places
- Dates formatted as DD/MM/YYYY
- Color coding for visual hierarchy:
  - Green: Approved, earnings, positive
  - Orange: Pending, awaiting review
  - Red: Rejected, withdrawals, negative
  - Blue: General info, available balance

## Dependencies Used

No new dependencies required for M4.
All features use existing packages:
- `flutter/material.dart` - UI components
- `shared_preferences` - Token storage (logout)
- Existing API client and services

## Code Quality

- Proper error handling
- Loading states for all API calls
- Pull-to-refresh on all screens
- User-friendly empty states
- Confirmation dialogs for destructive actions
- Clean separation of concerns (models, services, UI)
- Follows existing project patterns
- Responsive and accessible design
