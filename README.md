#  **UniversalShimmer — iOS Shimmer & Skeleton Loader (SwiftUI)**

UniversalShimmer is a lightweight, production-grade shimmer engine built for SwiftUI.
It provides:

 **Instagram-quality shimmer animation**
 **Premium skeleton loading placeholders**
 **Super easy setup with Swift Package Manager**
 **Customizable colors, speed, and direction**

Works on:

* iOS 14+
* SwiftUI
* Any View / Any Shape
* Any Layout (List, VStack, HStack, Grid)

---

#  **1. Installation (Swift Package Manager)**

### Step 1 — Open Xcode

### Step 2 — `File → Add Packages…`

### Step 3 — Paste the package URL:

```
https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_UniversalShimmer.git
```

### Step 4 — Select branch:

```
Branch → Stages
```

### Step 5 — Add to your app target → **Add Package**

Done! 

---

#  **2. Import the Framework**

```swift
import UniversalShimmer
```

---

#  **3. Basic Shimmer Example**

```swift
struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {

            Text("Excelsior Shimmer")
                .font(.title)
                .shimmer(active: isLoading)

            Button(isLoading ? "Stop Shimmer" : "Start Shimmer") {
                withAnimation { isLoading.toggle() }
            }
        }
        .padding()
    }
}
```

---

#   **4. Skeleton Loading Example (Best Practice)**

Use `.shimmerSkeleton(active:)` to hide real content and show shimmer placeholder.

```swift
struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {

            Text("Excelsior Shimmer")
                .font(.title)
                .shimmerSkeleton(active: isLoading)

            Text("Username")
                .font(.title)
                .shimmerSkeleton(active: isLoading)

            Button(isLoading ? "Stop Shimmer" : "Start Shimmer") {
                isLoading.toggle()
            }
        }
        .padding()
    }
}
```

### ✔ Content hidden

### ✔ Shimmer shows instead

### ✔ Real content appears when loading = false

---

#  **5. Optional Skeleton Components**

(Only include if you kept them in your package)

```swift
SkeletonText(width: 200, height: 20)
SkeletonAvatar(size: 60)
SkeletonCard()
```

Example:

```swift
if loading {
    SkeletonText(width: 200)
    SkeletonAvatar(size: 70)
} else {
    Text("Loaded Content")
}
```

---

#  **6. Customize the Shimmer Animation**

```swift
let config = ShimmerConfig(
    baseColor: .gray.opacity(0.3),
    highlightColor: .white.opacity(0.9),
    speed: 1.2,
    opacity: 1.0,
    direction: .leftToRight
)

Text("Custom Shimmer")
    .shimmer(active: true, config: config)
```

---

#  **7. Troubleshooting**

###  No Such Module 'UniversalShimmer'

Fix:

1. Ensure package is added to target
2. Clean build:

```
Shift + Command + K
```

3. Rebuild:

```
Command + B
```

---

###  Shimmer not animating

Make sure:

```swift
withAnimation {
    isLoading.toggle()
}
```

Animation requires SwiftUI animation context.

---

#  **8. Real-World Example: API Loading + Skeleton**

```swift
struct JobLoadingView: View {
    @State private var loading = true

    var body: some View {
        VStack(spacing: 20) {
            if loading {
                SkeletonText(width: 250)
                SkeletonAvatar(size: 80)
            } else {
                Text("Job Title Loaded")
                Image("profilePic")
            }

            Button("Toggle Loading") {
                loading.toggle()
            }
        }
    }
}
```

---

# **Done!**

 