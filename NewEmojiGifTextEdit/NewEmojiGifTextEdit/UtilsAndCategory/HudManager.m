//
//  HudManager.m
//  Unity-iPhone
//
//  Created by 张帆 on 16/12/14.
//
//

#import "HudManager.h"
#define KWINDOW [[UIApplication sharedApplication].delegate window]

@interface HudManager ()
@property (nonatomic, strong) MBProgressHUD *activityHud, *wordHUD;
@end

@implementation HudManager

#pragma mark - 文字
+ (void)showHud:(NSString *)label{
    
    [HudManager showHudWithLaber:label detailLabel:nil offset:CGPointMake(0, 120) duringTime:2 fromView:KWINDOW];
}

+ (void)showHudWithLaber:(NSString *)title detailLabel:(NSString *)detail offset:(CGPoint)offset duringTime:(float)during fromView:(UIView *)superView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
        hud.userInteractionEnabled = NO;
        hud.mode = MBProgressHUDModeText;
        hud.animationType = MBProgressHUDAnimationFade;
        hud.label.text = title;
        hud.offset = offset;
        hud.margin = 10;
        //    hud.detailsLabel.text = detail;
        [hud hideAnimated:YES afterDelay:during];
    });
}

#pragma mark - 其他

+ (void)showHudCheckmark:(NSString *)text {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:KWINDOW animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        UIImage *image = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        hud.square = YES;
        hud.label.text = text;
        [hud hideAnimated:YES afterDelay:1.0f];
    });
}

+ (void)showWord:(NSString *)word {
    [[HudManager shareManager] showWord:word after:0];
}

+ (void)showWord:(NSString *)word  after:(NSInteger)after{
    [[HudManager shareManager] showWord:word after:after];
}

+ (void)showLoading {
    [[HudManager shareManager] showLoading];
}

+ (void)hideLoading {
    [[HudManager shareManager] hideLoading];
}

#pragma mark - instance method || 非公开

static dispatch_once_t onceToken;
static HudManager *manager;
+ (HudManager *)shareManager {
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (MBProgressHUD *)activityHud {
    if (!_activityHud) {
        _activityHud = [[MBProgressHUD alloc] initWithView:KWINDOW];
        _activityHud.removeFromSuperViewOnHide = NO;
        [KWINDOW addSubview:_activityHud];
    }
    return _activityHud;
}

- (void)showLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityHud.mode = MBProgressHUDModeIndeterminate;
        [self.activityHud showAnimated:YES];
    });
}

- (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityHud hideAnimated:YES];
    });
}

//文字 单例

- (MBProgressHUD *)wordHUD {
    if (!_wordHUD) {
        _wordHUD = [[MBProgressHUD alloc] initWithView:KWINDOW];
        _wordHUD.removeFromSuperViewOnHide = NO;
        [KWINDOW addSubview:_wordHUD];
    }
    return _wordHUD;
}

- (void)showWord:(NSString *)word after:(NSInteger)after{
    
    if (after == 0) {
        after = 2;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.wordHUD.label.text = word;
        self.wordHUD.mode = MBProgressHUDModeText;
        self.wordHUD.animationType = MBProgressHUDAnimationFade;
        self.wordHUD.userInteractionEnabled = NO;
        self.wordHUD.margin = 10.0f;
        self.wordHUD.offset = CGPointMake(0, 100);
        [self.wordHUD showAnimated:YES];
        [self.wordHUD hideAnimated:YES afterDelay:after];
    });
}

@end
