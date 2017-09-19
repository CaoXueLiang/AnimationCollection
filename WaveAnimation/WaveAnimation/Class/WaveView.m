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
@property (nonatomic,strong) UIImageView *middleImageView;
@property (nonatomic,strong) UIImageView *topImageView;
@property (nonatomic,strong) UIView *containerView;

//振幅
@property (nonatomic,assign) CGFloat amplitude;
//角速度
@property (nonatomic,assign) CGFloat angularVelocity;
//初相(左右移动)
@property (nonatomic,assign) CGFloat offSetX;
//偏距(上下移动)
@property (nonatomic,assign) CGFloat offSetY;
@end

#define MoveSpeed 0.15//偏移量移动速度
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
    //容器视图
    _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    _containerView.layer.cornerRadius = _containerView.bounds.size.width/2.0;
    _containerView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    _containerView.layer.masksToBounds = YES;
    [self addSubview:_containerView];
    
    
    //底部图片(白底蓝字)
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:_containerView.bounds];
    backImageView.image = [UIImage imageNamed:@"blue"];
    [_containerView addSubview:backImageView];
    
    
    //添加中层图片(蓝底白字)
    _middleImageView = [[UIImageView alloc]initWithFrame:_containerView.bounds];
    _middleImageView.image = [UIImage imageNamed:@"white"];
    _middleImageView.backgroundColor = [UIColor colorWithRed:51/255.0f green:170/255.0f blue:255/255.0f alpha:1];
    [_containerView addSubview:_middleImageView];
    
    UIView *view = [[UIView alloc] initWithFrame:_middleImageView.bounds];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [_middleImageView addSubview:view];
    
    //上部图片(蓝底白字)
    _topImageView = [[UIImageView alloc]initWithFrame:_containerView.bounds];
    _topImageView.image = [UIImage imageNamed:@"white"];
    _topImageView.backgroundColor = [UIColor colorWithRed:51/255.0f green:170/255.0f blue:255/255.0f alpha:1];
    [_containerView addSubview:_topImageView];
    
    //参数配置
    self.amplitude = 3;
    self.angularVelocity = 0.1;
    self.offSetX = 0;
    self.offSetY = _containerView.bounds.size.height/2.0;
    
    
    //设置遮罩
    _waveCosLayer = [CAShapeLayer layer];
    _waveSinLayer = [CAShapeLayer layer];
    self.waveCosLayer.path = [self waveParhType:WaveTypeCos].CGPath;
    self.waveSinLayer.path = [self waveParhType:WaveTypeSin].CGPath;
    self.topImageView.layer.mask = self.waveSinLayer;
    self.middleImageView.layer.mask = self.waveCosLayer;
}

/*
 正弦曲线可表示为y=Asin(ωx+φ)+k
 我们就能计算出波浪曲线上任意位置的坐标点。通过UIBezierPath的函数addLineToPoint来把这些点连接起来，就构建了波浪形状的path。
 只要我们的设定相邻两点的间距够小，就能构建出平滑的正弦曲线
 */
- (UIBezierPath *)waveParhType:(WaveType)type{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat WIDTH = _containerView.bounds.size.width;
    CGFloat endX = 0.0;
    for (int i = 0; i <= WIDTH; i++) {
        CGFloat Y = 0.0;
        endX = i;
        if (type == WaveTypeSin) {
            Y = _amplitude *sinf(_angularVelocity*i + _offSetX) + _offSetY;
        }else if (type == WaveTypeCos){
            Y = _amplitude *sinf(_angularVelocity*i + _offSetX + 1) + _offSetY;
        }
        
        if (i == 0) {
            [path moveToPoint:CGPointMake(i,Y)];
        }else{
            [path addLineToPoint:CGPointMake(i, Y)];
        }
    }
    CGFloat endY = CGRectGetHeight(self.containerView.bounds);
    [path addLineToPoint:CGPointMake(endX, endY)];
    [path addLineToPoint:CGPointMake(0, endY)];
    [path closePath];
    return path;
}

#pragma mark - Event Response
- (void)updatePath:(CADisplayLink *)link{
    self.offSetX -= MoveSpeed;
    self.waveCosLayer.path = [self waveParhType:WaveTypeCos].CGPath;
    self.waveSinLayer.path = [self waveParhType:WaveTypeSin].CGPath;
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
