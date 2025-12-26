# UniversalShimmer – SwiftUI Universal Shimmer Loader

**UniversalShimmer** is a lightweight SwiftUI shimmer loader that works with **any view**
(Text, Image, Card, Stack, Custom UI) and integrates cleanly with **API loading states**.

It is designed to be:

* 🔹 Content-agnostic
* 🔹 API-driven
* 🔹 Easy to integrate
* 🔹 Safe for production

---

## ✨ Features

* Works on **any SwiftUI View**
* No skeleton duplication
* Driven by `Bool` (`isLoading`)
* Automatic start & stop
* Customizable mask, color, radius
* Works with real API calls
* iOS 14+

---

## 📦 Installation (Swift Package Manager)

### Add via Xcode

1. Open your project in Xcode
2. Go to **File → Add Packages…**
3. Paste the repository URL:

```
https://github.com/Excelsior-Technologies-Community/IOS_UniversalShimmer.git
```

4. Select the **Development** branch
5. Add **UniversalShimmer** to your app target

---

## 📥 Import

```swift
import UniversalShimmer
```

---

## 🧠 How UniversalShimmer Works (Important)

> **Shimmer is applied in the View**
> **API logic lives in the ViewModel**
> **A single `Bool` controls shimmer visibility**

You **never call shimmer inside the API file**.

---

## ✅ Basic Usage

```swift
Text("Loading")
    .shimmerize(active: true)
```

---

## ✅ Apply to Any View

### Text

```swift
Text("Loading title")
    .shimmerize(active: isLoading)
```

### Image

```swift
Image(systemName: "photo")
    .shimmerize(active: isLoading)
```

### Card / Container

```swift
VStack { ... }
.shimmerize(active: isLoading)
```

---

## 🔧 Customization Options

```swift
.shimmerize(
    active: isLoading,
    shouldAddHideMask: true,
    hideMaskColor: Color.gray.opacity(0.3),
    hideMaskRadius: 16,
    gradient: nil,
    animationDuration: 1.7,
    animationDelay: 0.5
)
```

---

## 🚀 Recommended Pattern (API + Shimmer)

### 1️⃣ ViewModel (API only – no shimmer)

```swift
final class PostViewModel: ObservableObject {

    @Published var post: Post?
    @Published var isLoading = true
    @Published var errorMessage: String?

    func fetchPost() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else {
            errorMessage = "Invalid URL"
            return
        }

        errorMessage = nil
        isLoading = true
        post = nil

        URLSession.shared.dataTask(with: url) { data, _, error in

            if let error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }

            guard let data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                do {
                    self.post = try JSONDecoder().decode(Post.self, from: data)
                } catch {
                    self.errorMessage = "Decoding error"
                }
                self.isLoading = false
            }
        }.resume()
    }
}
```

---

### 2️⃣ ContentView (Connect shimmer to API state)

```swift
import SwiftUI
import UniversalShimmer

struct ContentView: View {

    @StateObject private var viewModel = PostViewModel()

    var body: some View {
        VStack(spacing: 20) {

            // Any content (card / text / image)
            VStack(alignment: .leading, spacing: 12) {

                Text(viewModel.post?.title ?? "Loading title")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(viewModel.post?.body ?? "Loading body text goes here")
                    .font(.body)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )

            // 🔥 Shimmer connected to API loading state
            .shimmerize(
                active: viewModel.isLoading,
                shouldAddHideMask: true,
                hideMaskColor: Color.gray.opacity(0.3),
                hideMaskRadius: 16
            )

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchPost()
        }
    }
}
```
 
