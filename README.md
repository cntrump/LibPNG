## LibPNG

an Objective-C wrapper for libpng.

`UIImagePNGRepresentation` can not handle larger image, so you need libpng.

useage:

encode UIImage to PNG data:

```objc
UIImage *image = ...;
NSData *pngData = [UIImage dataUsingLibPNGWithImage:image];
```
