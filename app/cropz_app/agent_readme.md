# Agent Reference Log

## Date
- 2026-02-24

## Project Setup
- Created Flutter project at `F:\cc_code\app\cropz_app`.
- Platform scope: Android only.
- State management selected: Riverpod.
- Local persistence selected for now: SQLite (`sqflite`), with server sync planned later.

## Architecture Decisions
- Adopted feature-first clean architecture structure.
- Current implemented feature scope: `cropz_card` only.
- Layers created:
  - `lib/app`
  - `lib/shared`
  - `lib/features/cropz_card/domain`
  - `lib/features/cropz_card/data`
  - `lib/features/cropz_card/presentation`

## Dependencies Added
- `flutter_riverpod`
- `sqflite`
- `path`

## Core Implementations Completed
- App bootstrap with `ProviderScope`.
- SQLite database class with table creation.
- Domain entities for:
  - `CropzProfile`
  - `BankInfo`
  - `ProfileAddress`
  - `CropzCardDetails` aggregate
- Data models for:
  - `CropzProfileModel`
  - `BankInfoModel`
  - `ProfileAddressModel`
- Local datasource:
  - fetch profiles
  - fetch bank rows by profile
  - fetch address rows by profile
  - transactional save for profile + related rows
- Repository contract + implementation aligned to aggregate save/load.
- Riverpod providers for datasource/repository/list/details/form-controller.
- Cropz Card UI:
  - home/list page
  - create/edit form page

## Functional Scope Added in UI
- Profile create/edit.
- Multiple bank accounts per profile (add/remove sections).
- Multiple addresses per profile (add/remove sections).
- Address type support (office/godown/shop via free text field).
- Single transactional save from form for all related data.

## UI instructions
	When generating Flutter UI code, strictly adhere to a premium "Soft-UI / Claude" aesthetic by bypassing aggressive Material defaults:
	
	1. Typography & Hierarchy:
	   - Default to clean, modern sans-serif fonts (like Inter or Geist).
	   - Use strict neutral palettes. Avoid pure black. Use colors like Color(0xFF18181B) for primary text and Color(0xFF71717A) for secondary text.
	
	2. Cards & Containers (Bento Grid style):
	   - Never use the default Material 'Card' widget. Build cards manually using Container.
	   - Force a rounded profile using 'BorderRadius.circular(16)' or 24.
	   - Use extremely soft shadows: 'BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))'.
	   - Use a very thin, subtle border: 'Border.all(color: Color(0xFFE4E4E7))'.
	
	3. Spacing & Padding:
	   - Use generous negative space. Default to gaps of 16, 24, or 32 between main sections to let elements breathe.
	
	4. Micro-Interactions:
	   - Never let UI elements just "snap" into view. Wrap dynamic components in 'AnimatedContainer', 'AnimatedOpacity', or 'AnimatedSwitcher'.
	   - Use 'Curves.easeInOutCubic' for premium-feeling transitions.
	
## Data Model Alignment Work
- Mapped fields from `data_model.md` into entity/model structure.
- Updated model mapping to support data-model naming variants.
- Added `CropzProfileModel.fromEntity(...)` and used it in repository mapping.

## SQLite Column Alignment (Latest)
- Aligned column names to normalized `data_model.md` style.
- DB schema version bumped to `2`.
- Added `onUpgrade` strategy.
- Current upgrade implementation drops and recreates tables from v1 to v2.

### Profiles table (current naming)
- `cropzid`, `firmname`, `ownername`, `mobile`, `whatsapp`, `email`, `gstno`
- `slno`, `slexpdate`, `plno`, `retailflno`, `retailflexpdate`
- `wsflno`, `wsflexpdate`, `fmsretailid`, `fmswsid`
- `gst_document`, `sl_document`, `pl_document`, `fl_document`
- `companies`, `upiid`, `qrcode`, `transport`

### Bank table (current naming)
- `name`, `accountno`, `accounttype`, `ifsccode`, `bankname`, `branch`

### Address table (current naming)
- `cropzid`, `addresstype`, `address1`, `address2`, `address3`
- `city`, `taluk`, `block`, `district`, `state`, `pincode`
- `ingst`, `parentcropzid`

## Known Notes
- Previous full CLI `flutter analyze` calls timed out in this environment; targeted MCP analysis used and passing for modified files.
- Lint `unnecessary_underscores` was fixed in home page.
- Current DB upgrade is destructive (local data reset on schema upgrade).

## Update - License Fields UI (2026-02-24)
- Added license and related ID fields to Cropz Card form UI:
  - `slNo`, `slExpiryDate`
  - `plNo`
  - `retailFlNo`, `retailFlExpiryDate`
  - `wsFlNo`, `wsFlExpiryDate`
  - `fmsRetailId`, `fmsWsId`
- Added dedicated form section: `Licenses & IDs`.
- Wired all above fields to profile save mapping (not just carrying previous values).
- Verified with targeted analyzer: no errors.

## Update - Essential First UX Flow (2026-02-24)
- Refactored Cropz Card form into a 5-step `Stepper`.
- Step order:
  1. Essential
  2. Business & Licenses
  3. Bank Accounts
  4. Addresses
  5. Review & Save
- Only essential fields are shown first.
- Users can go back using Back button and can tap any step title to jump and edit previous sections.
- Save action moved to final step (`Review & Save`).
- Targeted analysis: no errors.

## Update - Documents Section (2026-02-24)
- Added a new Stepper section: `Documents` (before `Review & Save`).
- Added support to upload and store locally (app documents directory) these files:
  - Seed License
  - Pesticide License
  - Fertilizer License
  - GST
- Allowed file types: PDF and images (`pdf`, `png`, `jpg`, `jpeg`, `webp`).
- Added share action for each uploaded document using native share sheet.
- Added replace/remove actions for uploaded documents.
- Stored document paths in existing profile fields:
  - `slDocument`, `plDocument`, `flDocument`, `gstDocument`
- Added dependencies:
  - `file_picker`
  - `path_provider`
  - `share_plus`
- Targeted analysis: no errors.
