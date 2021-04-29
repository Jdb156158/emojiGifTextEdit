//
//  ViewController.m
//  EmojiGifTextEdit
//
//  Created by db J on 2021/4/28.
//

#import "ViewController.h"
#import "GifTextEditCtrl.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)clickGifListBtn:(id)sender {
    NSLog(@"====修改Gif====");
    GifTextEditCtrl *vc = [[GifTextEditCtrl alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
