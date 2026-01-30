# Rental Request Form Implementation

## Overview
A comprehensive rental request form has been implemented that appears after equipment selection, allowing users to submit detailed rental requests to local vendors.

## Features Implemented

### 1. **Equipment Summary Card**
- Displays selected equipment with image, name, and category
- Provides context for the rental request

### 2. **Location Input (ZIP Code)**
- Required field with validation
- Accepts only 5-digit US ZIP codes
- Uses regex pattern validation
- Shows error messages for invalid inputs

### 3. **Rental Period Selection**
- **Start Date & Time Picker**
  - Calendar date selection
  - Time picker for specific hours
  - Cannot select past dates
  - Combined date and time selection
  
- **End Date & Time Picker**
  - Automatically restricted to dates after start date
  - Time picker included
  - Resets if start date is changed to a later date
  
- **Duration Calculator**
  - Automatically calculates rental duration in days
  - Displays below date pickers when both dates are selected

### 4. **Desired Price (Optional)**
- Optional budget field
- Numeric input only
- Validates positive numbers when provided
- Helper text explains it's optional
- Shows dollar sign icon

### 5. **Request Reason**
- Required multiline text field (4 lines)
- Minimum 10 characters required
- Maximum 500 characters
- Validates user provides sufficient detail
- Helps vendors understand the use case

### 6. **Information Card**
- Blue info card explaining the process
- Informs users that vendors will send quotes
- Sets clear expectations

### 7. **Submit Button**
- Full-width prominent button
- Shows loading spinner during submission
- Disabled while loading to prevent duplicate submissions
- Success/error messages via SnackBar

## Integration with Backend API

The form integrates with the Equipment Rental Marketplace API:

### Endpoint Used:
```
POST /api/v1/rental-requests
```

### Request Body:
```json
{
  "equipment_type_id": "UUID",
  "zip_code": "12345",
  "start_date": "2026-02-01T09:00:00Z",
  "end_date": "2026-02-05T17:00:00Z"
}
```

### Authentication:
- Uses JWT Bearer token from SharedPreferences
- Token is automatically included in the Authorization header

### Backend Process:
1. Validates equipment type exists
2. Converts ZIP code to GPS coordinates using geocoding
3. Creates rental request with status "pending"
4. Finds nearby vendors within 25km radius
5. Sends WhatsApp notifications to matched vendors

## User Flow

1. **Browse Equipment** → User browses equipment on home screen
2. **View Details** → User taps equipment to see details
3. **Initiate Rental** → User clicks "Rent Now" button
4. **Fill Form** → User fills out the rental request form:
   - Enter ZIP code
   - Select start date & time
   - Select end date & time
   - (Optional) Enter desired price
   - Describe reason for rental
5. **Submit** → User submits the request
6. **Confirmation** → Success message shown, user returned to home
7. **Wait for Quotes** → Vendors receive notifications and submit quotes
8. **Review Quotes** → User can view quotes in "My Rentals" section

## Files Modified/Created

### Created:
- `/lib/features/rental/rental_request_form_screen.dart` - Main form screen

### Modified:
- `/lib/features/rental/equipment_detail_screen.dart` - Added navigation to form
- `/pubspec.yaml` - Added `intl` package for date formatting

## Validation Rules

| Field | Validation |
|-------|-----------|
| ZIP Code | Required, 5 digits, numeric only |
| Start Date | Required, cannot be in the past |
| End Date | Required, must be after start date |
| Desired Price | Optional, must be positive number if provided |
| Request Reason | Required, minimum 10 characters, maximum 500 characters |

## Error Handling

### Client-Side Validation:
- Form validation prevents submission with invalid data
- Real-time error messages for each field
- User-friendly error text

### Network Errors:
- Try-catch block handles API failures
- Displays error message in SnackBar
- Loading state prevents multiple submissions
- User can retry after error

### Success Flow:
- Green success message shown
- User navigated back to home screen
- Can view submitted request in "My Rentals"

## UI/UX Considerations

- **ScrollView**: Form is scrollable to accommodate all fields on small screens
- **Card Design**: Equipment summary in card for visual hierarchy
- **Icons**: Each field has relevant icon for quick recognition
- **Color Coding**: Blue info card, green success, red errors
- **Loading State**: Clear visual feedback during submission
- **Disabled State**: Submit button disabled during loading
- **Helper Text**: Guidance provided for optional fields
- **Input Types**: Appropriate keyboards (numeric for ZIP, etc.)

## Future Enhancements (Optional)

1. **Auto-complete ZIP Code** - Use location services
2. **Price Estimation** - Show estimated price range based on equipment and duration
3. **Image Upload** - Allow users to upload reference images
4. **Favorite Locations** - Save frequently used ZIP codes
5. **Calendar View** - Show equipment availability calendar
6. **Push Notifications** - Notify when vendors submit quotes
7. **Draft Saving** - Save form as draft for later completion

## Testing Recommendations

1. Test with invalid ZIP codes
2. Test date picker edge cases (past dates, same date for start/end)
3. Test form submission with/without optional fields
4. Test network error scenarios
5. Test with various screen sizes
6. Test navigation flow (back button, form submission)

## Dependencies

```yaml
dependencies:
  intl: ^0.19.0          # Date formatting
  http: ^1.2.0           # API calls
  shared_preferences: ^2.2.2  # Token storage
```

## Notes

- The "desired price" and "request reason" fields are captured but not currently sent to the API (API doesn't accept them yet)
- These fields can be stored locally or sent when the API is updated to accept them
- The form follows Material Design 3 guidelines
- All date/times are converted to ISO 8601 format with UTC timezone as required by the API
