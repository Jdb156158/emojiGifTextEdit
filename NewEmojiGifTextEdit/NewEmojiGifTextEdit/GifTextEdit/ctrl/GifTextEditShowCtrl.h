//
//  GifTextEditShowCtrl.h
//  NewEmojiGifTextEdit
//
//  Created by db J on 2021/4/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GifTextEditShowCtrl : UIViewController
// 添加一个回调. 如果没有展示, 会立即调用回调.
+ (void)showWithDismissCallback:(void (^)(void))dismissCallback;
@end

NS_ASSUME_NONNULL_END
