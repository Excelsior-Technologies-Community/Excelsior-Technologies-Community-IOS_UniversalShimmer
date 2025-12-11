# UniversalShimmer – SwiftUI Shimmer & Skeleton Loader

UniversalShimmer is a lightweight shimmer and skeleton-loading framework for SwiftUI.
It helps display loading placeholders while fetching data from a remote API or local database.

Key features:

• Shimmer effect for any SwiftUI view
• Skeleton placeholders for text, images, and shapes
• Configurable colors, speed, and direction
• Works on iOS 14+
• Zero external dependencies

---

# 1. Installation (Swift Package Manager)

1. Open Xcode
2. Go to: `File → Add Packages…`
3. Enter the package URL:

```
https://github.com/Excelsior-Technologies-Community/IOS_UniversalShimmer.git
```

4. Select the `Development` branch
5. Add the package to your app target

---

# 2. Import the Framework

```swift
import UniversalShimmer
```

---

# 3. Using Shimmer with Skeleton Placeholders

The modifier `.shimmerSkeleton(active:)` hides the real content and shows a shimmer effect while loading.

Example placeholder:

```swift
RoundedRectangle(cornerRadius: 6)
    .frame(height: 24)
    .shimmerSkeleton(active: true)
```

---

# 4. Customizing the Shimmer

Shimmer settings can be modified using `ShimmerConfig`.

```swift
let config = ShimmerConfig(
    baseColor: Color.gray.opacity(0.25),
    highlightColor: Color.white.opacity(0.7),
    speed: 1.2,
    opacity: 1.0,
    direction: .leftToRight
)
```

Apply custom config:

```swift
Text("Loading")
    .shimmerSkeleton(active: true, config: config)
```

---

# 5. Troubleshooting

### Shimmer not visible

Ensure placeholders have a fixed width or height.

### "No such module 'UniversalShimmer'"

Confirm that the package is added to the correct target.

### Animation not running

Shimmer requires the SwiftUI rendering cycle to remain active.

---

# 6. Full Working Example (API Loading + Shimmer)

This is the recommended implementation that uses shimmer while an API call loads content.

```swift
import SwiftUI
import UniversalShimmer

struct ContentView: View {
    @StateObject private var vm = PostViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Title Shimmer
            Group {
                if let title = vm.post?.title {
                    Text(title)
                        .font(.title)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(height: 24)
                        .shimmerSkeleton(active: vm.isLoading)
                }
            }

            // Body shimmer
            Group {
                if let body = vm.post?.body {
                    Text(body)
                        .font(.body)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 60)
                        .shimmerSkeleton(active: vm.isLoading)
                }
            }

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            vm.fetchPost()
        }
    }
}

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
}

struct UserResponse: Codable {
    let data: User
}

struct User: Codable {
    let id: Int
    let email: String
    let first_name: String
    let last_name: String
    let avatar: String
}

import Foundation

class PostViewModel: ObservableObject {
    @Published var post: Post?
    @Published var isLoading = true
    @Published var errorMessage: String?

    func fetchPost() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        post = nil

        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {   // shimmer visibility delay
                do {
                    self.post = try JSONDecoder().decode(Post.self, from: data)
                } catch {
                    self.errorMessage = "Decoding error: \(error)"
                }

                self.isLoading = false
            }
        }.resume()
    }
}
```
 