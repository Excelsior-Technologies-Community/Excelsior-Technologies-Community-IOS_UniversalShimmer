
# 🎯 **FULL STEP-BY-STEP DEVELOPER GUIDE**

### *How Any Developer Can Add UniversalShimmer to Their Project (SPM)*

This is written like a proper README section — you can paste it directly into your own repo’s README.md.

---

# 📦 UniversalShimmer — Installation Guide (Swift Package Manager)

UniversalShimmer is distributed using **Swift Package Manager**, the official dependency manager by Apple.
Any developer can add it to their iOS project by following the steps below.

---

# ✅ **1. Requirements**

* **Xcode 14 or higher**
* **iOS 14+ deployment target**
* Internet connection
* Swift Package Manager enabled

---

# 🔧 **2. Adding the Package to Your Project**

#### **Step 1 — Open Xcode**

Open your existing iOS project (.xcodeproj or .xcworkspace).

---

#### **Step 2 — Add Swift Package**

In the top menu:

```
File → Add Packages…
```

This opens the Swift Package Manager window.

---

#### **Step 3 — Enter the Package URL**

Paste this URL:

```
https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_UniversalShimmer.git
```

Press **Enter**.

Xcode will fetch the package details.

---

#### **Step 4 — Select the Correct Branch**

Choose:

```
Branch → Stages
```

Because the shimmer code currently lives inside the **Stages** branch.

---

#### **Step 5 — Add to Your App Target**

You will see your app's target (example: `MyApp`).

Make sure the checkbox is ON.

Click:

```
Add Package
```

Done! 🎉
UniversalShimmer is now connected to your project.

---

# 📥 **3. Importing the Framework**

In any Swift file where you want to use shimmer:

```swift
import UniversalShimmer
```

---

# ✨ **4. Basic Usage Example**

```swift
import SwiftUI
import UniversalShimmer

struct ContentView: View {
    @State private var loading = true

    var body: some View {
        VStack(spacing: 20) {

            Text("Excelsior Shimmer")
                .font(.title)
                .shimmer(active: loading)

            Button(loading ? "Stop Shimmer" : "Start Shimmer") {
                loading.toggle()
            }
        }
        .padding()
    }
}
```

---

# 🧩 **5. Using Built-in Skeleton Components**

UniversalShimmer provides premade UI skeletons:

### Text skeleton

```swift
SkeletonText(width: 200, height: 20)
```

### Avatar skeleton

```swift
SkeletonAvatar(size: 60)
```

### Card skeleton

```swift
SkeletonCard()
```

Example:

```swift
if loading {
    SkeletonText(width: 200)
    SkeletonAvatar(size: 70)
} else {
    Text("Loaded content goes here")
}
```

---

# ⚡ **6. Customizing the Shimmer Effect**

You can control speed, direction, colors, opacity:

```swift
let config = ShimmerConfig(
    baseColor: .gray.opacity(0.3),
    highlightColor: .white.opacity(0.8),
    speed: 1.1,
    opacity: 1.0,
    direction: .leftToRight
)

Text("Custom Shimmer")
    .shimmer(active: true, config: config)
```

---

# 🛠 **7. Troubleshooting**

### 🔹 Error: *"No such module 'UniversalShimmer'"*

Fix:

1. Go to Project → Your App Target → **Frameworks, Libraries, and Embedded Content**
2. Confirm: `UniversalShimmer` appears.
3. Clean build folder:

   ```
   Shift + Command + K
   ```
4. Build again:

   ```
   Command + B
   ```

---

### 🔹 Error: *"Package.swift doesn't exist"*

This happens if:

* Wrong URL was used
* Wrong branch was selected
* Your local network blocked GitHub

Make sure you used the correct URL:

```
https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_UniversalShimmer.git
```

---

# 📘 **8. Example: Real API Loading + Shimmer**

```swift
struct JobLoadingView: View {
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                SkeletonText(width: 250)
                SkeletonAvatar(size: 80)
            } else {
                Text("Job Title Loaded")
                Image("profilePic")
            }

            Button("Toggle Loading") {
                isLoading.toggle()
            }
        }
        .padding()
    }
}
```

---

# 🎉 You Are Done!
 
