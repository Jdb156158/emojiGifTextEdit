//
//  SystemUtils.m
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import "SystemUtils.h"
#import <sys/utsname.h>
#import <Photos/Photos.h>

@implementation SystemUtils
+ (void)disableBtn:(UIButton *)btn {
    btn.alpha = 0.4f;
    btn.enabled = NO;
}

+ (void)enableBtn:(UIButton *)btn {
    btn.alpha = 1.0f;
    btn.enabled = YES;
}

+ (NSString *)timeFormatted:(int)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    NSString *result = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    return result;
}

+ (void)deleteFileAtPath:(NSString *)path {
    
    if ([FILEMANAGER fileExistsAtPath:path]) {
        [FILEMANAGER removeItemAtPath:path error:nil];
    }
}

+ (CGSize)sizeMaxWidth:(float)maxWidth withAsset:(PHAsset *)asset {
    
    float scale = 1.0f;
    CGSize resultSize;
    if (asset.pixelWidth > asset.pixelHeight) {
        //原图 宽>高
        if (maxWidth > asset.pixelWidth) {
            scale = 1.0f;
        }else {
            scale = asset.pixelWidth / maxWidth;
        }
    }else {
        //原图 宽<=高
        if (maxWidth > asset.pixelHeight) {
            scale = 1.0f;
        }else {
            scale = asset.pixelHeight / maxWidth;
        }
    }
    resultSize = CGSizeMake(asset.pixelWidth/scale, asset.pixelHeight/scale);
    
//    NSLog(@"--------------------------");
//    NSLog(@"资源size%@， 缩小倍数%02f", NSStringFromCGSize(resultSize), (float)scale);
//    NSLog(@"--------------------------");
    return resultSize;
}

+ (CGSize)sizeMaxWidth:(float)maxWidth withAvAsset:(AVAsset *)avasset {
    float scale = 1.0f;
    CGSize resultSize;
//
    NSLog(@"naturalSize.width = %f ,naturalSize.height = %f",avasset.naturalSize.width,avasset.naturalSize.height);

    resultSize = avasset.naturalSize;
    if (avasset.naturalSize.width > avasset.naturalSize.height) {
        //原图 宽>高
        if (maxWidth > avasset.naturalSize.width) {
            scale = 1.0f;
        }else {
            scale = avasset.naturalSize.width / maxWidth;
        }
    }else {
        //原图 宽<=高
        if (maxWidth > avasset.naturalSize.height) {
            scale = 1.0f;
        }else {
            scale = avasset.naturalSize.height / maxWidth;
        }
    }
    resultSize = CGSizeMake(avasset.naturalSize.width/scale, avasset.naturalSize.height/scale);

    NSLog(@"--------------------------");
    NSLog(@"资源size%@， 缩小倍数%02f", NSStringFromCGSize(resultSize), (float)scale);
    NSLog(@"--------------------------");
    return resultSize;
}




+ (CGSize)sizeMaxWidth:(float)maxWidth withSize:(CGSize)size {
    
    float scale = 1.0f;
    CGSize resultSize;
    if (maxWidth > size.width) {
        resultSize = size;
    }else {
        scale = size.width / maxWidth;
        resultSize = CGSizeMake(size.width/scale, size.height/scale);
    }
    
    NSLog(@"--------------------------");
    NSLog(@"size%@， 缩小倍数%02f", NSStringFromCGSize(resultSize), (float)scale);
    NSLog(@"--------------------------");
    return resultSize;
}

+ (CGSize)sizeMaxHeight:(float)maxHeight withSize:(CGSize)size {
    float scale = 1.0;
    CGSize resultSize;
    if (maxHeight > size.height) {
        resultSize = size;
    }else {
        scale = size.height / maxHeight;
        resultSize = CGSizeMake(size.width / scale, size.height / scale);
    }
    return resultSize;
}

#pragma mark - auth request

+ (void)requestAlbumAuth:(void(^)(bool isAllowed))completionBlock {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            completionBlock(YES);
        }else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            completionBlock(NO);
        }
    }];
}

+ (void)requestCameraAuth:(void(^)(bool isAllowed))completionBlock {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        completionBlock(granted);
    }];
}

+ (void)asyncPushAuthAlert:(NSString *)authName {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:authName message:@"下一步操作需访问相册权限，需要您去设置中允许访问" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *go = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }];
        
        [alert addAction:okBtn];
        [alert addAction:go];
        [[UIViewController currentViewController] presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - 设置页的功能
+ (void)openMailFeedback {
    NSMutableString *mailUrl = [[NSMutableString alloc] init];
    NSString *recipients = @"duolaameng2077@163.com";
    NSString *userInfo = [NSString stringWithFormat:@"\n\n\n\n\n系统版本：%@\n 手机型号：%@\n 应用版本：%@", [[UIDevice currentDevice] systemVersion],[SystemUtils iphoneType], TLAppVerName];
    [mailUrl appendFormat:@"mailto:%@?", recipients];
    [mailUrl appendFormat:@"&subject=%@", @"表情包大师"];
    [mailUrl appendFormat:@"&body=%@", userInfo];
    
    NSString *emailPath = [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailPath] options:@{} completionHandler:^(BOOL success) {
        
    }];
}


+ (void)clearImgCache {
    NSUInteger cache = [[SDImageCache sharedImageCache] totalDiskSize] ;
    NSNumber *cachesize = [NSNumber numberWithUnsignedInteger:cache];
    NSString *sizeDes = [SystemUtils transformedValue:cachesize];
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"title_total", nil), sizeDes];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ask_clear", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"title_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *clear = [UIAlertAction actionWithTitle:NSLocalizedString(@"title_clear", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
        [HudManager showWord:NSLocalizedString(@"have_cleared", nil)];
    }];
    [alert addAction:cancel];
    [alert addAction:clear];
    [[UIViewController currentViewController] presentViewController:alert animated:NO completion:nil];
}

+ (void)clearMyGIFCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long size = 0;
    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:MYGIF_PATH isDirectory:&isDirectory]) {
        size = 0;
    }
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:MYGIF_PATH];
    for (NSString *subPath in enumerator) {
        //全路径
        NSString *fullPath = [MYGIF_PATH stringByAppendingPathComponent:subPath];
        //累加文件大小
        size += [fileManager attributesOfItemAtPath:fullPath error:nil].fileSize;
    }
    
    NSDirectoryEnumerator *enumerator2 = [fileManager enumeratorAtPath:MYEditPhoto_PATH];
    for (NSString *subPath in enumerator2) {
        //全路径
        NSString *fullPath = [MYEditPhoto_PATH stringByAppendingPathComponent:subPath];
        //累加文件大小
        size += [fileManager attributesOfItemAtPath:fullPath error:nil].fileSize;
    }
    
    size += [SDImageCache sharedImageCache].totalDiskSize;
    
    NSNumber *cachesize = [NSNumber numberWithUnsignedInteger:size];
    NSString *sizeDes = [SystemUtils transformedValue:cachesize];
    NSString *message = [NSString stringWithFormat:@"%@%@", @"缓存数据总大小共计：", sizeDes];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *clear = [UIAlertAction actionWithTitle:@"确定清除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:MYGIF_PATH];
        for (NSString *subPath in enumerator) {
            //全路径
            NSString *fullPath = [MYGIF_PATH stringByAppendingPathComponent:subPath];
            //累加文件大小
            [fileManager removeItemAtPath:fullPath error:nil];
        }
        NSDirectoryEnumerator *enumerator2 = [fileManager enumeratorAtPath:MYEditPhoto_PATH];
        for (NSString *subPath in enumerator2) {
            //全路径
            NSString *fullPath = [MYEditPhoto_PATH stringByAppendingPathComponent:subPath];
            //累加文件大小
            [fileManager removeItemAtPath:fullPath error:nil];
        }
        [HudManager showWord:@"清理完毕"];
    }];
    [alert addAction:cancel];
    [alert addAction:clear];
    [[UIViewController currentViewController] presentViewController:alert animated:NO completion:nil];
}

+ (CGRect)getRandomRectFromOriginRect:(CGRect)parentRect {
    int topHeight = IS_IPhoneX_All ? 88 + 135 : 64 + 135;
    int fromX = ceil(parentRect.origin.x);
    int toX = floor(CGRectGetMaxX(parentRect)) - 180;
    int fromY = ceil(parentRect.origin.y);
    int toY = floor(parentRect.origin.y + parentRect.size.height * 0.4) - 70;
    int resultX, resultY;
    if (parentRect.size.width <= 180) {
        resultX = CGRectGetMidX(parentRect) - 90;
    }else {
        resultX = (int)(fromX + (arc4random() % (toX - fromX + 1)));
    }
    resultX = resultX <= 0 ? 0 : resultX;
    if (parentRect.size.height <= 70) {
        resultY = CGRectGetMidY(parentRect) - 70;
    }else {
        resultY = (int)(fromY + (arc4random() % (toY - fromY + 1)));
    }
    resultY = resultY <= topHeight ? topHeight : resultY;
    CGRect resultRect = CGRectMake(resultX, resultY, 180, 70);
    return resultRect;
}

+ (BOOL)successCreateMyGIFDirectory {
    return [[NSFileManager defaultManager] createDirectoryAtPath:MYGIF_PATH withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (BOOL)successCreateEditPhotoDirectory {
    return [[NSFileManager defaultManager] createDirectoryAtPath:MYEditPhoto_PATH withIntermediateDirectories:YES attributes:nil error:nil];
}


#pragma mark - 获取机型

+ (NSString *)iphoneType {
    
    //需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone4,1"])
        return@"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"])
        return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"])
        return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"])
        return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"])
        return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"])
        return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"])
        return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"])
        return@"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"])
        return@"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"])
        return@"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"])
        return@"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"] || [platform isEqualToString:@"iPhone12,8"])
        return@"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"])
        return@"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"])
        return@"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"])
        
        return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"])
        return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"])
        return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"])
        return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"])
        return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"])
        return@"iPhone X";
    
    if ([platform hasPrefix:@"iPhone11,"]) {
        return @"iPhone X";
    }
    return platform;
}

+ (BOOL)isIphoneX {
    BOOL isX = [[self iphoneType] isEqualToString:@"iPhone X"];
    return isX;
}

+ (void)saveContentGifToPhotoAlbum:(NSData *)gifData completion:(void(^)(BOOL isSuccess, NSError *error))completionBlock {

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        PHAssetResourceCreationOptions *requestoOptions = [[PHAssetResourceCreationOptions alloc] init];
        [request addResourceWithType:PHAssetResourceTypePhoto data:gifData options:requestoOptions];

    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success)
            [HudManager showHudCheckmark:@"保存成功"];
        else
            [HudManager showWord:@"保存失败，请重试！"];
        completionBlock(success, error);
    }];
}

+ (void)saveGifToPhotoAlbum:(NSString *)gifPath completion:(void(^)(BOOL isSuccess, NSError *error))completionBlock {
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSData *gifData = [NSData dataWithContentsOfFile:gifPath];
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        PHAssetResourceCreationOptions *requestoOptions = [[PHAssetResourceCreationOptions alloc] init];
        [request addResourceWithType:PHAssetResourceTypePhoto data:gifData options:requestoOptions];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completionBlock(success, error);
    }];
}

+ (void)saveContentPhotoDownloadSandbox:(NSData *)imageData{
    //保存图片到沙盒
    NSString *targetImgPath = [NSString stringWithFormat:@"%@%@download.png",Edit_Photo_Download,[NSString getNowTimeTimestamp]];
    
    NSLog(@"保存图片到沙盒:%@",targetImgPath);
    NSError *error = nil ;
    
    BOOL isWrited = [imageData writeToFile:targetImgPath options:NSDataWritingAtomic  error:&error];
    
    if (!isWrited) {
        NSLog(@"writeToFile failed with error %@", error);
    }
}


/// 压缩原图数组
+ (NSArray *)archiveImgs:(NSArray *)originImgs {
    NSMutableArray *resultImgs = [NSMutableArray array];
    for (UIImage *originImg in originImgs) {
        NSData *fixData = UIImageJPEGRepresentation(originImg, 0.5f);
        UIImage *resultImg = [UIImage imageWithData:fixData];
        [resultImgs addObject:resultImg];
    }
    return resultImgs;
}


#pragma mark - 非公开方法

//计算缓存大小
+ (id)transformedValue:(id)value{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB" ,nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}


#pragma mark - 图片
+ (NSMutableArray *)newCroppedImagesWith:(NSArray *)oldImages withSize:(CGSize)targetSize{
    
    NSMutableArray *imageArray = [NSMutableArray array];
    if (targetSize.width == CGSizeZero.width) {
        UIImage *firstImg = [oldImages firstObject];
        targetSize = firstImg.size;
    }
    
    for (UIImage *image in oldImages){
        CGRect rect = CGRectMake(0, 0,image.size.width, image.size.height);
        if (rect.size.width < rect.size.height){
            rect.origin.y = (rect.size.height - rect.size.width)/2;
            rect.size.height = rect.size.width;
        } else {
            rect.origin.x = (rect.size.width - rect.size.height)/2;
            rect.size.width = rect.size.height;
        }
        //裁剪
        UIImage *newImage = [SystemUtils croppedImage:image bounds:rect];
        //缩放
        UIImage *finalImage = [SystemUtils clipImage:newImage ScaleWithsize:targetSize];
        [imageArray addObject:finalImage];
    }
    return imageArray;
}

+ (UIImage *)croppedImage:(UIImage *)image bounds:(CGRect)bounds{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

+ (UIImage *)clipImage:(UIImage *)image ScaleWithsize:(CGSize)asize{
    
    if (!image) {
        return nil;
    }
    
    UIImage *newimage;
    CGSize oldsize = image.size;
    CGRect rect;
    if (asize.width/asize.height > oldsize.width/oldsize.height) {
        rect.size.width = asize.width;
        rect.size.height = asize.width*oldsize.height/oldsize.width;
        rect.origin.x = 0;
        rect.origin.y = (asize.height - rect.size.height)/2;
    }
    else{
        rect.size.width = asize.height*oldsize.width/oldsize.height;
        rect.size.height = asize.height;
        rect.origin.x = (asize.width - rect.size.width)/2;
        rect.origin.y = 0;
    }
    UIGraphicsBeginImageContext(asize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, CGRectMake(0, 0, asize.width, asize.height));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
    [image drawInRect:rect];
    newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

#pragma mark - 获取连拍
+ (void)burstimgsWithPhasset:(PHAsset *)phasset completion:(void (^)(NSMutableArray *images))completionBlock {
    NSMutableArray *resultImgs = [NSMutableArray array];
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.includeAllBurstAssets = YES;
    fetchOptions.sortDescriptors =  @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithBurstIdentifier:phasset.burstIdentifier options:fetchOptions];
    
    NSUInteger burstCount = fetchResult.count;
    
    PHImageRequestOptions *requestOptions = [SystemUtils imgRequestOptions];
    NSLock *threadLock = [[NSLock alloc] init];
    for (int i = 0; i<burstCount; i++) {
        PHAsset *each = [fetchResult objectAtIndex:i];
        NSString *imgPath = [NSString stringWithFormat:@"%@%d.png", BURST_IMGPATH, i];
        [SystemUtils deleteFileAtPath:imgPath];
        __block NSData *imgData;
        CGSize targetSize = [SystemUtils sizeMaxWidth:MAX_PIXEL_BURSTGIF withAsset:each];//尺寸大容易崩溃
        [[PHImageManager defaultManager] requestImageForAsset:each targetSize:targetSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            [threadLock lock];
            if (result) {
                imgData = UIImageJPEGRepresentation(result, 1.0);
                [imgData writeToFile:imgPath atomically:YES];
                [resultImgs addObject:imgPath];
                result = nil;
            }
            if (resultImgs.count == burstCount){
                completionBlock(resultImgs);
            }
            //            NSLog(@"phasset 转 图片---%@", index);
            [threadLock unlock];
        }];
    }
    if (fetchResult.count == 0) {
        completionBlock(nil);
    }
}

+ (void)imgsWithPhassetArr:(NSMutableArray *)phassetArr completion:(void (^)(NSMutableArray *images))completionBlock {
    PHImageRequestOptions *requestOptions = [SystemUtils imgRequestOptions];
    
    NSMutableArray *resultImgs = [NSMutableArray array];
    NSUInteger imgCount = phassetArr.count;
    for (int i = 0; i<imgCount; i++) {
        //...
        NSString *imgPath = [NSString stringWithFormat:@"%@%d.png", BURST_IMGPATH, i];
        [SystemUtils deleteFileAtPath:imgPath];
        __block NSData *imgData;
        
        PHAsset *each = [phassetArr objectAtIndex:i];
        NSLock *threadLock = [[NSLock alloc] init];
        
        CGSize targetSize = [SystemUtils sizeMaxWidth:MAX_PIXEL_PICTUREGIF withAsset:each];
        [[PHImageManager defaultManager] requestImageForAsset:each targetSize:targetSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [threadLock lock];
            if (result) {
                imgData = UIImageJPEGRepresentation(result, 1.0);
                [imgData writeToFile:imgPath atomically:YES];
                [resultImgs addObject:imgPath];
                result = nil;
            }
            if (resultImgs.count == imgCount){
                completionBlock(resultImgs);
            }
            [threadLock unlock];
        }];
    }
    if (imgCount == 0) {
        completionBlock(nil);
    }
}

//截图
+ (UIImage *)captureImageFullScreenInView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(KWINDOW.frame.size, NO, 0.0);//1.0
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGFloat y = IS_IPhoneX_All ? 44 : 20;
    theImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(theImage.CGImage, CGRectMake(0, y*[UIScreen mainScreen].scale, K_W*[UIScreen mainScreen].scale, (K_H - y)*[UIScreen mainScreen].scale))];
    return theImage;
}

//是否是中文环境
+ (BOOL)isZH {
    static BOOL result = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[self getPreferredLanguage] hasPrefix:@"zh-Hans"];
    });
    return result;
}

+ (BOOL)isJP {
    static BOOL result = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[self getPreferredLanguage] hasPrefix:@"ja"];
    });
    return result;
}

+ (BOOL)isEn {
    static BOOL result = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[self getPreferredLanguage] hasPrefix:@"en"];
    });
    return result;
}

+ (BOOL)isKo {
    static BOOL result = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[self getPreferredLanguage] hasPrefix:@"ko"];
    });
    return result;
}

+ (int)getRandomNumber:(int)from to:(int)to {
     int num = (int)(from + (arc4random() % (to - from + 1)));
     return num;
}

#pragma mark - 非公开方法

+ (PHImageRequestOptions *)imgRequestOptions {
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.synchronous = YES;
    
    return requestOptions;
}

+ (NSString*)getPreferredLanguage {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (void)systemShareImage:(UIImage *)image vc:(UIViewController *)vc {
    NSString *shareText = @"表情分享";
    UIImage *shareImage = image;
    NSArray *activityItems = [[NSArray alloc] initWithObjects:shareText, shareImage, nil];
    UIActivityViewController *activityVc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSLog(@"%@",activityType);
        if (completed) {
            [HudManager showWord:@"分享成功"];
        } else {
            [HudManager showWord:@"分享失败"];
        }
        //[vc dismissViewControllerAnimated:YES completion:nil];
    };
    
    activityVc.completionWithItemsHandler = myBlock;
    
    [vc presentViewController:activityVc animated:YES completion:nil];
}

+ (void)systemShareNSData:(NSData *)data vc:(UIViewController *)vc {
    NSString *shareText = @"表情分享";
    NSArray *activityItems = [[NSArray alloc] initWithObjects:shareText, data, nil];
    UIActivityViewController *activityVc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSLog(@"%@",activityType);
        if (completed) {
            [HudManager showWord:@"分享成功"];
        } else {
            [HudManager showWord:@"分享失败"];
        }
    };
    
    activityVc.completionWithItemsHandler = myBlock;
    
    [vc presentViewController:activityVc animated:YES completion:nil];
}

/// 获取当前时间戳有两种方法(以秒为单位)
+ (NSString *)getNowTimeTimestamp {

    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];

    return timeSp;

}


+ (NSInteger)comparativeTimeDifference:(NSString *)startTime endTime:(NSString *)endTime {
    NSString *beginTimestamp = startTime;
    NSString *endTimestamp = endTime;
        
    NSTimeInterval timer1 = [beginTimestamp doubleValue];
    NSTimeInterval timer2 = [endTimestamp doubleValue];
        
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timer1];
    NSString *dateString1 = [formatter stringFromDate:date];
        
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:timer2];
    NSString *dateString2 = [formatter stringFromDate:date2];
        
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:date2 options:0];

    NSLog(@"%@",dateString1);
    NSLog(@"%@",dateString2);
    // 获得某个时间的年月日时分秒
    NSLog(@"差值%ld天,%ld小时%ld分%ld秒",cmps.day ,cmps.hour, cmps.minute,cmps.second);
    return cmps.minute;
}

+ (void)joinQQGroupId:(NSString *)groupId groupKey:(NSString *)groupKey{
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external&jump_from=webapi", groupId,groupKey];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }else{
    }
}

@end
