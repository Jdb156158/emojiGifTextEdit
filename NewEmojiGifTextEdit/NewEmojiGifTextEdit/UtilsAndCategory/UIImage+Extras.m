//
//  UIImage+Extras.m
//  EmojiGifTextEdit
//
//  Created by db J on 2021/4/29.
//

#import "UIImage+Extras.h"

@implementation UIImage (Extras)
+ (UIImage *)imageByCroppingCGImage:(CGImageRef)cgImage toSize:(CGSize)size {
    double refWidth = CGImageGetWidth(cgImage);
    double refHeight = CGImageGetHeight(cgImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

+ (UIImage *)imageByCroppingVideoFrameCGImage:(CGImageRef)cgImage toSize:(CGSize)size {
    double width = CGImageGetWidth(cgImage);
    double height = CGImageGetHeight(cgImage);
    double newCropWidth, newCropHeight;
    
    if (width < height) {
        if (width < size.width) {
            newCropWidth = size.width;
        } else {
            newCropWidth = width;
        }
        newCropHeight = (newCropWidth * size.height)/size.width;
    } else {
        if (height < size.height) {
            newCropHeight = size.height;
        } else {
            newCropHeight = height;
        }
        newCropWidth = (newCropHeight * size.width)/size.height;
    }
    
    double x = width / 2.0 - newCropWidth / 2.0;
    double y = height / 2.0 - newCropHeight / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    UIGraphicsBeginImageContext(size);
    [croppedImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}
@end
