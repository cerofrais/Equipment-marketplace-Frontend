# Equipment Scheduling Feature

## Overview

The equipment scheduling feature allows vendors to schedule their equipment for customers by capturing customer contact information and rental dates/times. The system checks for scheduling conflicts before creating a schedule.

## Features Implemented

### 1. Schedule Data Model
- **File**: `lib/core/models/schedule.dart`
- **Models**:
  - `Schedule`: Represents a scheduled equipment rental
  - `AvailabilityCheck`: Represents the result of checking equipment availability

### 2. Schedule Service
- **File**: `lib/core/services/schedule_service.dart`
- **Methods**:
  - `checkAvailability()`: Checks if equipment is available for a given time range
  - `createSchedule()`: Creates a new schedule
  - `getAllSchedules()`: Retrieves all schedules
  - `getSchedulesByEquipment()`: Gets schedules for a specific equipment
  - `getSchedule()`: Gets a specific schedule by ID
  - `updateSchedule()`: Updates an existing schedule
  - `deleteSchedule()`: Deletes a schedule

### 3. Schedule Form Screen
- **File**: `lib/features/vendor/schedule_form_screen.dart`
- **Features**:
  - Date and time pickers for start and end times
  - Customer contact name field (required)
  - Customer contact number field (required)
  - Price field (optional, pre-filled from asset rental rate)
  - Availability check before submission
  - Detailed conflict information display
  - Form validation

### 4. Asset Details Integration
- **File**: `lib/features/vendor/asset_details_screen.dart`
- **Changes**:
  - Updated "Schedule - Coming Soon" button to functional "Schedule Equipment" button
  - Opens the schedule form when clicked
  - Shows success message after successful scheduling

### 5. Schedule List Screen
- **File**: `lib/features/vendor/schedule_list_screen.dart`
- **Features**:
  - Displays all schedules for a specific equipment in a data table
  - Shows customer name, phone number, start/end times, price, and status
  - Color-coded status badges (pending, confirmed, completed, cancelled)
  - Delete schedule functionality with confirmation dialog
  - Pull-to-refresh to reload schedules
  - Empty state and error state handling
  - Horizontal and vertical scrolling for large tables

### 6. Vendor Assets Screen Integration
- **File**: `lib/features/vendor/vendor_assets_screen.dart`
- **Changes**:
  - Added long-press menu on equipment cards
  - Menu options: "View Schedule" and "Delete Equipment"
  - Opens schedule list screen when "View Schedule" is selected

## User Flow

### Creating a Schedule

1. **Navigate to Equipment**: Vendor views their equipment in the Assets screen
2. **View Details**: Tap on an equipment card to see details
3. **Schedule Equipment**: Tap the "Schedule Equipment" button
4. **Fill Form**:
   - Select start date and time
   - Select end date and time
   - Enter customer contact name
   - Enter customer contact number
   - Optionally modify the price
5. **Submit**: Tap "Schedule Equipment" button
6. **Availability Check**: System automatically checks if the equipment is available
7. **Two Possible Outcomes**:
   - **Available**: Schedule is created successfully
   - **Conflict**: Error dialog shows who has the equipment booked with their contact details

### Viewing Schedules

1. **Navigate to Equipment**: Vendor views their equipment in the Assets screen
2. **Long Press**: Long-press on an equipment card
3. **Select Option**: Choose "View Schedule" from the bottom sheet menu
4. **View Table**: See all schedules in a comprehensive data table with:
   - Customer name and phone number
   - Start and end date/times
   - Price
   - Status (with color coding)
   - Delete action button
5. **Refresh**: Pull down to refresh the schedule list
6. **Delete Schedule**: Tap the delete icon to remove a schedule (with confirmation)

## API Endpoints Used

All endpoints follow the base URL pattern: `{BASE_URL}/api/v1/schedules/`

### POST `/api/v1/schedules/check-availability`
Check if equipment is available for scheduling.

**Request Body**:
```json
{
  "equipment_id": "string",
  "start_time": "2026-02-10T10:00:00Z",
  "end_time": "2026-02-15T18:00:00Z"
}
```

**Response** (Available):
```json
{
  "equipment_id": "f7f9e491-0966-4301-970c-a39368c49bbf",
  "is_available": true,
  "conflicting_schedules": []
}
```

**Response** (Conflict):
```json
{
  "equipment_id": "f7f9e491-0966-4301-970c-a39368c49bbf",
  "is_available": false,
  "conflicting_schedules": [
    {
      "id": "uuid",
      "vendor_id": "5f01b44f-aa7a-4b35-8aaa-8d13b45d19bb",
      "equipment_id": "f7f9e491-0966-4301-970c-a39368c49bbf",
      "start_time": "2026-02-12T10:00:00Z",
      "end_time": "2026-02-14T18:00:00Z",
      "name": "John Doe",
      "contact": "+1234567890",
      "price": "5000.00",
      "status": "confirmed",
      "created_at": "2026-02-10T09:00:00Z",
      "updated_at": "2026-02-10T09:00:00Z"
    }
  ]
}
```

### POST `/api/v1/schedules/`
Create a new schedule.

**Request Body**:
```json
{
  "vendor_id": "5f01b44f-aa7a-4b35-8aaa-8d13b45d19bb",
  "equipment_id": "ddbdce0c-bd5c-4689-bb20-45980fa7da60",
  "start_time": "2026-02-10T07:32:52.936Z",
  "end_time": "2026-02-11T07:32:52.936Z",
  "name": "string",
  "contact": "+513763767104",
  "price": 0
}
```

**Response**:
```json
{
  "vendor_id": "5f01b44f-aa7a-4b35-8aaa-8d13b45d19bb",
  "equipment_id": "ddbdce0c-bd5c-4689-bb20-45980fa7da60",
  "start_time": "2026-02-10T07:32:52.936000Z",
  "end_time": "2026-02-11T07:32:52.936000Z",
  "name": "string",
  "contact": "+513763767104",
  "price": "0.00",
  "id": "b139821d-f8bb-4a4d-8f0f-196ff30dcaa1",
  "created_at": "2026-02-10T07:34:28.330389Z",
  "updated_at": "2026-02-10T07:34:28.330395Z"
}
```

### GET `/api/v1/schedules/`
Get all schedules.

### GET `/api/v1/schedules/equipment/{equipment_id}`
Get all schedules for a specific equipment.

### GET `/api/v1/schedules/{schedule_id}`
Get a specific schedule.

### PUT `/api/v1/schedules/{schedule_id}`
Update a schedule.

### DELETE `/api/v1/schedules/{schedule_id}`
Delete a schedule.

## Form Validation

### Required Fields:
- Start Date & Time
- End Date & Time
- Customer Contact Name
- Customer Contact Number (minimum 10 digits)

### Optional Fields:
- Price (decimal with up to 2 decimal places)

### Validation Rules:
- End date/time must be after start date/time
- Start date/time must be in the future
- Equipment ID must exist
- Contact number must be at least 10 digits

## Conflict Handling

When a scheduling conflict is detected:

1. **Availability Check Fails**: The system calls the check-availability endpoint
2. **Conflict Details Retrieved**: Backend returns information about the conflicting schedule
3. **Error Dialog Displayed**: Shows a detailed dialog with:
   - Warning icon
   - Clear message about unavailability
   - Conflicting customer's name
   - Conflicting customer's phone number
   - Conflicting schedule start time
   - Conflicting schedule end time
4. **User Action**: User can:
   - Close the dialog
   - Modify the dates/times
   - Try scheduling again

## Error Handling

The implementation includes comprehensive error handling:

- **Network Errors**: Caught and displayed to user
- **Validation Errors**: Inline form validation
- **API Errors**: Displayed via error dialogs
- **Conflict Errors**: Special dialog with conflict details
- **Missing Data**: Validated before API calls

## UI Components

### Schedule Form Screen
- **Equipment Info Card**: Displays the equipment being scheduled (green background)
- **Date/Time Selectors**: Interactive cards that open date and time pickers
- **Text Fields**: Material Design text fields with icons
- **Submit Button**: Full-width green button
- **Loading State**: Shows circular progress indicator during API calls

### Schedule List Screen
- **Equipment Info Header**: Fixed header showing equipment details (green background)
- **Data Table**: Scrollable table with all schedule information
- **Column Headers**: Bold headers with green background
- **Status Badges**: Color-coded status indicators:
  - Green: Confirmed
  - Orange: Pending
  - Blue: Completed
  - Red: Cancelled
  - Grey: Default/Unknown
- **Action Buttons**: Delete icon button for each schedule
- **Empty State**: Friendly message when no schedules exist
- **Error State**: Error message with retry button
- **Pull-to-Refresh**: Swipe down to reload schedules

### Long-Press Menu (Vendor Assets)
- **Bottom Sheet**: Modal bottom sheet with rounded top corners
- **Menu Options**:
  - View Schedule (green calendar icon)
  - Delete Equipment (red delete icon)
- **Visual Handle**: Subtle drag handle at top

### Conflict Dialog
- **Warning Icon**: Orange warning icon
- **Customer Details**: Name and phone number
- **Schedule Details**: Start and end times formatted nicely
- **Icons**: Visual indicators for person, phone, and time

## Code Architecture

### Models (lib/core/models/)
- `schedule.dart`: Data models for Schedule and AvailabilityCheck

### Services (lib/core/services/)
- `schedule_service.dart`: All API calls related to scheduling

### Screens (lib/features/vendor/)
- `schedule_form_screen.dart`: Form for creating schedules
- `schedule_list_screen.dart`: Data table displaying all schedules for equipment
- `asset_details_screen.dart`: Updated to integrate scheduling button
- `vendor_assets_screen.dart`: Updated with long-press menu for viewing schedules

## Date/Time Formatting

The implementation uses the `intl` package for date/time formatting:

- **Display Format**: `MMM dd, yyyy - hh:mm a` (e.g., "Feb 10, 2026 - 02:30 PM")
- **API Format**: ISO 8601 UTC format (e.g., "2026-02-10T10:30:00Z")
- **Timezone**: All times are converted to UTC before sending to API

## Testing the Feature

### Test Case 1: Successful Schedule
1. Navigate to vendor assets
2. Tap on an equipment
3. Tap "Schedule Equipment"
4. Fill all required fields
5. Submit form
6. Verify success message

### Test Case 2: Scheduling Conflict
1. Create a schedule for an equipment
2. Try to create another schedule with overlapping dates
3. Verify conflict dialog appears with correct details

### Test Case 3: Validation Errors
1. Try to submit form without filling required fields
2. Try to set end time before start time
3. Enter invalid phone number (< 10 digits)
4. Verify appropriate error messages

### Test Case 4: Price Pre-fill
1. For equipment with rental_rate_per_day set
2. Open schedule form
3. Verify price field is pre-filled

### Test Case 5: View Schedules
1. Long-press on an equipment card
2. Select "View Schedule" from the menu
3. Verify schedule list screen opens
4. Verify all schedules are displayed in table format
5. Verify color-coded status badges

### Test Case 6: Delete Schedule
1. Open schedule list for an equipment
2. Tap delete icon on a schedule
3. Confirm deletion in the dialog
4. Verify schedule is removed and list updates

### Test Case 7: Long-Press Menu
1. Long-press on an equipment card in the assets screen
2. Verify bottom sheet appears with two options
3. Test "View Schedule" option - should open schedule list
4. Test "Delete Equipment" option - should show delete confirmation

### Test Case 8: Pull-to-Refresh
1. Open schedule list for an equipment
2. Pull down the list
3. Verify list refreshes and shows updated data

### Test Case 9: Empty Schedule State
1. Long-press on an equipment with no schedules
2. Select "View Schedule"
3. Verify empty state message appears

## Future Enhancements

Potential improvements for future versions:

1. **Edit Schedule**: Modify existing schedules from the schedule list
2. **Schedule Calendar**: Visual calendar view of schedules
3. **Notifications**: Send notifications for upcoming schedules
4. **Recurring Schedules**: Support for recurring/repeating schedules
5. **Schedule Status Management**: Update schedule status (pending → confirmed → completed)
6. **Payment Integration**: Connect with payment processing
7. **Schedule History**: View past schedules and analytics
8. **Multi-equipment Scheduling**: Schedule multiple equipment at once
9. **Export Schedules**: Export schedule data to CSV/PDF
10. **Schedule Filters**: Filter schedules by date range, status, or customer
11. **Search Functionality**: Search schedules by customer name or phone
12. **Schedule Reminders**: Automatic reminders before schedule start time

## Dependencies

- `flutter_dotenv`: For environment configuration
- `http`: For API calls
- `shared_preferences`: For token storage
- `intl`: For date/time formatting
- Material Design components

## Notes

- All times are stored and transmitted in UTC
- Equipment ID must exist before scheduling
- Authentication token is automatically included in API calls
- Form state is preserved during loading operations
- Success/error feedback is provided via SnackBars and Dialogs
