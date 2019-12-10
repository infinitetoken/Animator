# Animator

Create movies and animated GIF's from a set of images

- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Installation

Animator can be installed using the Swift Package Manager. Add the following to your `Package.swift` file:

```swift

dependencies: [
    .Package(url: "https://github.com/infinitetoken/Animator.git", from: "1.0.0")
]

```

## Usage

```swift

import Animator

let images: [CGImage] = ...
let url: URL = ...

Animator.movie(from: Animator.frames(from: images), outputURL: url) { (error) in
    if let error = error {
        // Error
    }
    // It worked! Do something with the file at url...
}

Animator.animation(from: Animator.frames(from: images), outputURL: url) { (error) in
    if let error = error {
        // Error
    }
    // It worked! Do something with the file at url...
}

```

## License

Animator is released under the MIT license. [See LICENSE](https://github.com/infinitetoken/Animator/blob/master/LICENSE) for details.
