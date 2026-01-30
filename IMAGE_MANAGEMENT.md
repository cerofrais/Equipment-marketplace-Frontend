# Image Management Guide

## 📁 Directory Structure

```
equip_verse/
└── assets/
    └── images/
        ├── placeholder.png    # Default fallback image
        ├── excavator.png      # Equipment-specific images
        ├── forklift.png
        └── ...
```

## 🖼️ How to Add Images

### 1. Save Your Image
Save the equipment image file to:
```
/Users/harshav/Desktop/git_repos/equip_verse/assets/images/
```

### 2. Image Types Supported
- PNG (recommended for quality)
- JPG/JPEG
- WebP
- GIF

### 3. Image Naming Convention
- Use lowercase
- Use underscores for spaces: `mini_excavator.png`
- Keep names descriptive: `caterpillar_backhoe.png`

## 🔧 How Images Work

The app uses the **`EquipmentImage`** widget which automatically handles:

### Local Assets (Offline)
```dart
image: 'assets/images/placeholder.png'
```
- Loaded from your project's `assets/images/` folder
- Fast and always available
- Perfect for placeholders

### Network Images (Online)
```dart
image: 'https://example.com/equipment/excavator.jpg'
```
- Loaded from API/URLs
- Shows loading spinner while downloading
- Falls back to placeholder on error

## 📝 Equipment Model Configuration

The `Equipment` model automatically:
1. Checks if backend provides `image_url`
2. Uses network URL if available
3. Falls back to local placeholder if not

```dart
factory Equipment.fromJson(Map<String, dynamic> json) {
  return Equipment(
    image: json['image_url'] ?? 'assets/images/placeholder.png',
    // ... other fields
  );
}
```

## 🎨 Image Display Features

The `EquipmentImage` widget provides:

✅ **Automatic Detection** - Detects network vs local images  
✅ **Loading Spinner** - Shows progress for network images  
✅ **Error Handling** - Falls back to placeholder icon  
✅ **Rounded Corners** - Wrapped in ClipRRect for aesthetics  
✅ **Responsive Sizing** - Adapts to different screen sizes  

## 📱 Where Images Appear

1. **Equipment Detail Screen** - Large 250px height banner
2. **Rental Request Form** - Small 80x80px thumbnail
3. **Home Screen** (if implemented) - Grid/list item images
4. **My Rentals Screen** (if implemented) - Request history

## 🔄 Quick Start

After adding your image to `assets/images/`:

1. **Run pub get** (if it's a new image):
   ```bash
   flutter pub get
   ```

2. **Hot Reload** - The image should appear immediately

## 💡 Best Practices

### Image Sizes
- **Thumbnails**: 200x200px (80-100px display)
- **Detail view**: 800x600px (250px height display)
- **High-DPI**: 2x or 3x resolution variants

### Optimization
- Compress images before adding (use TinyPNG, ImageOptim)
- Target ~100-300KB for detail images
- Target ~20-50KB for thumbnails

### Resolution Variants (Optional)
```
assets/images/
├── placeholder.png       # 1x (base)
├── 2.0x/
│   └── placeholder.png   # 2x (high DPI)
└── 3.0x/
    └── placeholder.png   # 3x (extra high DPI)
```

## 🌐 Production Setup

For production, you'll likely:

1. **Upload images to cloud storage** (AWS S3, Cloudinary, etc.)
2. **Backend returns URLs** in the API response
3. **App displays** using network images
4. **Local assets** serve as fallbacks only

Example API response:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Excavator",
  "category": "construction",
  "description": "Heavy construction equipment",
  "image_url": "https://cdn.example.com/equipment/excavator.jpg"
}
```

## 🐛 Troubleshooting

### Image not showing?
1. Check file path: `assets/images/your_image.png`
2. Verify `pubspec.yaml` includes `- assets/images/`
3. Run `flutter pub get`
4. Try hot restart (not just hot reload)

### Blurry images?
- Use higher resolution images (2x or 3x)
- Check image compression settings

### Slow loading?
- Optimize/compress images
- Consider using cached_network_image package for better caching

## 📦 Related Files

- **Widget**: `lib/core/widgets/equipment_image.dart`
- **Model**: `lib/core/models/equipment.dart`
- **Config**: `pubspec.yaml`
- **Screens**: 
  - `lib/features/rental/equipment_detail_screen.dart`
  - `lib/features/rental/rental_request_form_screen.dart`
