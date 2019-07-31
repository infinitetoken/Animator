# Animator

Create movies and animated GIF's from a set of images

- [Usage](#usage)
- [License](#license)

## Usage

```swift

import Animator

let images: [CGImage] = ...
let url: URL = ...

Animator.movie(from: Animator.frames(from: images), size: CGSize(width: 480, height: 320), outputURL: url) { (error) in
    if let error = error {
        // Error
    }
    // It worked! Do something with the file at url...
}

Animator.animation(from: Animator.frames(from: images), size: CGSize(width: 480, height: 320), outputURL: url) { (error) in
    if let error = error {
        // Error
    }
    // It worked! Do something with the file at url...
}

```

## License

Animator is released under the MIT license. [See LICENSE](https://github.com/infinitetoken/Animator/blob/master/LICENSE) for details.
