//
//  GifTextEditDetail.m
//  EmojiGifTextEdit
//
//  Created by db J on 2021/4/28.
//

#import "GifTextEditDetail.h"
#import "GifTextEditDetailCell.h"
#import "GifTextEditDetailHeadView.h"
@interface GifTextEditDetail ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (strong, nonatomic)  NSMutableArray *packageModels;
@property (strong, nonatomic)  UIView *headView;
@end

@implementation GifTextEditDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *array = self.dict[@"splitList"];
    self.packageModels = [NSMutableArray arrayWithArray:array];
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
    self.mytableview.sectionHeaderHeight = 60;
    self.headView = [[NSBundle mainBundle]loadNibNamed:@"GifTextEditDetailHeadView" owner:self options:nil].firstObject;
//    self.mytableview.tableHeaderView = self.headView;
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

@end
