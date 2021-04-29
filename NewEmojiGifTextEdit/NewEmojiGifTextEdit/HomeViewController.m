//
//  HomeViewController.m
//  NewEmojiGifTextEdit
//
//  Created by db J on 2021/4/29.
//

#import "HomeViewController.h"
#import "GifTextEditCtrl.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //创建沙盒文件地址
    [SystemUtils successCreateMyGIFDirectory];
    [SystemUtils successCreateEditPhotoDirectory];
    
}
- (IBAction)clickEditBtn:(id)sender {
    
    GifTextEditCtrl *vc = [[GifTextEditCtrl alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
