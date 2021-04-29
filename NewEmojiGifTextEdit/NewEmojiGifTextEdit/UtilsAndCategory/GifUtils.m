//
//  GifUtils.m
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import "GifUtils.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation GifUtils
#pragma mark - 公开 video --> img
+ (void)imgsWithVideoAsset:(AVAsset *)avasset withTimeInterval:(float)interval withTimeRange:(CMTimeRange)range completion:(void(^)(NSMutableArray *images))completionBlock {
    NSMutableArray *resultImages = [NSMutableArray array];
    
    if (interval <= 0) {
        interval = 0.5;
    }
    
    CMTime cmDuration = avasset.duration;
    int startSeconds = 0;
    
    if (range.duration.value != 0) {
        cmDuration = range.duration;
        startSeconds = (int)(range.start.value / range.start.timescale);
    }
    
    float videoLength = (float)cmDuration.value / cmDuration.timescale;
    NSUInteger frameCount = videoLength / interval;
//    frameCount = frameCount > 30 ? 30 : frameCount;
    //确定时间间隔 timePoints->图片张数
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int i = 0; i<frameCount; i++) {
        float point = i * interval + startSeconds;
        CMTime curTime = CMTimeMakeWithSeconds(point, 600);
        [timePoints addObject:[NSValue valueWithCMTime:curTime]];
    }
    
    if (timePoints.count == 0) {
        completionBlock(nil);
    }
    
    CGFloat pixel;
    if (timePoints.count <= PIXEL_VIDEOGIF_SEGEMENT_NUMBER) {
        pixel = MAX_PIXEL_VIDEOGIF_LESSIMAGE;
    } else {
        pixel = MAX_PIXEL_VIDEOGIF;
    }
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:avasset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = [SystemUtils sizeMaxWidth:MAX_PIXEL_VIDEOGIF withAvAsset:avasset];
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    
    NSLock *locker = [[NSLock alloc] init];
    __block NSUInteger blockCount = 0;
    [generator generateCGImagesAsynchronouslyForTimes:timePoints completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        [locker lock];
        blockCount ++;
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"无法生成图片, error:%@", error);
        }else {
            UIImage *frameImg =[UIImage imageWithCGImage:image];
            NSString *imgPath = [NSString stringWithFormat:@"%@%ld.png", VIDEO_IMGPATH, blockCount];
            NSData *imgData = UIImageJPEGRepresentation(frameImg, 1.0);
            [SystemUtils deleteFileAtPath:imgPath];
            [imgData writeToFile:imgPath atomically:YES];
            [resultImages addObject:imgPath];
            frameImg = nil;
        }
        
        if (blockCount == timePoints.count) {
            completionBlock(resultImages);
        }
        [locker unlock];
    }];
}

#pragma mark - 公开 img --> gif

// 取单张图片 图片不缩放的情况下 导出GIF
+ (void)gifWithImages:(NSArray *)images withDelay:(float)delay targetPath:(NSString *)targetPath markImage:(UIImage *)markImage  markTextIV:(UIImage *)markTextIV markFrame:(CGRect)markFrame markTextIVFrame:(CGRect)markTextIVFrame isRecord:(BOOL)isRecord isPhotoToGif:(BOOL)isPhotoToGif{
    NSArray *resultImgPaths = [self addMarkToOriginImgs:images markImage:markImage isRecord:isRecord markIV:markTextIV markFrame:markFrame markTextIVFrame:markTextIVFrame isPhotoToGif:isPhotoToGif];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:targetPath], kUTTypeGIF, resultImgPaths.count, NULL);
    
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @{(__bridge id)kCGImagePropertyGIFDelayTime : @(delay)},
                                     (__bridge id)kCGImagePropertyGIFDictionary, nil];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @{(__bridge id)kCGImagePropertyGIFLoopCount : @(0)}, (__bridge id)kCGImagePropertyGIFDictionary,
                                   [NSNumber numberWithInt:0.1], kCGImageDestinationLossyCompressionQuality, nil];
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    
    for (int i = 0; i < resultImgPaths.count; i ++) {
        NSString *eachPath = resultImgPaths[i];
        UIImage *eachImg = [UIImage imageWithContentsOfFile:eachPath];
        
        if (i == 0) {
            CGSize imageSize  =  eachImg.size;
            NSLog(@"origalSize =%@ newsSize = null ,scale = 无 ",NSStringFromCGSize(imageSize));
        }
        ////        CGImageDestinationAddImage(destination,eachImg.CGImage, (__bridge CFDictionaryRef)frameProperties); //hanli;
        CGImageDestinationAddImage(destination, eachImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    //
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
}

+ (void)gifWithImages:(NSArray *)images withDelay:(float)delay targetPath:(NSString *)targetPath{
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:targetPath], kUTTypeGIF, images.count, NULL);
    
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @{(__bridge id)kCGImagePropertyGIFDelayTime : @(delay)},
                                     (__bridge id)kCGImagePropertyGIFDictionary, nil];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @{(__bridge id)kCGImagePropertyGIFLoopCount : @(0)}, (__bridge id)kCGImagePropertyGIFDictionary,
                                   [NSNumber numberWithInt:0.1], kCGImageDestinationLossyCompressionQuality, nil];
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    
    for (int i = 0; i < images.count; i ++) {
        NSString *eachPath = images[i];
        UIImage *eachImg = [UIImage imageWithContentsOfFile:eachPath];

        CGImageDestinationAddImage(destination,eachImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    //
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
}

#pragma mark - 公开 从GIF中提取图片

+ (void)imgsFromGifWithData:(NSData *)data textDictArray:(NSArray *)textArray completeHnadler:(void(^)(float imgDelay, NSMutableArray *images))completeHandler {
    if (!data) {
        return;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray array];
    for (size_t i = 0; i < count; i++) {
        
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        UIImage *img = [UIImage imageWithCGImage:image];
        if (img.size.width > MAX_PIXEL_VIDEOGIF) {
            CGSize targetSize = [SystemUtils sizeMaxWidth:MAX_PIXEL_VIDEOGIF withSize:img.size];
            img = [UIImage imageByCroppingCGImage:image toSize:targetSize];
        }
        
        for (int texti = 0; texti<textArray.count; texti++) {
            NSDictionary *dict = textArray[texti];
            NSInteger start = [dict[@"startFrame"] integerValue];
            NSInteger end = [dict[@"endFrame"] integerValue];
            NSString *text = dict[@"sample"];
            if (i<=end && i>=start && text.length>0) {
                img = [self watermarkImage:img withName:text];
            }
        }
        
        CGImageRelease(image);
        
        NSString *imgPath = [NSString stringWithFormat:@"%@%zu.png", FINAL_IMGPATH, i]; //处理完后生成图片在沙盒中保存的地址
        @autoreleasepool {
            NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
            [SystemUtils deleteFileAtPath:imgPath];
            [imgData writeToFile:imgPath atomically:YES];
            [images addObject:imgPath];
            img = nil;
        }
        
    }
    CGFloat delayTime = 0.1;
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    if (properties) {
        CFDictionaryRef gifProperties;
        BOOL result = CFDictionaryGetValueIfPresent(properties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties);
        if (result) {
            const void *durationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &durationValue)) {
                delayTime = [(__bridge NSNumber *)durationValue doubleValue];
                if (delayTime < 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &durationValue)) {
                        delayTime = [(__bridge NSNumber *)durationValue doubleValue];
                    }
                }
            }
        }
    }
    CFRelease(source);
    completeHandler(delayTime, images);
}



// scale 缩放单张图片的比例控制  GIF导出的大小
//+ (void)gifWithImages:(NSArray *)images scale:(CGFloat)scale withDelay:(float)delay targetPath:(NSString *)targetPath withMuArr:(NSMutableArray *)textfieldDictArr markImage:(UIImage *)markImage isRecord:(BOOL)isRecord markIV:(UIView *)markIV markFrame :(CGRect)markFrame isPhotoToGif:(BOOL)isPhotoToGif {
//    NSArray *resultImgPaths = [self addMarkToOriginImgs:images markImage:markImage isRecord:isRecord markIV:markIV markFrame:markFrame isPhotoToGif:isPhotoToGif];
//    
//    scale = scale *1.25;
//    
//    scale > 1.0 ? scale = 1.0: 0;
//    
//    
//    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:targetPath], kUTTypeGIF, resultImgPaths.count, NULL);
//    
//    NSDictionary *frameProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     @{(__bridge id)kCGImagePropertyGIFDelayTime : @(delay)},
//                                     (__bridge id)kCGImagePropertyGIFDictionary, nil];
//    NSDictionary *gifProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   @{(__bridge id)kCGImagePropertyGIFLoopCount : @(0)}, (__bridge id)kCGImagePropertyGIFDictionary,
//                                   [NSNumber numberWithInt:0.1], kCGImageDestinationLossyCompressionQuality, nil];
//    CGFloat limitInch = 1000;
//    
//    UIImage * sampleImg = [UIImage imageWithContentsOfFile:resultImgPaths[0]];
//    
//    CGFloat limitScale = [self getFitScaleWithLimitNumber:limitInch withImage:sampleImg];
//    
//    scale = [self getFinalScaleWithOrignalScale:scale addToWechatLimitScale:limitScale];
//    
//    if (scale < 0.12) {
//        
//        scale = 0.12;
//    }
//    
//    
//    
//    for (int i = 0; i < resultImgPaths.count; i ++) {
//        NSString *eachPath = resultImgPaths[i];
//
//        UIImage *eachImg = [UIImage imageWithContentsOfFile:eachPath];
//        CGImageRef refImg = eachImg.CGImage;
//        
//        CGSize size = CGSizeMake(CGImageGetWidth(refImg), CGImageGetHeight(refImg));
//        
//        CGImageRef imageRef = [self nov_createImageWithScale:scale  imageRe:eachImg.CGImage];
//        
//        if (i == 0) {
//            
//            NSLog(@"没有缩放之前的大小 refImgsize = %@,eachImgSize = %@",NSStringFromCGSize(size),NSStringFromCGSize(eachImg.size));
//            
//            CGSize imageSize  =  eachImg.size;
//            CGSize newsSize  = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
//            
//            NSLog(@"走到加水印最终 origalSize =%@ newsSize = %@ ,最终scale = %f ",NSStringFromCGSize(imageSize) ,NSStringFromCGSize(newsSize),scale);
//        }
//        
////        CGImageDestinationAddImage(destination,eachImg.CGImage, (__bridge CFDictionaryRef)frameProperties); //hanli;
//        CGImageDestinationAddImage(destination, imageRef, (__bridge CFDictionaryRef)frameProperties);
//        eachImg = nil;
//        CGImageRelease(imageRef);
//
//    }
//    
//    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
////
//    CGImageDestinationFinalize(destination);
//    CFRelease(destination);
//}

+ (NSArray *)addMarkToOriginImgs:(NSArray *)originImgs markImage:(UIImage *)markImg isRecord:(BOOL)isRecord markIV:(UIImage *)markIV markFrame:(CGRect)markFrame markTextIVFrame:(CGRect)markTextIVFrame isPhotoToGif:(BOOL)isPhotoToGif {
    NSMutableArray *resultImgs = [NSMutableArray array];
    for (int j = 0; j < originImgs.count; j++) {
        NSString *sourceImgPath = (NSString *)originImgs[j]; //原始图片在沙盒中的地址
        NSString *imgPath = [NSString stringWithFormat:@"%@%d.png", FINAL_IMGPATH, j]; //处理完后生成图片在沙盒中保存的地址
        UIImage *img = [UIImage imageWithContentsOfFile:sourceImgPath];
        CGFloat imgW = img.size.width;
        CGFloat imgH = img.size.height;
        CGFloat endImgW, endImgH;
        CGSize size = isPhotoToGif ? CGSizeMake((K_W-40) * 2, (K_W-40) * 2) : img.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        if (imgW >= imgH) {
            endImgW = (K_W-40) * 2;
            endImgH = imgH * (K_W-40) * 2 / imgW;
        }else {
            endImgW = imgW * (K_W-40) * 2 / imgH;
            endImgH = (K_W-40) * 2;
        }
        // 1.获得一个位图图形上下文,画背景
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (isPhotoToGif) {
            CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextFillRect(context, CGRectMake(0, 0, (K_W-40) * 2, (K_W-40) * 2));
            CGContextDrawPath(context, kCGPathStroke);
            [img drawInRect:CGRectMake(((K_W-40)*2 - endImgW) / 2.0, ((K_W-40)*2 - endImgH) / 2.0, endImgW, endImgH)];
        }else {
            CGContextDrawPath(context, kCGPathStroke);
            [img drawAtPoint:CGPointMake(0, 0)];
        }
        // 3.返回绘制的新图形
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        @autoreleasepool {
            if (markImg != nil) {
                newImage = [self addWaterMark:newImage markImg:markImg isRecord:isRecord isDefault:NO markIV:markIV markFrame:markFrame markTextIVFrame:markTextIVFrame isPhotoToGif:isPhotoToGif];
            }else {
                newImage = [self addWaterMark:newImage markImg:markImg isRecord:isRecord isDefault:YES markIV:markIV markFrame:markFrame markTextIVFrame:markTextIVFrame isPhotoToGif:isPhotoToGif];
            }
            NSData *imgData = UIImageJPEGRepresentation(newImage, 1.0);
            [SystemUtils deleteFileAtPath:imgPath];
            [imgData writeToFile:imgPath atomically:YES];
            [resultImgs addObject:imgPath];
            img = nil;
        }
    }
    return resultImgs;
}
//+ (NSArray *)addWaterMarker:(NSArray *)sourceImgs markImage:(UIImage *)markImage {
//    if (sourceImgs.count == 0) {
//        return nil;
//    }
//    NSMutableArray *resultImages = [NSMutableArray new];
//    for (UIImage *image in sourceImgs) {
//        CGSize size = image.size;
//        CGFloat finalMarkHeight = (size.width / markImage.size.width) * 55.0;
//        CGSize markSize = [SystemUtils sizeMaxHeight:finalMarkHeight withSize:markImage.size];
//        UIGraphicsBeginImageContext(size);
//        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//        [markImage drawInRect:CGRectMake(size.width - markSize.width, size.height - markSize.height, markSize.width, markSize.height)];
//        UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
//        [resultImages addObject:resultImg];
//        UIGraphicsEndImageContext();
//    }
//    return resultImages;
//}

//给单张图片添加水印
+ (UIImage *)addWaterMark:(UIImage *)sourceImg markImg:(UIImage *)markImg isRecord:(BOOL)isRecord isDefault:(BOOL)isDefault markIV:(UIImage *)markIV markFrame:(CGRect)markFrame  markTextIVFrame:(CGRect)markTextIVFrame isPhotoToGif:(BOOL)isPhotoToGif {
    
    CGSize size = sourceImg.size;
    UIGraphicsBeginImageContext(size);
    [sourceImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    
    CGFloat markH = markFrame.size.height;
    CGFloat markW = markFrame.size.width;
    
//    CGFloat finalMarkHeight = markH;
//    CGSize markSize = [SystemUtils sizeMaxHeight:finalMarkHeight withSize:markImg.size];
//    markH = markSize.height;
//    CGFloat markW = markSize.width;
    /**
     * afterW afterH 重新绘图时水印图片在画布中的实际尺寸
     * endX endY  水印图片在画布中的实际原点坐标
     * bigW bigH  画布底部背景图在gif编辑页面展现的实际尺寸
     */
    CGFloat afterW, afterH, endX, endY, bigW, bigH;
    CGFloat scale = 1.0;
    if (size.width >= size.height) {
        scale = size.width / (K_W-40);
        afterW = markW * size.width / (K_W-40);
        afterH = afterW * markH / markW;
        bigW = (K_W-40);
        bigH = (K_W-40) * size.height / size.width;
        endX = markFrame.origin.x;
        CGFloat ySpace = ((K_W-40) - bigH) / 2.0; //背景图的上下间距
        endY = isPhotoToGif ? markFrame.origin.y : markFrame.origin.y - ySpace;
    }else {
        scale = size.height / (K_W-40);
        afterH = size.height * markH / (K_W-40);
        afterW = markW * afterH / markH;
        bigW = (K_W-40) * size.width / size.height;
        bigH = (K_W-40);
        CGFloat xSpace = ((K_W-40) - bigW) / 2.0; //背景图的左右间距
        endX = isPhotoToGif ? markFrame.origin.x : markFrame.origin.x - xSpace;
        endY = markFrame.origin.y;
    }
    CGSize endMarkSize = CGSizeMake(markFrame.size.width * scale, markFrame.size.height * scale);
    [markImg drawInRect:CGRectMake(endX * scale, endY * scale, endMarkSize.width, endMarkSize.height)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (markIV == nil) {
        return resultImg;
    }
    
    //文字水印
    UIImage *newresultImg = [self addTextWaterMark:resultImg markTextWaterMark:markIV markTextIVFrame:markTextIVFrame  isPhotoToGif:isPhotoToGif];
    
    return newresultImg;
    
}

//文字水印
+ (UIImage *)addTextWaterMark:(UIImage *)sourceImg markTextWaterMark:(UIImage *)textWaterMark markTextIVFrame:(CGRect)markTextIVFrame isPhotoToGif:(BOOL)isPhotoToGif{
    
    CGSize size = sourceImg.size;
    UIGraphicsBeginImageContext(size);
    [sourceImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    
    CGFloat markH = markTextIVFrame.size.height;
    UIImage *markImg = textWaterMark;
    CGFloat finalMarkHeight = markH * (K_W-40) / 375;
    CGSize markSize = [SystemUtils sizeMaxHeight:finalMarkHeight withSize:markImg.size];
    markH = markSize.height;
    CGFloat markW = markSize.width;
    /**
     * afterW afterH 重新绘图时水印图片在画布中的实际尺寸
     * endX endY  水印图片在画布中的实际原点坐标
     * bigW bigH  画布底部背景图在gif编辑页面展现的实际尺寸
     */
    CGFloat afterW, afterH, endX, endY, bigW, bigH;
    CGFloat scale = 1.0;
    if (size.width >= size.height) {
        scale = size.width / (K_W-40);
        afterW = markW * size.width / (K_W-40);
        afterH = afterW * markH / markW;
        bigW = (K_W-40);
        bigH = (K_W-40) * size.height / size.width;
        endX = markTextIVFrame.origin.x;
        CGFloat ySpace = ((K_W-40) - bigH) / 2.0; //背景图的上下间距
        endY = isPhotoToGif ? markTextIVFrame.origin.y : markTextIVFrame.origin.y - ySpace;
    }else {
        scale = size.height / (K_W-40);
        afterH = size.height * markH / (K_W-40);
        afterW = markW * afterH / markH;
        bigW = (K_W-40) * size.width / size.height;
        bigH = (K_W-40);
        CGFloat xSpace = ((K_W-40) - bigW) / 2.0; //背景图的左右间距
        endX = isPhotoToGif ? markTextIVFrame.origin.x : markTextIVFrame.origin.x - xSpace;
        endY = markTextIVFrame.origin.y;
    }
    CGSize endMarkSize = CGSizeMake(markTextIVFrame.size.width * scale, markTextIVFrame.size.height * scale);

    [markImg drawInRect:CGRectMake(endX * scale, endY * scale, endMarkSize.width, endMarkSize.height)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImg;
    
}


#pragma mark - Helpers

// 需要同时分辨率大小和文件大小 这里去判断
+ (CGFloat) getFinalScaleWithOrignalScale:(CGFloat)orignalScale  addToWechatLimitScale:(CGFloat )limitScale {
    
    if (limitScale > orignalScale) {
        
        return orignalScale;
    } else {
        
        return limitScale;
    }
}

// 获取图片分辨率，最大值内的 需要缩小的比例
+ (CGFloat)getFitScaleWithLimitNumber:(CGFloat)limitNumer withImage:(UIImage *)image {
    
    float scale = 1.0f;
    
    CGSize imageSize = image.size;
    
    CGFloat maxWidth = limitNumer;
 
    if (imageSize.width >imageSize.height) {
        //原图 宽>高
        if (maxWidth > imageSize.width) {
            scale = 1.0f;
        }else {
            
            scale = maxWidth / imageSize.width;
        }
    }else {
        //原图 宽<=高
        if (maxWidth > imageSize.height) {
            scale = 1.0f;
        }else {
            
            scale = maxWidth /imageSize.height;
        }
    }
    
    NSLog(@"原图片的size = %@,缩放后图片的size = %@，缩放scale = %f",NSStringFromCGSize(imageSize),NSStringFromCGSize(CGSizeMake(imageSize.width *scale,imageSize.height *scale)), scale);
    
    return scale;
}

// 按照图片原来的宽高比 是缩放图片
+ (CGImageRef)nov_createImageWithScale:(CGFloat)scale  imageRe:(CGImageRef) imageRef {
    
    CGSize newSize = CGSizeMake(CGImageGetWidth(imageRef)*scale, CGImageGetHeight(imageRef)*scale);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);// 这里参数设置为1 是指的按照图片自己的分辨率
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return nil;
    }
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    //Release old image
    //        CFRelease(imageRef);
    // Get the resized image from the context and a UIImage
    CGImageRef destImageRef= CGBitmapContextCreateImage(context);
    
    UIGraphicsEndImageContext();
    return destImageRef;
    
    //    return imageRef;
}

+(UIImage *)watermarkImage:(UIImage *)img withName:(NSString *)name
 
 {
 
   NSString* mark = name;
 
   int w = img.size.width;
 
   int h = img.size.height;
 
   UIGraphicsBeginImageContext(img.size);
 
   [img drawInRect:CGRectMake(0, 0, w, h)];
 
   NSDictionary *attr = @{
 
              NSFontAttributeName: [UIFont boldSystemFontOfSize:12],  //设置字体
 
              NSForegroundColorAttributeName : [UIColor whiteColor]   //设置字体颜色
 
              };
      
    CGFloat width1 = [name boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
     
   [mark drawInRect:CGRectMake(w/2-width1/2, h-20,width1, 15) withAttributes:attr];    //左下角
 
   UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
 
   UIGraphicsEndImageContext();
 
   return aimg;
 
 }

@end
