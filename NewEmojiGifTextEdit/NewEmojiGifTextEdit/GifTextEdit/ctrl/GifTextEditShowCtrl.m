//
//  GifTextEditShowCtrl.m
//  NewEmojiGifTextEdit
//
//  Created by db J on 2021/4/29.
//

#import "GifTextEditShowCtrl.h"

@interface GifTextEditShowCtrl ()
@property(nonatomic, copy) void (^dismissCallback)(void);
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *centerView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@end

@implementation GifTextEditShowCtrl

+ (void)showWithDismissCallback:(void (^)(void))dismissCallback {
    
    GifTextEditShowCtrl *viewController = [[GifTextEditShowCtrl alloc] initWithNibName:@"GifTextEditShowCtrl" bundle:[NSBundle bundleForClass:[GifTextEditShowCtrl class]]];
    viewController.dismissCallback = dismissCallback;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    nav.navigationBarHidden = true;
    nav.modalPresentationStyle = UIModalPresentationCustom;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [[UIViewController currentViewController] presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    
    _centerView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:PATH_GIF]];
    [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissView)]];
}

- (void)dissView{
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)closeSaveBtn:(id)sender {
    
    [HudManager showLoading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SystemUtils saveGifToPhotoAlbum:PATH_GIF completion:^(BOOL isSuccess, NSError *error) {
              NSData *data = [NSData dataWithContentsOfFile:PATH_GIF];
            NSLog(@"filePath = %@  gif = %.2f M ", PATH_GIF,(CGFloat)data.length / (1024.0 *1024));
            dispatch_async(dispatch_get_main_queue(), ^{
                [HudManager hideLoading];
                if (isSuccess){
                    [HudManager showWord:@"保存GIF成功"];
                    [self.navigationController dismissViewControllerAnimated:true completion:nil];
                    
                    if (self.dismissCallback) {
                        self.dismissCallback();
                    }
                }
                else{
                    [HudManager showWord:@"保存GIF失败"];
                }
            });
            
        }];
    });
}

@end
