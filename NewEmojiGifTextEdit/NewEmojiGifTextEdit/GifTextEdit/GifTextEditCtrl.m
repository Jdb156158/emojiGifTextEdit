//
//  GifTextEditCtrl.m
//  EmojiGifTextEdit
//
//  Created by db J on 2021/4/28.
//

#import "GifTextEditCtrl.h"
#import "CellFlowLayout.h"
#import "GifTextEditListCell.h"
#import "GifTextEditDetail.h"
@interface GifTextEditCtrl ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *cententView;
@property (nonatomic, strong) NSMutableArray *packageModels;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation GifTextEditCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *foodPlistPath =[[NSBundle mainBundle] pathForResource:@"test" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:foodPlistPath];
    NSArray *array = dict[@"data"];
    self.packageModels = [NSMutableArray arrayWithArray:array];
    NSLog(@"++++%@++",self.packageModels);
    
    [self.cententView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.mas_equalTo(self.cententView).offset(0);
    }];
}

#pragma mark - get
- (NSMutableArray *)packageModels {
    
    if (!_packageModels) {
        _packageModels = [NSMutableArray array];
    }
    return _packageModels;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        CellFlowLayout *configLayout = [[CellFlowLayout alloc]init];
        configLayout.kCollectionViewWidth = ([UIScreen mainScreen].bounds.size.width-45)/2;
        configLayout.kCollectionViewHeight = 120;
        configLayout.kCollectionminimumLineSpacing = 15;
        configLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        configLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,self.view.frame.size.height) collectionViewLayout:configLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"GifTextEditListCell" bundle:nil] forCellWithReuseIdentifier:@"GifTextEditListCell"];


    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.packageModels.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section>=self.packageModels.count) {
        //防止数组越界
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GifTextEditListCell" forIndexPath:indexPath];
        return cell;
    }
    
    NSDictionary *dict = self.packageModels[indexPath.item];
    
    GifTextEditListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GifTextEditListCell" forIndexPath:indexPath];
    [cell.centetImage sd_setImageWithURL:[NSURL URLWithString:dict[@"url"]]];
    cell.bottomLabel.text = dict[@"title"];
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.packageModels[indexPath.item];
    GifTextEditDetail *vc = [[GifTextEditDetail alloc] init];
    vc.dict = dict;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
