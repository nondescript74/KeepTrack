# CloudKit & App Group Setup Checklist

## Common Runtime Crash Causes on Physical Devices

If your app crashes on a physical device but works in simulator, follow this checklist:

---

## ✅ Xcode Project Configuration

### 1. **Signing & Capabilities Tab**

#### App Groups
- [ ] Open your target → **Signing & Capabilities**
- [ ] Verify **App Groups** capability is added
- [ ] Confirm group identifier matches code: `group.com.headydiscy.KeepTrack`
- [ ] Group should show a checkmark (✓) when properly configured

#### iCloud
- [ ] Verify **iCloud** capability is added
- [ ] Enable **CloudKit** checkbox
- [ ] Verify container identifier matches code: `iCloud.com.headydiscy.KeepTrack`
- [ ] Container should appear in the containers list

#### Background Modes (Optional but Recommended)
- [ ] Add **Background Modes** capability
- [ ] Enable **Remote notifications** (for CloudKit sync)

---

### 2. **Bundle Identifier**

- [ ] Verify bundle identifier matches your App ID in Apple Developer portal
- [ ] Example: `com.headydiscy.KeepTrack`
- [ ] Check under **General** tab → **Identity** section

---

### 3. **Team & Provisioning Profile**

- [ ] Verify correct **Team** is selected under **Signing & Capabilities**
- [ ] For physical device testing, ensure:
  - [ ] Valid development certificate
  - [ ] Development provisioning profile includes:
    - Your test device UDID
    - App Groups entitlement
    - CloudKit entitlement

---

## ✅ Apple Developer Portal Configuration

### 1. **App ID Setup**

Visit [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)

- [ ] App ID exists for `com.headydiscy.KeepTrack` (or your bundle ID)
- [ ] **App Groups** capability is enabled
- [ ] **iCloud** capability is enabled with **CloudKit** support

### 2. **App Group Setup**

- [ ] App Group `group.com.headydiscy.KeepTrack` is created
- [ ] App Group is linked to your App ID

### 3. **CloudKit Container**

- [ ] Container `iCloud.com.headydiscy.KeepTrack` exists
- [ ] Container is associated with your App ID

---

## ✅ Physical Device Configuration

### 1. **iCloud Account**

- [ ] Device is signed into iCloud
  - **Settings** → [Your Name] → **iCloud**
- [ ] iCloud Drive is enabled
- [ ] Sufficient iCloud storage available

### 2. **Developer Settings**

- [ ] Device is registered in your Apple Developer account
- [ ] Device UDID is in the provisioning profile

---

## ✅ Testing the Fix

The updated `SwiftDataManager` now has **fallback logic**:

1. **First Attempt**: Initialize with CloudKit + App Groups
2. **Fallback**: If that fails, initialize with local storage only

### Checking Logs

Run your app and check the Xcode console for these messages:

**✅ Success (CloudKit working):**
```
✅ SwiftData container initialized with CloudKit sync
```

**⚠️ Fallback (Local storage only):**
```
❌ CloudKit initialization failed: [error details]
⚠️ Falling back to local storage without CloudKit sync...
⚠️ SwiftData container initialized with LOCAL storage only
⚠️ Data will NOT sync via iCloud
```

**Common Error Codes:**

- **134060 / 134020**: App Group or CloudKit entitlement missing/misconfigured
- **134030**: No iCloud account on device
- **260**: File permissions issue (rare)

---

## 🔧 Quick Fixes

### If App Still Crashes:

1. **Clean Build Folder**
   - Xcode → Product → Clean Build Folder (⇧⌘K)

2. **Delete App from Device**
   - Completely remove the app from your test device
   - Rebuild and reinstall

3. **Reset Provisioning Profiles**
   - Xcode → Preferences → Accounts
   - Select your team → Download Manual Profiles
   - Or delete derived data: `~/Library/Developer/Xcode/DerivedData`

4. **Verify Entitlements File**
   - Check `KeepTrack.entitlements` in your project
   - Should contain:
     ```xml
     <key>com.apple.developer.icloud-container-identifiers</key>
     <array>
         <string>iCloud.com.headydiscy.KeepTrack</string>
     </array>
     <key>com.apple.developer.ubiquity-kvstore-identifier</key>
     <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
     <key>com.apple.security.application-groups</key>
     <array>
         <string>group.com.headydiscy.KeepTrack</string>
     </array>
     ```

---

## 📱 Testing Without CloudKit (Development Mode)

If you want to temporarily disable CloudKit for testing:

### Option 1: Comment out CloudKit configuration
In `SwiftDataManager.swift`, the fallback will automatically activate.

### Option 2: Check the flag
```swift
if SwiftDataManager.shared.isCloudKitEnabled {
    // CloudKit is working
    print("Syncing via iCloud")
} else {
    // Local storage only
    print("Local storage only - CloudKit unavailable")
}
```

---

## 🎯 Next Steps

1. **Build and run** on your physical device
2. **Check the console** for initialization messages
3. **Verify iCloud account** is signed in on the device
4. **Review entitlements** in Xcode project

If you still see crashes, paste the **full error message** from the console for further diagnosis.

---

## Additional Resources

- [Apple CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [SwiftData with CloudKit](https://developer.apple.com/documentation/swiftdata/syncing-data-across-devices)
- [App Groups Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
