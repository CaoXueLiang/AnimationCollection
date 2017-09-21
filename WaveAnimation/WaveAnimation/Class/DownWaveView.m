//
//  DownWaveView.m
//  WaveAnimation
//
//  Created by bjovov on 2017/9/20.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import "DownWaveView.h"
@interface DownWaveView()
//圆形容器视图
@property (nonatomic,strong) UIView *containerView;
//辅助视图(用于放大)
@property (nonatomic,strong) UIView *tmpConatinerView;
//下载箭头
@property (nonatomic,strong) CAShapeLayer *arrowsLayer;
//对勾layer
@property (nonatomic,strong) CAShapeLayer *checkLayer;
//正弦波浪线
@property (nonatomic,strong) CAShapeLayer *waveSinLayer;
//余弦波浪线
@property (nonatomic,strong) CAShapeLayer *waveCosLayer;
//定时器
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
    _tmpConatinerView = [[UIView alloc]initWithFrame:CGRectInset(self.bounds, -5, -5)];
    _tmpConatinerView.backgroundColor = [UIColor colorWithRed:58/255.0 green:234/255.0 blue:253/255.0 alpha:0.7];
    _tmpConatinerView.layer.cornerRadius = CGRectGetWidth(_tmpConatinerView.bounds)/2.0;
    _tmpConatinerView.layer.masksToBounds = YES;
    _tmpConatinerView.hidden = YES;
    [self addSubview:_tmpConatinerView];
    
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
    
    
    //添加下载箭头和对勾
    [self.containerView.layer addSublayer:self.arrowsLayer];
    [self.containerView.layer addSublayer:self.checkLayer];
    
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:recognizer];
    
    [self reSetAnimation];
}

- (void)reSetAnimation{
    //参数配置
    _amplitude = 7;
    _angularSpeed = 1.1;
    _offSetX = CGRectGetWidth(self.containerView.bounds)/3;
    _offSetY = CGRectGetHeight(self.bounds);
    
    self.arrowsLayer.hidden = NO;
    self.checkLayer.hidden = YES;
    self.containerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tmpConatinerView.alpha = 0.7;
    self.tmpConatinerView.transform = CGAffineTransformIdentity;
}


#pragma mark - private Menthod
- (void)tap:(UITapGestureRecognizer *)gesture{
    [self reSetAnimation];
    self.arrowsLayer.hidden = YES;
    [self startAnimation];
}

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
    _offSetX += 0.12;
    _offSetY -= 0.3;
    _waveSinLayer.path = [self createLayerPathWithType:LayerTypeSin].CGPath;
    _waveCosLayer.path = [self createLayerPathWithType:LayerTypeCos].CGPath;
    if (_offSetY <= -_amplitude) {
        [self stopAnimation];
        //水波灌满后，将背景色设置为淡蓝色
        self.containerView.backgroundColor = [UIColor colorWithRed:58/255.0 green:234/255.0 blue:253/255.0 alpha:1];
        
        //开始stroken动画
        [self startCheckStokeAnimation];
    }
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

- (void)startCheckStokeAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.4;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    self.checkLayer.hidden = NO;
    [animation setValue:@"strokeAnimation" forKey:@"ANIMATIONKEY"];
    [self.checkLayer addAnimation:animation forKey:nil];
}


- (void)scaleAnimation{
   [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
       self.containerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
       
   } completion:^(BOOL finished) {
          
      [UIView animateWithDuration: 0.3 delay: 0.0 usingSpringWithDamping: 10 initialSpringVelocity: 50 options:UIViewAnimationOptionCurveEaseInOut animations:^{
           self.containerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
          
            }completion:^(BOOL finished) {
        
        }];
       
       self.tmpConatinerView.hidden = NO;
       [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
           self.tmpConatinerView.transform = CGAffineTransformMakeScale(2.5, 2.5);
           self.tmpConatinerView.alpha = 0;
       } completion:^(BOOL finished) {
           self.tmpConatinerView.hidden = YES;
       }];
   }];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([[anim valueForKey:@"ANIMATIONKEY"] isEqualToString:@"strokeAnimation"]) {
        //开始scale动画
        [self scaleAnimation];
    }
}

#pragma mark - Setter && Getter
- (CAShapeLayer *)arrowsLayer{
    if (!_arrowsLayer) {
        _arrowsLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat biasLength = width*0.3;//箭头斜线的长度
        [path moveToPoint:CGPointMake(width/2.0, width*0.2)];
        [path addLineToPoint:CGPointMake(width/2.0, width*0.8)];
        CGPoint leftPoint = CGPointMake(width/2.0 - biasLength*sinf(45.0*M_PI/180), width*0.8 - biasLength*cosf(45.0*M_PI/180));
        CGPoint rightPoint = CGPointMake(width/2.0 + biasLength*sinf(45.0*M_PI/180), width*0.8 - biasLength*cosf(45.0*M_PI/180));
        [path addLineToPoint:leftPoint];
        [path moveToPoint:CGPointMake(width/2.0, width*0.8)];
        [path addLineToPoint:rightPoint];
        _arrowsLayer.path = path.CGPath;
        _arrowsLayer.strokeColor = [UIColor colorWithRed:58/255.0 green:234/255.0 blue:253/255.0 alpha:1].CGColor;
        _arrowsLayer.lineWidth = 3;
        _arrowsLayer.fillColor = [UIColor clearColor].CGColor;
        _arrowsLayer.lineJoin = kCALineJoinRound;
        _arrowsLayer.lineCap = kCALineCapRound;
        _arrowsLayer.hidden = NO;
    }
    return _arrowsLayer;
}

- (CAShapeLayer *)checkLayer{
    if (!_checkLayer) {
        _checkLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGRect rectInCircle = CGRectInset(self.bounds, self.bounds.size.width*(1-1/sqrt(2.0))/2, self.bounds.size.width*(1-1/sqrt(2.0))/2);
        [path moveToPoint:CGPointMake(rectInCircle.origin.x + rectInCircle.size.width/9, rectInCircle.origin.y + rectInCircle.size.height*2/3)];
        [path addLineToPoint:CGPointMake(rectInCircle.origin.x + rectInCircle.size.width/3,rectInCircle.origin.y + rectInCircle.size.height*9/10)];
        [path addLineToPoint:CGPointMake(rectInCircle.origin.x + rectInCircle.size.width*8/10, rectInCircle.origin.y + rectInCircle.size.height*2/10)];
        _checkLayer.path = path.CGPath;
        _checkLayer.strokeColor = [UIColor whiteColor].CGColor;
        _checkLayer.lineWidth = 10;
        _checkLayer.fillColor = [UIColor clearColor].CGColor;
        _checkLayer.lineJoin = kCALineJoinRound;
        _checkLayer.lineCap = kCALineCapRound;
        _checkLayer.hidden = YES;
    }
    return _checkLayer;
}

@end


