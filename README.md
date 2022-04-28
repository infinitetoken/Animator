# Animator

Create animated GIF or PNG from a set of images

- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Installation

Animator can be installed using the Swift Package Manager. Add the following to your `Package.swift` file:

```swift

dependencies: [
    .Package(url: "https://github.com/infinitetoken/Animator.git", from: "2.0.0")
]

```

## Usage

```swift

import Animator

let images: [CGImage] = ...
let url: URL = ...

let data = await Animator.animation(from: Animator.frames(from: images), type: .gif)

```

## License

Animator is released under the MIT license. [See LICENSE](https://github.com/infinitetoken/Animator/blob/master/LICENSE) for details.
