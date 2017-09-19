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
    _wave = [[WaveView alloc]initWithFrame:CGRectMake(50, 200, 200, 200)];
    [self.view addSubview:_wave];
    [_wave startAnimation];
}


@end
