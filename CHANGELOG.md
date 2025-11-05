# Changelog

## 0.1.2 - 2025-11-05

#### 🐛 Bug Fixes
- Fixed `minHeight` behavior when set to `null` — now defaults gracefully without layout issues.

#### 📚 Documentation
- Added README notes clarifying that `isDense` is always `true`. When using `prefixIcon` or `suffixIcon`, developers should explicitly set `Icon(size: 24)` to match native `TextField` alignment.


## 0.1.1 - 2025-11-05

- InputDecoration are fixed to dense:true to get more space

## 0.1.0 - 2025-11-04

- **Migrated core layout to `InputDecorator`**  
  Replaced legacy composition with native `InputDecorator` for idiomatic form field rendering and label/hint behavior.

- **Removed all `compensation` and `displayPadding` parameters**  
  Simplified API surface by eliminating manual layout overrides. Alignment now follows native Flutter behavior.
  
## 0.0.8 - 2025-10-30

- Fix vertical offset when max height null.

## 0.0.7 - 2025-10-30

- Fix vertical offset when content height maxes out.

## 0.0.6 - 2025-10-26

- Fix pubspec.yaml to long description

## 0.0.5 - 2025-10-26

- Updated README add missing ko-fi button

## 0.0.4 - 2025-10-26

- Updated README with dedicated picker examples section
- Optimized topics for pub.dev search
- Minor documentation improvements and clarifications

## 0.0.3 - 2025-10-26

- Fixed displayPadding so displayed content aligns correctly inside decorated fields.
- Replaced sample GIF with a smaller variant for faster README loading.

## 0.0.2 - 2025-10-26

- Unified `onTap` signature to `FutureOr<void>` for `AnyField` and `AnyFormField`.
- Expanded documentation for compensation params (helper/error/floating/left/right/top).
- README and example updates (smaller demo GIF); packaging and example fixes.
- Minor doc improvements and bug fixes.

## 0.0.1

Initial release of AnyField plugin.

### Features
* Flexible input field widget that can display arbitrary content
* Full support for InputDecoration (labels, borders, icons)
* Form integration via AnyFormField wrapper
* Value management through AnyValueController
* Configurable height constraints with scroll support
* Platform-aware layout compensation parameters
* Keyboard navigation and focus support
* Tap handling for custom interaction (sync/async)

### Documentation
* Added comprehensive API documentation
* Included usage examples
* Platform-specific layout compensation guide

### Example
* Added sample app demonstrating basic usage
* Included form integration examples
* Demonstrated various input types (date, tags, custom content)
