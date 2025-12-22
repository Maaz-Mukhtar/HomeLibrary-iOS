# Home Library iOS - App Store Deployment Guide

## Overview

This guide covers everything needed to publish Home Library to the Apple App Store.

---

## 1. Apple Developer Account

| Item | Details |
|------|---------|
| Program | Apple Developer Program |
| Cost | $99/year |
| Sign up | [developer.apple.com](https://developer.apple.com) |
| Approval time | 24-48 hours |

**Options:**
- **Individual** - Publish under your personal name
- **Organization** - Publish under company name (requires D-U-N-S number)

---

## 2. Business Identity (Optional)

### If Publishing as Individual
- App will show your personal name as seller
- Simpler setup, no additional requirements

### If Publishing as Organization
- [ ] Choose company name
- [ ] Register business (LLC, etc.) - varies by location
- [ ] Get D-U-N-S Number (free from Dun & Bradstreet, takes 1-2 weeks)
- [ ] Enroll as organization in Apple Developer Program

---

## 3. App Icon

### Requirements
- **Size:** 1024 x 1024 pixels
- **Format:** PNG (no alpha/transparency)
- **Shape:** Square (iOS applies rounded corners automatically)

### Design Guidelines
- Simple, recognizable design
- No screenshots or photos
- Works at small sizes (29px)
- Consistent with app's visual style

### Tools
- Figma (free)
- Canva (free)
- Sketch (paid)
- Hire designer: Fiverr ($20-50)

### Checklist
- [ ] Create 1024x1024 app icon
- [ ] Add to Assets.xcassets/AppIcon.appiconset
- [ ] Verify icon appears correctly in Xcode

---

## 4. App Store Screenshots

### Required Sizes

| Device | Size (pixels) | Required |
|--------|---------------|----------|
| iPhone 6.7" | 1290 x 2796 | Yes |
| iPhone 6.5" | 1284 x 2778 | Yes |
| iPhone 5.5" | 1242 x 2208 | Optional |
| iPad 12.9" | 2048 x 2732 | If supporting iPad |

### Screenshot Guidelines
- 3-10 screenshots per device size
- Show key features (Library, Add Book, Scan, Search)
- Can add text overlays and device frames
- First screenshot is most important

### Recommended Screenshots
1. Library grid view with books
2. Book detail page
3. Barcode scanning in action
4. Search and filter
5. Add book form

### Tools
- Screenshots.pro
- AppMockUp
- Figma templates

### Checklist
- [ ] Take raw screenshots from simulator
- [ ] Design frames/backgrounds
- [ ] Add feature callout text
- [ ] Export at correct sizes

---

## 5. App Preview Video (Optional)

| Requirement | Details |
|-------------|---------|
| Length | 15-30 seconds |
| Format | H.264, .mov or .mp4 |
| Resolution | Match screenshot sizes |

---

## 6. App Store Listing

### App Information

| Field | Value | Max Length |
|-------|-------|------------|
| App Name | Home Library | 30 chars |
| Subtitle | Catalog Your Book Collection | 30 chars |
| Category | Books or Lifestyle | - |
| Content Rating | 4+ | - |

### Description (4000 chars max)

```
Home Library helps you catalog and organize your physical book collection with ease.

FEATURES:
• Scan barcodes to instantly add books
• Manual entry with cover image support
• Organize by genre, location, and custom tags
• Search across your entire library
• Mark favorites for quick access
• Grid and list view options
• Sort by title, author, date, and more

SIMPLE ORGANIZATION:
Create custom locations (Bedroom Shelf, Living Room) and tags (To Read, Favorites) to organize your books exactly how you want.

POWERFUL SEARCH:
Find any book instantly by searching title, author, ISBN, notes, or tags.

OFFLINE FIRST:
All your data is stored locally on your device. No account required, no internet needed.

Perfect for book lovers who want to know exactly what's in their collection and where to find it.
```

### Keywords (100 chars)
```
books,library,catalog,bookshelf,collection,reading,isbn,barcode,scanner,organizer
```

### Checklist
- [ ] Write app description
- [ ] Choose keywords
- [ ] Select category
- [ ] Set content rating

---

## 7. Privacy & Legal

### Privacy Policy (Required)

**What to include:**
- What data the app collects
- How data is stored (locally only)
- No third-party sharing
- Contact information

**Free generators:**
- [freeprivacypolicy.com](https://freeprivacypolicy.com)
- [privacypolicytemplate.net](https://privacypolicytemplate.net)

**Host options:**
- GitHub Pages (free)
- Notion public page (free)
- Your own website

### App Privacy Details

For Home Library, declare:
- **Data Not Collected** - App doesn't collect any user data
- **Data Not Linked to You** - No tracking or analytics

### Export Compliance

Home Library uses HTTPS for API calls, which includes encryption:
- Answer "Yes" to encryption question
- Select "Only uses standard encryption" (exempt)

### Checklist
- [ ] Create privacy policy
- [ ] Host privacy policy online
- [ ] Get privacy policy URL
- [ ] Prepare App Privacy answers

---

## 8. Xcode Configuration

### Current Settings
```
Bundle ID: com.maazmukhtar.HomeLibrary
Version: 1.0.0
Build: 1
iOS Target: 17.0+
```

### Before Submitting
- [ ] Set DEVELOPMENT_TEAM in project.yml
- [ ] Create App Store distribution certificate
- [ ] Create App Store provisioning profile
- [ ] Archive build in Xcode

---

## 9. TestFlight (Recommended)

Beta test before public release:

1. Archive app in Xcode
2. Upload to App Store Connect
3. Add internal testers (up to 100)
4. Optionally add external testers (up to 10,000)
5. Collect feedback and fix issues

### Checklist
- [ ] Upload build to TestFlight
- [ ] Test on multiple devices
- [ ] Test on different iOS versions
- [ ] Fix any reported issues

---

## 10. App Store Submission

### In App Store Connect

1. Create new app
2. Fill in app information
3. Upload screenshots
4. Set pricing (Free)
5. Submit for review

### Review Process
- **Typical time:** 24-48 hours
- **Possible outcomes:** Approved, Rejected (with reasons)
- **Common rejection reasons:**
  - Crashes or bugs
  - Incomplete features
  - Privacy policy issues
  - Guideline violations

---

## Cost Summary

| Item | Cost |
|------|------|
| Apple Developer Account | $99/year |
| App Icon Design | $0-50 |
| Screenshot Design | $0-50 |
| Privacy Policy | Free |
| **Total** | **$99-199** |

---

## Timeline

| Phase | Duration |
|-------|----------|
| Developer account setup | 1-2 days |
| Icon and assets creation | 1-3 days |
| TestFlight testing | 3-7 days |
| App Store review | 1-3 days |
| **Total** | **1-2 weeks** |

---

## Checklist Summary

### Before Starting
- [ ] Apple Developer Account ($99)
- [ ] Decide: Individual vs Organization

### Assets
- [ ] App icon (1024x1024)
- [ ] Screenshots (all required sizes)
- [ ] App preview video (optional)

### Content
- [ ] App name and subtitle
- [ ] Full description
- [ ] Keywords
- [ ] Privacy policy URL

### Technical
- [ ] Configure signing in Xcode
- [ ] Test on physical devices
- [ ] TestFlight beta test
- [ ] Archive and upload

### Submit
- [ ] Create app in App Store Connect
- [ ] Upload all assets
- [ ] Submit for review
- [ ] Respond to any reviewer questions

---

*Last updated: December 23, 2024*
