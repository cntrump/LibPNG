//
//  UIImage+libpng.m
//  LibPNG
//
//  Created by cntrump@gmail.com on 2018/12/27.
//  Copyright © 2018 vvveiii. All rights reserved.
//

#import "UIImage+libpng.h"
#import <zlib.h>
#import "png.h"

static unsigned char *BitmapFromCGImage(CGImageRef imageRef) {
    if (!imageRef) {
        return NULL;
    }

    size_t w = CGImageGetWidth(imageRef);
    size_t h = CGImageGetHeight(imageRef);
    unsigned char *buf = (unsigned char *)malloc(w * 4 * h);
    if (!buf) {
        return NULL;
    }

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(buf, w, h, 8, w * 4, colorSpaceRef, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    if (!context) {
        CGColorSpaceRelease(colorSpaceRef);
        free(buf);

        return NULL;
    }

    CGContextDrawImage(context, CGRectMake(0, 0, w, h), imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(context);

    return buf;
}

static void PNGReadAndWriteCallback(png_structp png_ptr, png_bytep bytes, size_t bytes_len) {
    NSMutableData *pngData = (__bridge NSMutableData *)png_get_io_ptr(png_ptr);
    [pngData appendBytes:bytes length:bytes_len];
}

static NSData *PNGDataFromBitmap(unsigned char *bitmap, png_uint_32 width, png_uint_32 height) {
    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop info_ptr = png_create_info_struct(png_ptr);

    setjmp(png_jmpbuf(png_ptr));

    png_set_compression_level(png_ptr, Z_BEST_COMPRESSION);
    png_set_compression_mem_level(png_ptr, 8);
    png_set_compression_strategy(png_ptr, Z_DEFAULT_STRATEGY);
    png_set_compression_window_bits(png_ptr, 15);
    png_set_compression_method(png_ptr, 8);
    png_set_compression_buffer_size(png_ptr, 8192);

    png_set_IHDR(png_ptr,
                 info_ptr,
                 width,
                 height,
                 8,
                 PNG_COLOR_TYPE_RGBA,
                 PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT,
                 PNG_FILTER_TYPE_DEFAULT);

    png_bytepp row_pointers = (png_bytepp)png_malloc(png_ptr, sizeof(png_bytep) * height);
    if (!row_pointers) {
        png_destroy_write_struct(&png_ptr, &info_ptr);

        return nil;
    }

    unsigned long long bytesPerRow = width * 4;
    for (png_uint_32 i = 0; i < height; i++) {
        row_pointers[i] = &bitmap[i * bytesPerRow];
    }

    NSMutableData *pngData = NSMutableData.data;
    png_set_write_fn(png_ptr, (__bridge png_voidp)pngData, &PNGReadAndWriteCallback, NULL);

    png_set_rows(png_ptr, info_ptr, row_pointers);
    png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

    png_free(png_ptr, row_pointers);
    png_destroy_write_struct(&png_ptr, &info_ptr);

    return pngData;
}

@implementation UIImage (libpng)

+ (NSData *)dataUsingLibPNGWithImage:(UIImage *)image {
    @autoreleasepool {
        CGImageRef imageRef = image.CGImage;

        size_t w = CGImageGetWidth(imageRef);
        size_t h = CGImageGetHeight(imageRef);

        unsigned char *buf = BitmapFromCGImage(imageRef);
        if (!buf) {
            return nil;
        }

        NSData *pngData = PNGDataFromBitmap(buf, (png_uint_32)w, (png_uint_32)h);
        free(buf);

        if (pngData.length == 0) {
            return nil;
        }

        return pngData;
    }
}

@end
