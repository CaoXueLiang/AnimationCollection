//
//  ViewController.m
//  WaveAnimation
//
//  Created by bjovov on 2017/9/19.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import "ViewController.h"
#import "WaveView.h"
#import "DownWaveView.h"

@interface ViewController ()
@property (nonatomic,strong) WaveView *wave;
@property (nonatomic,strong) DownWaveView *downView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _wave = [[WaveView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
    _wave.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, 150);
    [_wave startAnimation];
    [self.view addSubview:_wave];
    
    
    _downView = [[DownWaveView alloc]initWithFrame:CGRectMake(0, 0, 120, 120)];
    _downView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, 300);
    [self.view addSubview:_downView];
}


@end
