//
//  HudManager.h
//  Unity-iPhone
//
//  Created by 张帆 on 16/12/14.
//
//

#import <Foundation/Foundation.h>

@interface HudManager : NSObject

//+ (void)showHud:(NSString *)label;

//+ (void)showHudWithLaber:(NSString *)title detailLabel:(NSString *)detail offset:(CGPoint)offset duringTime:(float)during fromView:(UIView *)superView;

+ (void)showHudCheckmark:(NSString *)text;

+ (void)showWord:(NSString *)word;

+ (void)showWord:(NSString *)word  after:(NSInteger)after;

#pragma mark - 单例风火轮
+ (void)showLoading ;

+ (void)hideLoading ;

@end
