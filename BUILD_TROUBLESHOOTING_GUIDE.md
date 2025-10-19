# 🚀 iOS Build Troubleshooting & Setup Guide

## 📋 **Quick Checklist for New iOS Projects**

### ✅ **Essential Files Required:**
- [ ] `YourApp.xcodeproj/project.pbxproj` (valid Xcode project file)
- [ ] `YourApp/YourAppApp.swift` (main app entry point)
- [ ] `YourApp/ContentView.swift` (main view)
- [ ] `YourApp/Assets.xcassets/` (asset catalog with proper structure)
- [ ] `YourApp/Preview Content/Preview Assets.xcassets/` (preview assets)
- [ ] `codemagic.yaml` (CI/CD configuration)

### ✅ **Critical Settings:**
- [ ] Bundle identifier set correctly
- [ ] Xcode project references match actual file locations
- [ ] No git submodules in main app directory
- [ ] CODE_SIGNING settings configured for unsigned builds

---

## 🛠 **Build Error Solutions**

### **Error 1: "The project is damaged and cannot be opened"**
```
-[PBXGroup buildPhase]: unrecognized selector sent to instance
```

**Root Cause:** Corrupted or malformed `project.pbxproj` file

**Solution:**
1. Use Apple-standard object IDs (e.g., `8D1107310486CEB800E47090`)
2. Ensure proper XML structure with correct references
3. Set `CODE_SIGN_STYLE = Manual` in build settings
4. Remove problematic build settings that cause parsing errors

**Prevention:**
- Never manually edit `project.pbxproj` without Xcode
- Use consistent object ID patterns
- Validate project file structure before committing

---

### **Error 2: "Build input files cannot be found"**
```
Build input files cannot be found: '/path/to/YourApp.swift', '/path/to/ContentView.swift'
```

**Root Cause:** Missing Swift source files or git submodule issues

**Solution:**
1. **Check for git submodules:** Look for `.git` directories in subdirectories
   ```bash
   find . -name ".git" -type d
   ```
2. **Remove embedded git repos:**
   ```bash
   rm -rf YourApp/.git
   git rm --cached YourApp
   git add YourApp/
   ```
3. **Ensure source files exist:**
   ```swift
   // YourAppApp.swift
   import SwiftUI
   
   @main
   struct YourAppApp: App {
       var body: some Scene {
           WindowGroup {
               ContentView()
           }
       }
   }
   ```

**Prevention:**
- Always check directory structure before committing
- Avoid nested git repositories
- Use `git status` to verify all files are tracked

---

### **Error 3: "No matching profiles found" / "No Team Found in Archive"**
```
No matching profiles found for bundle identifier "com.example.app"
exportArchive No Team Found in Archive
```

**Root Cause:** Code signing requirements even for unsigned builds

**Solution:**
Use manual IPA creation instead of Apple's export process:
```bash
# Extract .app from archive
mkdir -p build/ios/ipa/Payload
cp -r build/YourApp.xcarchive/Products/Applications/YourApp.app build/ios/ipa/Payload/

# Create IPA manually
cd build/ios/ipa
zip -r YourApp.ipa Payload/
```

**Prevention:**
- Use manual IPA creation for unsigned builds
- Set `CODE_SIGNING_REQUIRED=NO` and `CODE_SIGNING_ALLOWED=NO`
- Avoid Apple's export process for development builds

---

### **Error 4: "Failed to read file attributes" (Asset Catalogs)**
```
Failed to read file attributes for "Assets.xcassets"
```

**Root Cause:** Missing or incorrectly structured asset catalogs

**Solution:**
Create proper asset catalog structure:
```
Assets.xcassets/
├── Contents.json
├── AppIcon.appiconset/
│   └── Contents.json
└── AccentColor.colorset/
    └── Contents.json
```

**Contents.json templates:**
```json
// Assets.xcassets/Contents.json
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

// AppIcon.appiconset/Contents.json  
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

---

### **Error 5: "One of the paths in DEVELOPMENT_ASSET_PATHS does not exist"**
```
ValidateDevelopmentAssets: No such file or directory
```

**Root Cause:** SwiftUI preview assets validation for release builds

**Solution:**
Remove or disable development asset paths for release builds:
```yaml
# In project.pbxproj, remove or set:
DEVELOPMENT_ASSET_PATHS = "";
ENABLE_PREVIEWS = NO;
```

**Prevention:**
- Separate development and release build configurations
- Disable previews for release builds
- Use conditional asset inclusion

---

## 📱 **Codemagic Configuration Best Practices**

### **Minimal Working codemagic.yaml:**
```yaml
workflows:
  ios-unsigned-build:
    name: iOS Unsigned Build
    max_build_duration: 60
    instance_type: mac_mini_m1
    environment:
      vars:
        XCODE_PROJECT: "YourApp.xcodeproj"
        XCODE_SCHEME: "YourApp"
        BUNDLE_ID: "com.yourcompany.yourapp"
      xcode: latest
    scripts:
      - name: Build unsigned archive
        script: |
          xcodebuild archive \
            -project "$XCODE_PROJECT" \
            -scheme "$XCODE_SCHEME" \
            -configuration Release \
            -destination "generic/platform=iOS" \
            -archivePath "$PWD/build/YourApp.xcarchive" \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            PROVISIONING_PROFILE=""
      - name: Create IPA manually
        script: |
          mkdir -p "$PWD/build/ios/ipa/Payload"
          cp -r "$PWD/build/YourApp.xcarchive/Products/Applications/YourApp.app" "$PWD/build/ios/ipa/Payload/"
          cd "$PWD/build/ios/ipa"
          zip -r YourApp.ipa Payload/
    artifacts:
      - build/ios/ipa/*.ipa
      - build/YourApp.xcarchive
```

### **Critical Configuration Points:**
1. **Never include App Store Connect integrations** for unsigned builds
2. **Use manual IPA creation** instead of `xcodebuild -exportArchive`
3. **Set all code signing flags** to disabled
4. **Use specific Xcode versions** to avoid compatibility issues

---

## 🔍 **Debugging Commands**

### **Check Project Structure:**
```bash
# Verify all required files exist
ls -la YourApp/
find . -name "*.swift" | head -10
find . -name "*.xcodeproj"

# Check for git submodules
find . -name ".git" -type d

# Validate asset catalogs
find . -name "*.xcassets" -exec ls -la {} \;
```

### **Validate Xcode Project:**
```bash
# Check if project can be parsed
xcodebuild -list -project YourApp.xcodeproj

# Verify build settings
xcodebuild -project YourApp.xcodeproj -target YourApp -showBuildSettings | grep -i sign
```

### **Test Archive Creation:**
```bash
# Test archive step independently
xcodebuild archive \
  -project YourApp.xcodeproj \
  -scheme YourApp \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath /tmp/test.xcarchive \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

---

## 📊 **Success Indicators**

### **Build Process Should Show:**
```
✅ SwiftCompile normal arm64 Compiling YourApp.swift, ContentView.swift
✅ GenerateAssetSymbols (no errors)
✅ LinkAssetCatalog (completed)
✅ Ld /path/to/YourApp.app/YourApp normal
✅ CopySwiftLibs
✅ ** ARCHIVE SUCCEEDED **
```

### **Final IPA Should Be:**
- Size > 1MB (indicates successful build with assets)
- Valid ZIP structure when examined
- Contains `Payload/YourApp.app/` directory
- App executable present and not empty

---

## 🚨 **Emergency Fixes**

### **Quick Fix for Corrupted Project:**
1. Backup current `project.pbxproj`
2. Create minimal working project file
3. Use Apple-standard object IDs
4. Set manual code signing
5. Remove problematic build settings

### **Quick Fix for Missing Files:**
1. Check git status: `git status`
2. Remove git submodules: `rm -rf YourApp/.git`
3. Re-add files: `git add YourApp/`
4. Verify files exist: `ls -la YourApp/*.swift`

### **Quick Fix for Asset Issues:**
1. Create minimal asset structure
2. Use provided JSON templates
3. Disable previews for release builds
4. Remove development asset paths

---

## 📚 **Reference Links**

- [Apple Developer Documentation - Building and Running Your App](https://developer.apple.com/documentation/xcode/building-and-running-your-app)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Codemagic iOS Documentation](https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/)

---

## 💡 **Pro Tips**

1. **Always test locally first** before pushing to CI/CD
2. **Use minimal configurations** and add complexity gradually  
3. **Keep backups** of working `project.pbxproj` files
4. **Document project-specific settings** for your team
5. **Use manual IPA creation** for unsigned builds to avoid Apple's restrictions

---

*This guide was created based on real troubleshooting experience. Keep it updated as you encounter new issues!*
