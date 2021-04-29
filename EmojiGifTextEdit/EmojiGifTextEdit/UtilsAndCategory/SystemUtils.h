//
//  SystemUtils.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface SystemUtils : NSObject
#pragma mark - button的灰色显示和取消
+ (void)disableBtn:(UIButton *)btn;
+ (void)enableBtn:(UIButton *)btn;

/** 返回当前手机型号*/
+ (NSString *)iphoneType;

+ (BOOL)isIphoneX;

+ (CGSize)sizeMaxWidth:(float)maxWidth withAsset:(PHAsset *)asset;

+ (CGSize)sizeMaxWidth:(float)maxWidth withAvAsset:(AVAsset *)avasset;

+ (CGSize)sizeMaxWidth:(float)maxWidth withSize:(CGSize)size;

+ (CGSize)sizeMaxHeight:(float)maxHeight withSize:(CGSize)size;

/** 将整型数据转为 00:00 时间格式*/
+ (NSString *)timeFormatted:(int)totalSeconds;

/** 删除指定位置的文件*/
+ (void)deleteFileAtPath:(NSString *)path;

#pragma mark - 各种权限

/**
 仅适用于用户未做决定时，第一次主动弹出系统权限框，用户做出选择后触发block。

 @param completionBlock 是否授予权限
 */
+ (void)requestAlbumAuth:(void(^)(bool isAllowed))completionBlock;  //相册

/**
 仅适用于用户未做决定时，第一次主动弹出系统权限框，用户做出选择后触发block。
 
 @param completionBlock 是否授予权限
 */
+ (void)requestCameraAuth:(void(^)(bool isAllowed))completionBlock;  //照相机

/**
 使用于用户明确拒绝授权但又想使用改功能时，弹出此框引导进入系统设置页

 @param authName 弹框大标题 eg:请求使用相册权限
 */
+ (void)asyncPushAuthAlert:(NSString *)authName;

#pragma mark - 设置页的点击事件

/** 打开邮件反馈，需补充邮箱地址和主题*/
+ (void)openMailFeedback;

/** 清除sdimg的缓存，会弹出框显示当前缓存大小，让用户二次确认*/
+ (void)clearImgCache;

/** 保存gif到相册*/
+ (void)saveGifToPhotoAlbum:(NSString *)gifPath completion:(void(^)(BOOL isSuccess, NSError *error))completionBlock;

+ (void)saveContentGifToPhotoAlbum:(NSData *)gifData completion:(void(^)(BOOL isSuccess, NSError *error))completionBlock;

+ (void)saveContentPhotoDownloadSandbox:(NSData *)imageData;

#pragma mark - 图片处理
/** 裁剪、缩放图片
 * oldImages : 要处理的图片数组
 * targetSize : 指定的尺寸, 填为CGSizeZero之后，默认第一张图片的尺寸为准
 */
+ (NSMutableArray *)newCroppedImagesWith:(NSArray *)oldImages withSize:(CGSize)targetSize;

/** 裁剪图片
 * image : 原图
 * bounds : 指定的尺寸
 */
+ (UIImage *)croppedImage:(UIImage *)image bounds:(CGRect)bounds;

/** 裁剪图片
 * image : 原图
 * bounds : 缩放到的尺寸
 */
+ (UIImage *)clipImage:(UIImage *)image ScaleWithsize:(CGSize)asize;

#pragma mark - 相册获取
/** 从phasset返回所有连拍图片
  phasset : 从相册取到的连拍代表
 */
+ (void)burstimgsWithPhasset:(PHAsset *)phasset completion:(void (^)(NSMutableArray *images))completionBlock;

/** 从phasset数组-->img数组
 * phasset : PHAsset数组
 *
 */
+ (void)imgsWithPhassetArr:(NSMutableArray *)phassetArr completion:(void (^)(NSMutableArray *images))completionBlock;

/**
 原图数组压缩
 
 @param originImgs 原图数组
 @return 压缩后的图片数组
 */
+ (NSArray *)archiveImgs:(NSArray *)originImgs;

/**
 屏幕截图

 @param view 视图
 @return image
 */
+ (UIImage *)captureImageFullScreenInView:(UIView *)view;

/**
 是否成功创建MyGIF文件夹
 
 @return YES:创建成功  NO:创建失败
 */
+ (BOOL)successCreateMyGIFDirectory;

/**
 是否成功创建用户收藏下载记录文件夹
 
 @return YES:创建成功  NO:创建失败
 */
+ (BOOL)successCreateEditPhotoDirectory;

+ (void)clearMyGIFCache;


/**
 在一定区域内的随机rect
 
 @param parentRect 父视图区域
 @return 子视图随机的rect
 */
+ (CGRect)getRandomRectFromOriginRect:(CGRect)parentRect;

/**
 判断是否是中文环境

 @return 字符
 */
+ (BOOL)isZH;

/**
 检测是否是日文

 @return 字符
 */
+ (BOOL)isJP;

+ (BOOL)isEn;

+ (BOOL)isKo;

+ (int)getRandomNumber:(int)from to:(int)to;

+ (void)systemShareImage:(UIImage *)image vc:(UIViewController *)vc;
+ (void)systemShareNSData:(NSData *)data vc:(UIViewController *)vc;

/// 获取当前时间戳有两种方法(以秒为单位)
+ (NSString *)getNowTimeTimestamp;
+ (NSInteger)comparativeTimeDifference:(NSString *)startTime endTime:(NSString *)endTime;
+ (void)joinQQGroupId:(NSString *)groupId groupKey:(NSString *)groupKey;
@end

NS_ASSUME_NONNULL_END
