//
//  UIImage+libpng.h
//  LibPNG
//
//  Created by cntrump@gmail.com on 2018/12/27.
//  Copyright © 2018 vvveiii. All rights reserved.
//

#import <UIKIt/UIKit.h>

@interface UIImage (libpng)

+ (NSData *)dataUsingLibPNGWithImage:(UIImage *)image;

@end
