//
//  GifUtils.h
//  videoClip
//  资源转Gif
//  Created by db J on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GifType) {
    GifFromVideo = 0,
    GifFromBurst,
    GifFromLivephoto,
    GifFromImgs,
    GifFromGif
};

@interface GifUtils : NSObject

/** 视频-->图片 将视频转为按指定间隔转成一组图片
 * avasset : 视频资源
 * interval : 每帧之间的间隔
 * block 返回所需的一组图片
 */
+ (void)imgsWithVideoAsset:(AVAsset *)avasset withTimeInterval:(float)interval withTimeRange:(CMTimeRange)range completion:(void(^)(NSMutableArray *images))completionBlock;

/** 图片-->gif
 * images : 原材料
 * delay : 每一张图片停留的时间
 * targetPath : gif制作后保存的本地路径
 * markImage : 自带水印图片
 * isRecord : 是否是录制的视频
 * markIV: 自定义文字的视图
 * markFrame: 自带水印的frame
 * isPhotoToGif : YES:需要统一尺寸 NO：不需要统一尺寸
 */
+ (void)gifWithImages:(NSArray *)images withDelay:(float)delay targetPath:(NSString *)targetPath markImage:(UIImage *)markImage  markTextIV:(UIImage *)markTextIV markFrame:(CGRect)markFrame markTextIVFrame:(CGRect)markTextIVFrame isRecord:(BOOL)isRecord isPhotoToGif:(BOOL)isPhotoToGif;


// scale 缩放单张图片的比例控制  GIF导出的大小
//+ (void)gifWithImages:(NSArray *)images scale:(CGFloat)scale withDelay:(float)delay targetPath:(NSString *)targetPath withMuArr:(NSMutableArray *)textfieldDictArr markImage:(UIImage *)markImage isRecord:(BOOL)isRecord markIV:(UIView*)markIV markFrame :(CGRect)markFrame isPhotoToGif:(BOOL)isPhotoToGif ;

/**
 从GIF中提取图片数组
 @param data gif的原始二进制数据
 @param textArray 需要给图片上添加的文字数组
 block 返回所需的一组图片
 */
+ (void)imgsFromGifWithData:(NSData *)data textDictArray:(NSArray *)textArray completeHnadler:(void(^)(float imgDelay, NSMutableArray *images))completeHandler;
@end

NS_ASSUME_NONNULL_END
