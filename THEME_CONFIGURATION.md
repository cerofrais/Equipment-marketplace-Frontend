# Theme Color Configuration Guide

This app uses a centralized color management system that loads colors from a JSON configuration file. This allows you to change the entire app's color scheme by editing just one file.

## 📁 Configuration File Location

The color configuration is stored in:
```
assets/config/theme_config.json
```

## 🎨 Current Color Scheme

The app currently uses a **Dark Mode Full Palette** with the following colors:

| Element | Hex Code | Usage |
|---------|----------|-------|
| Primary Background | `#000000` | Main app background and deepest UI layer |
| Secondary Background | `#121212` | Inset elements, search bars, and secondary containers |
| Tertiary Background | `#1F1F1F` | Elevated cards, modals, and surface overlays |
| Primary Content | `#FFFFFF` | Headlines, main body text, and primary icons |
| Secondary Content | `#AFAFAF` | Subtitles, secondary labels, and hint text |
| Tertiary Content | `#6B6B6B` | Disabled text and low-priority metadata |
| Primary Action / Safety Blue | `#276EF1` | Buttons, hyperlinks, and active states |
| Subtle Border | `#292929` | Standard dividers and thin separators |
| Opaque Border | `#333333` | Stronger separation for clickable components |
| Success Green | `#05A35B` | Confirmations and positive status updates |
| Warning Yellow | `#FFC043` | Cautions, pending states, and ratings |
| Error Red | `#E11900` | Critical alerts and destructive actions |
| Illustrative Brown | `#99644C` | Specialized icons or branded illustrations |

## 🔧 How to Change Colors

### Method 1: Edit the JSON File (Recommended)

1. Open `assets/config/theme_config.json`
2. Modify the `HexCode` values for any color element
3. Save the file
4. Restart the app to see changes

Example:
```json
{
  "Element": "Primary Action / Safety Blue",
  "HexCode": "#FF5733",  // Changed from #276EF1 to #FF5733
  "Usage": "Buttons, hyperlinks, and active states"
}
```

### Method 2: Use Colors in Your Code

Colors are accessed through the `AppColors` class:

```dart
import 'package:equip_verse/core/theme/app_colors.dart';

// Background colors
AppColors.primaryBackground
AppColors.secondaryBackground
AppColors.tertiaryBackground

// Content colors
AppColors.primaryContent
AppColors.secondaryContent
AppColors.tertiaryContent

// Action colors
AppColors.primaryAction

// Border colors
AppColors.subtleBorder
AppColors.opaqueBorder

// Status colors
AppColors.successGreen
AppColors.warningYellow
AppColors.errorRed

// Special colors
AppColors.illustrativeBrown
```

### Example Usage in Widgets:

```dart
Container(
  color: AppColors.primaryBackground,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.primaryContent),
  ),
)

ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryAction,
  ),
  onPressed: () {},
  child: Text('Click Me'),
)

Divider(
  color: AppColors.subtleBorder,
)
```

## 🎯 Theme Integration

The color system is integrated with Flutter's Material Theme:

- **ColorScheme**: Automatically maps colors to Material Design roles
- **AppBar**: Uses Secondary Background with Primary Content text
- **Cards**: Uses Tertiary Background with Subtle Border
- **Buttons**: Uses Primary Action color
- **Input Fields**: Uses Secondary Background with Primary Action focus
- **Dialogs**: Uses Tertiary Background
- **Snackbars**: Uses Tertiary Background

## 🚀 How It Works

1. **Initialization**: When the app starts, `main.dart` calls `AppColors.loadColorsFromConfig()`
2. **Loading**: The JSON file is loaded and parsed
3. **Mapping**: Each color element is mapped to its corresponding static variable in `AppColors`
4. **Theme Building**: `theme.dart` uses these colors to build the app theme
5. **Application**: The theme is applied to the entire app via `MaterialApp`

## 📝 Adding New Colors

To add a new color:

1. Add the color definition to `theme_config.json`:
```json
{
  "Element": "New Color Name",
  "HexCode": "#RRGGBB",
  "Usage": "Description of where it's used"
}
```

2. Add a static variable in `lib/core/theme/app_colors.dart`:
```dart
static Color newColorName = const Color(0xFFRRGGBB);
```

3. Add a case in the `loadColorsFromConfig()` switch statement:
```dart
case 'New Color Name':
  newColorName = color;
  break;
```

## 🔄 Hot Reload

After changing colors in the JSON file, you need to **restart the app** (not just hot reload) because colors are loaded during app initialization.

## 💡 Best Practices

1. **Use semantic names**: Don't hardcode colors; use `AppColors` constants
2. **Maintain consistency**: Use the provided color palette throughout the app
3. **Test changes**: After updating the JSON, test the app in different screens
4. **Document changes**: Update the Usage field in JSON when changing color purposes
5. **Version control**: Commit the JSON file with your color changes

## 🛠️ Troubleshooting

**Colors not updating?**
- Make sure you **restarted** the app (hot reload won't work)
- Check that the JSON file path in `pubspec.yaml` is correct
- Verify the JSON syntax is valid

**App crashes on startup?**
- Check the JSON file for syntax errors
- Ensure all hex codes are valid (6 characters, no spaces)
- Check the console for error messages

**Some widgets not using new colors?**
- Make sure the widget is using `AppColors` instead of hardcoded colors
- Check if the widget is using theme properties correctly
- Verify the theme is properly applied in `app.dart`

## 📚 Related Files

- `assets/config/theme_config.json` - Color configuration
- `lib/core/theme/app_colors.dart` - Color loading and management
- `lib/core/theme/theme.dart` - Theme definition using colors
- `lib/main.dart` - Color initialization
- `lib/app.dart` - Theme application

---

**Need help?** Check the inline code comments in `app_colors.dart` and `theme.dart` for more details.
