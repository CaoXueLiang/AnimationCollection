//
//  ViewController.m
//  WaveAnimation
//
//  Created by bjovov on 2017/9/19.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import "ViewController.h"
#import "WaveView.h"

@interface ViewController ()
@property (nonatomic,strong) WaveView *wave;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _wave = [[WaveView alloc]initWithFrame:CGRectInset(self.view.bounds, 100, 100)];
    [_wave startAnimation];
    [self.view addSubview:_wave];
}


@end
