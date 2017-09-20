//
//  DownWaveView.h
//  WaveAnimation
//
//  Created by bjovov on 2017/9/20.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LayerType){
    LayerTypeSin,
    LayerTypeCos,
};

/**
 水波下载view
 */
@interface DownWaveView : UIView
- (void)startAnimation;
@end
