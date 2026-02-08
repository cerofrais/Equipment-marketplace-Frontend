# Vendor Asset Management Feature

## Overview
This feature adds a complete vendor asset management system to the EquipVerse app, allowing vendors to list and manage their equipment for rental.

## New Flow

### 1. User Type Selection
After successful login, users are presented with a choice:
- **Customer**: Browse and rent equipment (existing flow)
- **Vendor**: Manage equipment listings (new flow)

### 2. Vendor Assets Screen
When "Vendor" is selected, users see:
- A list of their equipment/assets
- An empty state when no assets are available
- A floating action button (+) to add new assets

### 3. Add Asset Form
The form collects the following information:

#### Required Fields:
- **Asset Category**: Dropdown with options like Backhoe Loader, Excavator, Bulldozer, Crane, etc.
- **Manufacturer (Brand)**: Text input for the equipment brand
- **Model**: Text input for the model name
- **Year of Purchase**: Year picker dialog
- **Registration Number**: Validated text input (unique identifier)
- **Equipment Photos**: At least 1 photo required (Front, Side, Plate views)
- **Location**: Text input for asset location

#### Optional Fields:
- **Serial Number**: Text input
- **Condition/Notes**: Multi-line text area for additional details
- **Rental Rate Per Day**: Numeric input for daily rental rate
- **Rental Rate Per Week**: Numeric input for weekly rental rate

## Files Created

### Models
- `/lib/core/models/asset.dart` - Asset data model with JSON serialization

### Screens
- `/lib/features/auth/user_type_selection_screen.dart` - User type selection after login
- `/lib/features/vendor/vendor_assets_screen.dart` - Vendor's asset list screen
- `/lib/features/vendor/add_asset_screen.dart` - Form to add new assets

### Updated Files
- `/lib/app.dart` - Added routes and updated navigation flow
- `/lib/ui/screens/login_screen.dart` - Updated to navigate to user type selection

## Navigation Routes
- `/user-type-selection` - User type selection screen
- `/equipment-list` - Customer equipment browsing (existing)
- `/vendor-assets` - Vendor assets list
- `/add-asset` - Add new asset form

## Implementation Notes

### Current State
- The UI is fully implemented and functional
- Form validation is in place
- Navigation flow is working

### TODO Items
1. **Image Picker Integration**: Currently uses placeholder images. Needs integration with `image_picker` package for actual photo uploads
2. **API Integration**: 
   - Load vendor's assets from backend
   - Save new assets to backend
   - Update/delete existing assets
3. **Asset Storage**: Connect to cloud storage for equipment photos
4. **Authentication Enhancement**: Store user type (customer/vendor) in auth service

### Recommendations
1. Add `image_picker` package to `pubspec.yaml`:
   ```yaml
   dependencies:
     image_picker: ^1.0.4
   ```

2. Add `permission_handler` for camera/gallery permissions:
   ```yaml
   dependencies:
     permission_handler: ^11.0.0
   ```

3. Update the `_pickImage()` method in `add_asset_screen.dart` with actual image picker implementation

4. Create an API service for vendor operations:
   ```dart
   class VendorApiService {
     Future<List<Asset>> getVendorAssets();
     Future<Asset> createAsset(Map<String, dynamic> assetData);
     Future<Asset> updateAsset(String id, Map<String, dynamic> assetData);
     Future<void> deleteAsset(String id);
   }
   ```

## Testing
To test the new flow:
1. Run the app and login
2. Select "Vendor" on the user type selection screen
3. Click the floating action button (+) to add an asset
4. Fill in the required fields
5. Add sample photos (currently adds placeholder images)
6. Submit the form

The asset data is printed to the console for verification.
