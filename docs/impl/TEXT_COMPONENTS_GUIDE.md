# Text Components Usage Guide

## Quick Reference

### HeaderText Component

Use `HeaderText` for all titles, headings, and prominent text. It uses **Bricolage Grotesque** font.

#### Basic Usage
```dart
import '../../../../core/widgets/text/text_widgets.dart';

HeaderText('Your Title Here')
```

#### With Size
```dart
// Available sizes: h1, h2, h3, h4
HeaderText(
  'Large Title',
  size: HeaderSize.h1,  // Largest
)

HeaderText(
  'Medium Title',
  size: HeaderSize.h2,  // Default
)

HeaderText(
  'Small Title',
  size: HeaderSize.h3,
)

HeaderText(
  'Extra Small Title',
  size: HeaderSize.h4,  // Smallest
)
```

#### With Custom Styling
```dart
HeaderText(
  'Styled Header',
  size: HeaderSize.h2,
  color: Colors.white,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### BodyText Component

Use `BodyText` for all regular text, descriptions, and body content. It uses **Poppins** font.

#### Basic Usage
```dart
import '../../../../core/widgets/text/text_widgets.dart';

BodyText('Your text here')
```

#### With Size
```dart
// Available sizes: large, medium, small
BodyText(
  'Large body text',
  size: BodySize.large,  // 16sp
)

BodyText(
  'Medium body text',
  size: BodySize.medium,  // 14sp (default)
)

BodyText(
  'Small caption text',
  size: BodySize.small,  // 12sp
)
```

#### With Custom Styling
```dart
BodyText(
  'Styled body text',
  size: BodySize.large,
  color: AppColors.textSecondary,
  fontWeight: FontWeight.w300,
  height: 1.5,  // Line height
  textAlign: TextAlign.justify,
  maxLines: 3,
  overflow: TextOverflow.fade,
)
```

## Common Use Cases

### Splash Screen
```dart
// App name
HeaderText(
  'Workchop',
  size: HeaderSize.h1,
  color: Colors.white,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
)

// Tagline
BodyText(
  'Connecting Artisans & Clients',
  size: BodySize.large,
  color: Colors.white.withOpacity(0.9),
  fontWeight: FontWeight.w300,
)
```

### Page Titles
```dart
HeaderText(
  'Welcome to Workchop',
  size: HeaderSize.h2,
  color: AppColors.primary,
)
```

### Descriptions
```dart
BodyText(
  'We are connecting skilled artisans with clients who value quality craftsmanship.',
  size: BodySize.large,
  color: AppColors.textSecondary,
  height: 1.5,
)
```

### Labels
```dart
BodyText(
  'Tell us who you are:',
  size: BodySize.large,
  fontWeight: FontWeight.w500,
  color: AppColors.textPrimary,
)
```

### Buttons
```dart
BodyText(
  'Continue',
  size: BodySize.large,
  fontWeight: FontWeight.w600,
  color: Colors.white,
)
```

### Small Text / Captions
```dart
BodyText(
  'Last updated 2 hours ago',
  size: BodySize.small,
  color: AppColors.textTertiary,
)
```

## Properties Reference

### HeaderText Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `String` | Required | The text to display |
| `size` | `HeaderSize` | `h2` | Size of the header (h1, h2, h3, h4) |
| `color` | `Color?` | `AppColors.textPrimary` | Text color |
| `fontWeight` | `FontWeight?` | Auto (bold for h1/h2, w600 for h3/h4) | Font weight |
| `textAlign` | `TextAlign?` | `null` | Text alignment |
| `letterSpacing` | `double?` | `null` | Letter spacing |
| `maxLines` | `int?` | `null` | Maximum number of lines |
| `overflow` | `TextOverflow?` | `null` | How to handle overflow |

### BodyText Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `String` | Required | The text to display |
| `size` | `BodySize` | `medium` | Size of the text (large, medium, small) |
| `color` | `Color?` | Auto (primary for large/medium, secondary for small) | Text color |
| `fontWeight` | `FontWeight?` | `normal` | Font weight |
| `textAlign` | `TextAlign?` | `null` | Text alignment |
| `height` | `double?` | `null` | Line height multiplier |
| `maxLines` | `int?` | `null` | Maximum number of lines |
| `overflow` | `TextOverflow?` | `null` | How to handle overflow |

## Font Sizes

### HeaderText Sizes
- `HeaderSize.h1` → 32sp (AppSizes.h1)
- `HeaderSize.h2` → 28sp (AppSizes.h2)
- `HeaderSize.h3` → 24sp (AppSizes.h3)
- `HeaderSize.h4` → 20sp (AppSizes.h4)

### BodyText Sizes
- `BodySize.large` → 16sp (AppSizes.body)
- `BodySize.medium` → 14sp (AppSizes.bodySmall)
- `BodySize.small` → 12sp (AppSizes.caption)

## Migration Guide

### Before (Old Way)
```dart
Text(
  'Workchop',
  style: TextStyle(
    fontSize: AppSizes.h1,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  ),
)
```

### After (New Way)
```dart
HeaderText(
  'Workchop',
  size: HeaderSize.h1,
  color: Colors.white,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
)
```

## Benefits

✅ **Consistent Typography** - All headers use Bricolage Grotesque, all body text uses Poppins  
✅ **Less Code** - No need to repeat font styling  
✅ **Type Safety** - Enum-based sizes prevent typos  
✅ **Easy Maintenance** - Change font in one place  
✅ **Better Readability** - Clear semantic meaning (header vs body)  
✅ **Responsive** - Uses flutter_screenutil for responsive sizing  

## Tips

1. **Always use HeaderText for titles** - Even if you want a small title, use `HeaderSize.h4` instead of BodyText
2. **Use BodySize.large for important body text** - Like descriptions and main content
3. **Use BodySize.small for captions** - Like timestamps, helper text, etc.
4. **Leverage the height property** - For better readability in paragraphs (typically 1.5-1.6)
5. **Don't override the font family** - The components are designed to use specific fonts
