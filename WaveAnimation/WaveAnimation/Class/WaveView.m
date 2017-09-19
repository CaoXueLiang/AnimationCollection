//
//  WaveView.m
//  WaveAnimation
//
//  Created by bjovov on 2017/9/19.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import "WaveView.h"

@interface WaveView()
@property (nonatomic,strong) CAShapeLayer *waveSinLayer;
@property (nonatomic,strong) CAShapeLayer *waveCosLayer;
@property (nonatomic,strong) CADisplayLink *dispalyLink;

//波浪相关的参数
@property (nonatomic, assign) CGFloat waveWidth;
@property (nonatomic, assign) CGFloat waveHeight;
@property (nonatomic, assign) CGFloat frequency;
@property (nonatomic, assign) CGFloat waveMid;
@property (nonatomic, assign) CGFloat maxAmplitude;
@property (nonatomic, assign) CGFloat phaseShift;
@property (nonatomic, assign) CGFloat phase;
@end

@implementation WaveView
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
    self.waveSinLayer = [CAShapeLayer layer];
    self.waveSinLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.waveSinLayer.fillColor = [UIColor whiteColor].CGColor;
    self.waveSinLayer.strokeColor = [UIColor clearColor].CGColor;
    self.waveSinLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.waveSinLayer.position = CGPointMake(CGRectGetWidth(self.bounds)/2.0, 300);
    [self.layer addSublayer:self.waveSinLayer];
    
    self.waveCosLayer = [CAShapeLayer layer];
    self.waveCosLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.waveCosLayer.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4].CGColor;
    self.waveCosLayer.strokeColor = [UIColor clearColor].CGColor;
    self.waveCosLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.waveCosLayer.position = CGPointMake(CGRectGetWidth(self.bounds)/2.0, 300);
    [self.layer addSublayer:self.waveCosLayer];
    
    //设置函数的参数
    self.waveWidth = CGRectGetWidth(self.bounds);
    self.waveHeight = CGRectGetHeight(self.bounds) * 0.5;
    self.frequency = 0.3;
    self.phaseShift = 8;
    self.waveMid = self.waveWidth/2.0;
    self.maxAmplitude = self.waveHeight *0.2;
    self.phase = 0;
}

- (void)drawRect:(CGRect)rect{
    self.waveCosLayer.path = [self waveParhType:WaveTypeCos].CGPath;
    self.waveSinLayer.path = [self waveParhType:WaveTypeSin].CGPath;
}

/*
 正弦曲线可表示为y=Asin(ωx+φ)+k
 我们就能计算出波浪曲线上任意位置的坐标点。通过UIBezierPath的函数addLineToPoint来把这些点连接起来，就构建了波浪形状的path。
 只要我们的设定相邻两点的间距够小，就能构建出平滑的正弦曲线
 */
- (UIBezierPath *)waveParhType:(WaveType)type{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat WIDTH = CGRectGetWidth(self.bounds);
    CGFloat endX = 0.0;
    for (int i = 0; i < WIDTH + 1; i++) {
        CGFloat Y = 0.0;
        endX = i;
        if (type == WaveTypeSin) {
            Y = self.maxAmplitude *sinf(i * (M_PI/180.0)*(360.0/_waveWidth) + self.phase *(M_PI/180.0)) + self.maxAmplitude;
        }else if (type == WaveTypeCos){
            Y = self.maxAmplitude *cosf(i * (M_PI/180.0)*(360.0/_waveWidth) + self.phase *(M_PI/180.0)) + self.maxAmplitude;
        }
        
        if (i == 0) {
            [path moveToPoint:CGPointMake(i,Y)];
        }else{
            [path addLineToPoint:CGPointMake(i, Y)];
        }
    }
    CGFloat endY = CGRectGetHeight(self.bounds) + 10;
    [path addLineToPoint:CGPointMake(endX, endY)];
    [path addLineToPoint:CGPointMake(0, endY)];
    [path closePath];
    return path;
}

#pragma mark - Event Response
- (void)updatePath:(CADisplayLink *)link{
    self.phase += self.phaseShift;
    [self setNeedsDisplay];
}

- (void)startAnimation{
    [self.dispalyLink invalidate];
    self.dispalyLink = nil;
    self.dispalyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePath:)];
    [self.dispalyLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)endAnimation{
    [self.dispalyLink invalidate];
}

@end
