# API Requirements for Profile Page

## Current Available APIs (from http://localhost:8000/docs)

### ✅ User Profile APIs
- **GET** `/api/v1/users/me` - Get Current User Profile
  - Returns user details including: id, phone_number, email, full_name, address, city, state, zip_code, company_name, role, is_active, created_at, updated_at
  
- **PUT** `/api/v1/users/{user_id}` - Update User
  - Updates user details
  - Accepts fields: email, full_name, address, city, state, zip_code, company_name

### ✅ Request History APIs
- **GET** `/api/v1/rental-requests/my-requests` - Get My Requests
  - Returns list of rental requests created by the logged-in user
  - Each request includes: id, user_id, equipment_type_id, zip_code, start_date, end_date, status, created_at

## Additional Features That Could Be Added

### 1. Enhanced Request Details
Currently the request only shows basic info. Consider adding:

**GET** `/api/v1/rental-requests/{request_id}`
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "equipment_type_id": "uuid",
  "equipment_type": {
    "id": "uuid",
    "name": "Excavator",
    "description": "Heavy machinery for construction"
  },
  "zip_code": "12345",
  "start_date": "2026-02-01T00:00:00",
  "end_date": "2026-02-15T00:00:00",
  "status": "pending",
  "quotes_count": 3,
  "created_at": "2026-01-30T10:00:00",
  "updated_at": "2026-01-30T10:00:00"
}
```

### 2. User Profile Picture Upload
Add endpoint for profile picture:

**POST** `/api/v1/users/me/profile-picture`
- Content-Type: multipart/form-data
- Accepts: image file
- Returns: updated user object with profile_picture_url

### 3. User Activity Statistics
Dashboard statistics for user:

**GET** `/api/v1/users/me/statistics`
```json
{
  "total_requests": 15,
  "active_requests": 3,
  "completed_requests": 10,
  "rejected_requests": 2,
  "total_spent": 5000.00,
  "average_request_value": 333.33
}
```

### 4. Notification Preferences
User notification settings:

**GET** `/api/v1/users/me/preferences`
**PUT** `/api/v1/users/me/preferences`
```json
{
  "email_notifications": true,
  "sms_notifications": true,
  "push_notifications": true,
  "marketing_emails": false,
  "quote_alerts": true,
  "request_updates": true
}
```

### 5. Request with Quote Information
Enhanced my-requests endpoint to include quote summary:

**GET** `/api/v1/rental-requests/my-requests?include_quotes=true`
```json
[
  {
    "id": "uuid",
    "equipment_type_id": "uuid",
    "equipment_type_name": "Excavator",
    "zip_code": "12345",
    "start_date": "2026-02-01",
    "end_date": "2026-02-15",
    "status": "quoted",
    "quotes": [
      {
        "id": "uuid",
        "vendor_name": "ABC Rentals",
        "total_price": 3500.00,
        "status": "pending"
      }
    ],
    "created_at": "2026-01-30T10:00:00"
  }
]
```

### 6. User Address Book
Multiple saved addresses:

**GET** `/api/v1/users/me/addresses`
**POST** `/api/v1/users/me/addresses`
**PUT** `/api/v1/users/me/addresses/{address_id}`
**DELETE** `/api/v1/users/me/addresses/{address_id}`

```json
{
  "addresses": [
    {
      "id": "uuid",
      "label": "Work",
      "address": "123 Main St",
      "city": "Boston",
      "state": "MA",
      "zip_code": "02101",
      "is_default": true
    },
    {
      "id": "uuid",
      "label": "Home",
      "address": "456 Oak Ave",
      "city": "Cambridge",
      "state": "MA",
      "zip_code": "02139",
      "is_default": false
    }
  ]
}
```

### 7. User Payment Methods
Saved payment methods:

**GET** `/api/v1/users/me/payment-methods`
**POST** `/api/v1/users/me/payment-methods`
**DELETE** `/api/v1/users/me/payment-methods/{payment_id}`

```json
{
  "payment_methods": [
    {
      "id": "uuid",
      "type": "card",
      "last4": "4242",
      "brand": "visa",
      "is_default": true
    }
  ]
}
```

## Implementation Priority

### High Priority (Core Features) ✅
- ✅ GET /api/v1/users/me
- ✅ PUT /api/v1/users/{user_id}
- ✅ GET /api/v1/rental-requests/my-requests

### Medium Priority (Enhanced UX)
- GET /api/v1/rental-requests/{request_id} with full details
- GET /api/v1/users/me/statistics
- POST /api/v1/users/me/profile-picture

### Low Priority (Advanced Features)
- User notification preferences
- Multiple addresses
- Payment methods management

## Current Implementation Status

The Flutter app now includes:
1. **User Model** (`lib/core/models/user.dart`) - Complete user data structure
2. **User Service** (`lib/core/services/user_service.dart`) - API calls for profile management
3. **Enhanced Profile Screen** (`lib/features/profile/profile_screen.dart`) - Full UI with:
   - Tab-based interface (Profile Details & Request History)
   - Edit profile dialog
   - Display all user information
   - Request history with status indicators
   - Pull-to-refresh functionality
   - Responsive error handling

## Notes
All currently required APIs are available on the backend. The profile page is fully functional with the existing endpoints!
