# Campaign List Feature Implementation (M2)

## Overview
This document describes the implementation of the Campaign List and Detail screens for the DataSet Mobile app (Milestone 2).

## What Was Implemented

### 1. Data Models
**File**: `lib/features/campaigns/models/campaign.dart`

Created a Campaign model class with:
- All campaign properties (id, title, description, category, photos required, reward, status, deadline, etc.)
- Factory constructor for JSON deserialization
- Helper properties:
  - `isActive`: Checks if campaign is active and not expired
  - `remainingPhotos`: Calculates how many photos are still needed
  - `totalReward`: Calculates total campaign payout

### 2. API Service
**File**: `lib/features/campaigns/services/campaign_service.dart`

Created CampaignService with:
- `getCampaigns()`: Fetches all campaigns from the API
- `getCampaignById(id)`: Fetches a specific campaign by ID
- Proper error handling
- Uses authenticated API calls

### 3. Campaign List Screen
**File**: `lib/features/campaigns/campaign_list_screen.dart`

Features implemented:
- ✅ Display all campaigns in a scrollable list
- ✅ Search functionality (searches title and description)
- ✅ Filter by status (All/Active/Expired)
- ✅ Pull-to-refresh
- ✅ Loading states
- ✅ Error handling with retry button
- ✅ Empty state messaging
- ✅ Campaign cards showing:
  - Title and description
  - Status badge (Active/Expired)
  - Category
  - Upload progress (current/total)
  - Reward per photo
  - Deadline
- ✅ Navigation to detail screen on tap

### 4. Campaign Detail Screen
**File**: `lib/features/campaigns/campaign_detail_screen.dart`

Features implemented:
- ✅ Full campaign information display
- ✅ Organized info sections:
  - Header with title and status badge
  - Info card with reward, total photos, deadline, created date
  - Full description
  - Progress bar showing upload completion
- ✅ Upload button (placeholder for next milestone)
- ✅ Loading and error states
- ✅ Responsive design

### 5. Navigation Updates
Updated files:
- `lib/features/auth/login_screen.dart` - Now navigates to CampaignListScreen
- `lib/features/auth/signup_screen.dart` - Now navigates to CampaignListScreen

## Project Structure

```
lib/
├── core/
│   ├── api_client.dart
│   └── config.dart
├── features/
│   ├── auth/
│   │   ├── auth_service.dart
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   └── campaigns/
│       ├── models/
│       │   └── campaign.dart             [NEW]
│       ├── services/
│       │   └── campaign_service.dart     [NEW]
│       ├── campaign_list_screen.dart     [NEW]
│       ├── campaign_detail_screen.dart   [NEW]
│       └── campaign_list_placeholder.dart [OLD - can be deleted]
└── main.dart
```

## API Integration

The implementation connects to the Visual Data Platform API:
- **Base URL**: `https://visual-data-api.onrender.com/v1`
- **Endpoints used**:
  - `GET /campaigns` - Fetch all campaigns
  - `GET /campaigns/:id` - Fetch specific campaign

## Features Summary

### Campaign List
- Search bar for filtering campaigns
- Filter dropdown (All/Active/Expired)
- Pull-to-refresh functionality
- Responsive card layout
- Shows key campaign metrics at a glance

### Campaign Detail
- Comprehensive campaign information
- Visual progress tracking
- Action button for photo upload (ready for M3)
- Clean, organized UI

## Next Steps (M3)

The next milestone should implement:
1. Photo upload functionality
2. Camera integration
3. Gallery picker
4. Upload progress tracking
5. Image preview
6. Multi-image upload support

## Testing

To test this implementation:

1. Run the app:
   ```bash
   flutter run
   ```

2. Login/Signup with valid credentials

3. You should see the campaign list screen

4. Test the following:
   - Search functionality
   - Filter by status
   - Pull to refresh
   - Tap on a campaign to see details
   - Tap upload button (shows placeholder message)

## Notes

- The old `campaign_list_placeholder.dart` file can be safely deleted
- All campaigns require authentication (JWT token)
- The upload button is a placeholder for the next milestone
- Error handling includes retry functionality
- Loading states provide good user feedback

## Dependencies Used

No new dependencies were added. The implementation uses:
- `http` - For API calls
- `shared_preferences` - For token storage (already in use)
- Flutter Material widgets

## Code Quality

- Follows existing project patterns
- Proper state management using StatefulWidget
- Error handling with user-friendly messages
- Responsive design
- Clean separation of concerns (models, services, UI)
