//
//  CellFlowLayout.h
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellFlowLayout : UICollectionViewFlowLayout

@property (assign, nonatomic) CGFloat kCollectionViewWidth;
@property (assign, nonatomic) CGFloat kCollectionViewHeight;
@property (assign, nonatomic) CGFloat kCollectionminimumLineSpacing;

@end

NS_ASSUME_NONNULL_END
