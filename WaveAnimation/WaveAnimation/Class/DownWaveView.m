//
//  DownWaveView.m
//  WaveAnimation
//
//  Created by bjovov on 2017/9/20.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import "DownWaveView.h"
@interface DownWaveView()
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) CAShapeLayer *waveSinLayer;
@property (nonatomic,strong) CAShapeLayer *waveCosLayer;
@property (nonatomic,strong) CADisplayLink *displayLink;

//振幅
@property (nonatomic,assign) CGFloat amplitude;
//角速度
@property (nonatomic,assign) CGFloat angularSpeed;
//初相
@property (nonatomic,assign) CGFloat offSetX;
//偏距
@property (nonatomic,assign) CGFloat offSetY;
@end

#define PhaseSpeed 0.3
@implementation DownWaveView
#pragma mark - Init Menthod
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUp];
    }
    return self;
}

- (void)setUp{
    //添加容器视图
    _containerView = [[UIView alloc]initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _containerView.layer.cornerRadius = CGRectGetWidth(self.bounds)/2.0;
    _containerView.layer.masksToBounds = YES;
    [self addSubview:_containerView];
    
    //添加水波曲线
    _waveCosLayer = [CAShapeLayer layer];
    _waveCosLayer.fillColor = [UIColor colorWithRed:166/255.0 green:228/255.0 blue:242/255.0 alpha:0.8].CGColor;
    _waveCosLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:_waveCosLayer];
    
    _waveSinLayer = [CAShapeLayer layer];
    _waveSinLayer.fillColor = [UIColor colorWithRed:58/255.0 green:234/255.0 blue:253/255.0 alpha:1].CGColor;
    _waveSinLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:_waveSinLayer];
    
    //参数配置
    _amplitude = 7;
    _angularSpeed = 1.1;
    _offSetX = CGRectGetWidth(self.containerView.bounds)/3;
    _offSetY = CGRectGetHeight(self.bounds)/2.0;
}


#pragma mark - private Menthod
- (void)startAnimation{
    [_displayLink invalidate];
    _displayLink = nil;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePath:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)updatePath:(CADisplayLink *)link{
    _offSetX += 0.1;
    _waveSinLayer.path = [self createLayerPathWithType:LayerTypeSin].CGPath;
    _waveCosLayer.path = [self createLayerPathWithType:LayerTypeCos].CGPath;
}

/*
 正弦曲线可表示为y=Asin(ωx+φ)+k
 */
- (UIBezierPath *)createLayerPathWithType:(LayerType *)type{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat Width = CGRectGetWidth(self.bounds);
    for (int i = 0; i <= Width; i++) {
        CGFloat CurrentY = 0.0;
        if (type == LayerTypeSin) {
            CurrentY = _amplitude *sinf(_angularSpeed * i * (360.0/Width) * (M_PI/180.0) + _offSetX) + _offSetY;
        }else {
            CurrentY = _amplitude *sinf(_angularSpeed * i * (360.0/Width) * (M_PI/180.0) + _offSetX + 1.9) + _offSetY;
        }
        if (i == 0) {
            [path moveToPoint:CGPointMake(i, CurrentY)];
        }else{
            [path addLineToPoint:CGPointMake(i, CurrentY)];
        }
    }
    [path addLineToPoint:CGPointMake(Width, CGRectGetHeight(self.bounds))];
    [path addLineToPoint:CGPointMake(0, CGRectGetHeight(self.bounds))];
    [path closePath];
    return path;
}



@end


