## LibPNG

an Objective-C wrapper for libpng.

`UIImagePNGRepresentation` can not handle larger image, so you need libpng.

useage:

```objc
UIImage *image = ...;
NSData *pngData = [UIImage dataUsingLibPNGWithImage:image];
```
