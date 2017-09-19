//
//  WaveView.h
//  WaveAnimation
//
//  Created by bjovov on 2017/9/19.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WaveType){
    WaveTypeSin,
    WaveTypeCos,
};

/**
 水波浪线动画
 */
@interface WaveView : UIView
- (void)startAnimation;
- (void)endAnimation;

@end
