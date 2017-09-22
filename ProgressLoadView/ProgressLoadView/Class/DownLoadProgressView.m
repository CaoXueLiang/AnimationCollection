//
//  DownLoadProgressView.m
//  ProgressLoadView
//
//  Created by bjovov on 2017/9/21.
//  Copyright © 2017年 CaoXueLiang.cn. All rights reserved.
//

#import "DownLoadProgressView.h"

#define AnimationKey  @"animationKeys"
#define CircleLineWidth 4 //圆环线宽
#define ArrowLineWidth  3 //箭头宽度

@interface DownLoadProgressView()<CAAnimationDelegate>
@property (nonatomic,strong) CADisplayLink *link;
/*白色进度条*/
@property (nonatomic,strong) CAShapeLayer *circleLayer;
/*淡色进度条背景*/
@property (nonatomic,strong) CAShapeLayer *backCircleLayer;
/*箭头竖线*/
@property (nonatomic,strong) CAShapeLayer *verticalLineLayer;
/*箭头端点线*/
@property (nonatomic,strong) CAShapeLayer *arrowsLayer;
@end

@implementation DownLoadProgressView{
    CGFloat _middleX;      //中心轴x
    CGFloat _LineHeight;   //竖线长度
    CGFloat _arrowWidth;   //箭头宽度
    CGFloat _arrowHeight;  //箭头长度
    CGFloat _horizontalArrowWidth;//箭头水平宽度
    CGFloat _arrowMoveDownPading; //箭头下移距离
    CGFloat _arrowMoveUpPading;   //箭头上移距离
}

#pragma mark - Init Menthod
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:28/255.0 green:136/255.0 blue:238/255.0 alpha:1];
        [self setUp];
        [self addSubViews];
        [self addTapGesture];
    }
    return self;
}

- (void)addSubViews{
    _backCircleLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.frame];
    _backCircleLayer.path = path.CGPath;
    _backCircleLayer.lineWidth = CircleLineWidth;
    _backCircleLayer.strokeColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3].CGColor;
    _backCircleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:_backCircleLayer];
    
    
    _circleLayer = [CAShapeLayer layer];
    _verticalLineLayer = [CAShapeLayer layer];
    _verticalLineLayer.path = [self beginVerticalLinePath].CGPath;
    _verticalLineLayer.strokeColor = [UIColor whiteColor].CGColor;
    _verticalLineLayer.fillColor = [UIColor clearColor].CGColor;
    _verticalLineLayer.lineCap = kCALineCapRound;
    _verticalLineLayer.lineJoin = kCALineJoinRound;
    _verticalLineLayer.lineWidth = ArrowLineWidth;
    [self.layer addSublayer:_verticalLineLayer];
    
    
    _arrowsLayer = [CAShapeLayer layer];
    _arrowsLayer.path = [self beginArrawPath].CGPath;
    _arrowsLayer.strokeColor = [UIColor whiteColor].CGColor;
    _arrowsLayer.fillColor = [UIColor clearColor].CGColor;
    _arrowsLayer.lineCap = kCALineCapRound;
    _arrowsLayer.lineJoin = kCALineJoinRound;
    _arrowsLayer.lineWidth = ArrowLineWidth;
    [self.layer addSublayer:_arrowsLayer];
}

- (void)setUp{
    /*初始化参数值*/
    _middleX = CGRectGetWidth(self.frame)/2.0;
    _LineHeight = CGRectGetHeight(self.frame) *0.5;
    _arrowWidth = CGRectGetWidth(self.frame) *0.16;
    _arrowHeight = CGRectGetHeight(self.frame) *0.16;
    _horizontalArrowWidth = CGRectGetWidth(self.frame) * 0.7;
    _arrowMoveDownPading = CGRectGetHeight(self.frame) *0.06;
    _arrowMoveUpPading = CGRectGetHeight(self.frame) *0.03;
}

- (void)addTapGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startAniamtion:)];
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
}

- (void)UpDate:(CADisplayLink *)link{
    self.circleLayer.path = [self circleProgressPath].CGPath;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
}

#pragma mark - Animations
- (void)startAniamtion:(UITapGestureRecognizer *)recognizer{
    
    [self VerticalLineToPointAnimation];
    [self arrowToLineAnimation];
}

/*竖线-->点*/
- (void)VerticalLineToPointAnimation{
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    keyAnimation.values = @[(__bridge id)[self beginVerticalLinePath].CGPath,
                            (__bridge id)[self verticalLinePointPath].CGPath];
    keyAnimation.duration = 1;
    keyAnimation.beginTime = CACurrentMediaTime();
    keyAnimation.delegate = self;
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    [keyAnimation setValue:@"lineToPoint" forKey:AnimationKey];
    [self.verticalLineLayer addAnimation:keyAnimation forKey:nil];
}

/*点上弹动画*/
- (void)pointPopUpAnimation{
    CASpringAnimation *positionAnimation = [CASpringAnimation animationWithKeyPath:@"position"];
    positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -(CGRectGetHeight(self.frame)/2.0) + CircleLineWidth/2.0 + 1)];
    positionAnimation.mass = 1.0;
    positionAnimation.damping = 10.0;
    positionAnimation.initialVelocity = 40.0;
    positionAnimation.duration = 1;
    positionAnimation.removedOnCompletion = NO;
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    positionAnimation.delegate = self;
    [positionAnimation setValue:@"popUp" forKey:AnimationKey];
    [self.verticalLineLayer addAnimation:positionAnimation forKey:nil];
}

/*箭头-->直线*/
- (void)arrowToLineAnimation{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    animation.values = @[(__bridge id)[self beginArrawPath].CGPath,
                         (__bridge id)[self arrowDownPath].CGPath,
                         (__bridge id)[self arrowUpPath].CGPath,
                         (__bridge id)[self horizontalArrowLinePath].CGPath,];
    animation.duration = 1.4;
    animation.keyTimes = @[@0,@0.15,@0.25,@0.28];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    animation.beginTime = CACurrentMediaTime() + 0.6;
    [animation setValue:@"arrowToLine" forKey:AnimationKey];
    [self.arrowsLayer addAnimation:animation forKey:nil];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([[anim valueForKey:AnimationKey] isEqualToString:@"lineToPoint"]) {
        [self pointPopUpAnimation];
        
    }else if ([[anim valueForKey:AnimationKey] isEqualToString:@"popUp"]){
        [_link invalidate];
        _link = nil;
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(UpDate:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    }else if ([[anim valueForKey:AnimationKey] isEqualToString:@"arrowToLine"]){
    
    }
}

#pragma mark - UIBezierPath
/**初始竖线path*/
- (UIBezierPath *)beginVerticalLinePath{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(_middleX, (CGRectGetHeight(self.frame)-_LineHeight)/2.0)];
    [linePath addLineToPoint:CGPointMake(_middleX, ((CGRectGetHeight(self.frame)-_LineHeight)/2.0) + _LineHeight)];
    return linePath;
}

/*竖线变成点后的path*/
- (UIBezierPath *)verticalLinePointPath{
    UIBezierPath *pointPath = [UIBezierPath bezierPath];
    [pointPath moveToPoint:CGPointMake(_middleX, CGRectGetHeight(self.frame)/2.0-3)];
    [pointPath addLineToPoint:CGPointMake(_middleX, CGRectGetHeight(self.frame)/2.0-3)];
    return pointPath;
}

/**初始箭头path*/
- (UIBezierPath *)beginArrawPath{
    CGFloat currentHeight = ((CGRectGetHeight(self.frame)-_LineHeight)/2.0) + _LineHeight;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(_middleX - _arrowWidth, currentHeight - _arrowHeight)];
    [path addLineToPoint:CGPointMake(_middleX, currentHeight)];
    [path addLineToPoint:CGPointMake(_middleX + _arrowWidth, currentHeight - _arrowHeight)];
    return path;
}

/*箭头下移Path*/
- (UIBezierPath *)arrowDownPath{
    CGFloat currentHeight = ((CGRectGetHeight(self.frame)-_LineHeight)/2.0) + _LineHeight;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(_middleX - _arrowWidth, currentHeight - _arrowHeight + _arrowMoveDownPading)];
    [path addLineToPoint:CGPointMake(_middleX, currentHeight + _arrowMoveDownPading)];
    [path addLineToPoint:CGPointMake(_middleX + _arrowWidth, currentHeight - _arrowHeight + _arrowMoveDownPading)];
    return path;
}

/*箭头上移Path*/
- (UIBezierPath *)arrowUpPath{
    CGFloat start = (CGRectGetWidth(self.frame) - _horizontalArrowWidth)/2.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(start, CGRectGetHeight(self.frame)/2.0)];
    [path addLineToPoint:CGPointMake(_middleX, CGRectGetHeight(self.frame)/2.0 - _arrowMoveUpPading)];
    [path addLineToPoint:CGPointMake(start + _horizontalArrowWidth, CGRectGetHeight(self.frame)/2.0)];
    return path;
}

/*箭头变成水平线*/
- (UIBezierPath *)horizontalArrowLinePath{
    CGFloat start = (CGRectGetWidth(self.frame) - _horizontalArrowWidth)/2.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(start, CGRectGetHeight(self.frame)/2.0)];
    [path addLineToPoint:CGPointMake(_middleX, CGRectGetHeight(self.frame)/2.0)];
    [path addLineToPoint:CGPointMake(start + _horizontalArrowWidth, CGRectGetHeight(self.frame)/2.0)];
    return path;
}

/**初始下载进度path*/
- (UIBezierPath *)circleProgressPath{
    CGFloat startPoint = M_PI*3/2.0;
    CGFloat endAngle = startPoint - M_PI*2*_progress;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0) radius:CGRectGetWidth(self.frame)/2.0 startAngle:startPoint endAngle:endAngle clockwise:NO];
    return circlePath;
}



@end


