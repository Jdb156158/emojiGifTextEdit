//
//  GifTextEditDetail.m
//  EmojiGifTextEdit
//
//  Created by db J on 2021/4/28.
//

#import "GifTextEditDetail.h"
#import "GifTextEditDetailCell.h"
#import "GifTextEditDetailHeadView.h"
#import "GifTextEditDetailFootView.h"
#import "GifTextEditShowCtrl.h"
@interface GifTextEditDetail ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (strong, nonatomic)  NSMutableArray *packageModels;
@property (strong, nonatomic)  GifTextEditDetailHeadView *headView;
@property (strong, nonatomic)  GifTextEditDetailFootView *footView;
@property (strong, nonatomic)  NSString *headImageUrl;
@end

@implementation GifTextEditDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *array = self.dict[@"splitList"];
    self.packageModels = [NSMutableArray arrayWithArray:array];
    self.headImageUrl = self.dict[@"url"];
    [self setupTableView];
        
}

#pragma mark - get
- (NSMutableArray *)packageModels {
    
    if (!_packageModels) {
        _packageModels = [NSMutableArray array];
    }
    return _packageModels;
}

- (void)setupTableView {
    [self.mytableview registerNib:[UINib nibWithNibName:@"GifTextEditDetailCell" bundle:nil] forCellReuseIdentifier:@"GifTextEditDetailCell"];

    self.mytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mytableview.delegate = self;
    self.mytableview.dataSource = self;
    self.headView = [[NSBundle mainBundle]loadNibNamed:@"GifTextEditDetailHeadView" owner:self options:nil].firstObject;
    [self.headView.headImageView sd_setImageWithURL:[NSURL URLWithString:self.headImageUrl]];
    self.mytableview.tableHeaderView = self.headView;
    self.footView = [[NSBundle mainBundle]loadNibNamed:@"GifTextEditDetailFootView" owner:self options:nil].firstObject;
    self.mytableview.tableFooterView = self.footView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.packageModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GifTextEditDetailCell *cell = [self.mytableview dequeueReusableCellWithIdentifier:@"GifTextEditDetailCell" forIndexPath:indexPath];
    
    NSDictionary *dict = self.packageModels[indexPath.item];
    cell.textField.placeholder = dict[@"sample"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

//获取tableView上面所有的cell

- (NSArray *)cellsForTableView:(UITableView *)tableView
{

    NSInteger sections = tableView.numberOfSections;

    NSMutableArray *cells = [[NSMutableArray alloc] init];

    for (int section = 0; section < sections; section++) {

        NSInteger rows = [tableView numberOfRowsInSection:section];

        for (int row = 0; row < rows; row++) {

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];

            [cells addObject:[tableView cellForRowAtIndexPath:indexPath]];
        }

    }
    return cells;

}


- (IBAction)clickOkBtn:(id)sender {
    
    NSLog(@"====生成Gif====:%@",[self cellsForTableView:self.mytableview]);
    
    NSArray *cellArray = [self cellsForTableView:self.mytableview];
    NSMutableArray *textArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<cellArray.count; i++) {
        GifTextEditDetailCell *cell = cellArray[i];
        NSDictionary *dict = self.packageModels[i];
        if (cell.textField.text.length>0) {
            NSDictionary *newdict = @{@"sample":cell.textField.text,@"startFrame":dict[@"startFrame"],@"endFrame":dict[@"endFrame"]};
            [textArray addObject:newdict];
        }else{
            NSDictionary *newdict = @{@"sample":cell.textField.placeholder,@"startFrame":dict[@"startFrame"],@"endFrame":dict[@"endFrame"]};
            [textArray addObject:newdict];
        }
        
    }
        
    
    NSString *gifPath = [[SDImageCache sharedImageCache] cachePathForKey:self.headImageUrl];
    NSData *gifData = nil;
    if (gifPath) {
        gifData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:gifPath]];
    }else{
        gifData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.headImageUrl]];
    }
    
    [HudManager showLoading];
        
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [SystemUtils requestAlbumAuth:^(bool isAllowed) {
            if (isAllowed) {
                [GifUtils imgsFromGifWithData:gifData textDictArray:textArray completeHnadler:^(float imgDelay, NSMutableArray *imgsArr) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (imgsArr.count>0) {
                            [self imagesToGif:imgsArr];
                        }else{
                            [HudManager hideLoading];
                            [HudManager showWord:@"生成GIF失败"];
                        }
                    });
                                
                }];
            }
        }];

    });
}

- (void)imagesToGif:(NSArray *)images{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [GifUtils gifWithImages:images withDelay:0.1 targetPath:PATH_GIF];
        dispatch_async(dispatch_get_main_queue(), ^{
            [HudManager hideLoading];
            //弹框展示
            [GifTextEditShowCtrl showWithDismissCallback:^{
                
            }];
            
        });
    });
    
}


@end
