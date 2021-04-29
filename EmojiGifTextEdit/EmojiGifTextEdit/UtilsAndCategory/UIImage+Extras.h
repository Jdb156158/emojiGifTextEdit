//
//  UIImage+Extras.h
//  EmojiGifTextEdit
//
//  Created by db J on 2021/4/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extras)
+ (UIImage *)imageByCroppingCGImage:(CGImageRef)cgImage toSize:(CGSize)size;
+ (UIImage *)imageByCroppingVideoFrameCGImage:(CGImageRef)cgImage toSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
