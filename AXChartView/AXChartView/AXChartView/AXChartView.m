//
//  AXChartView.m
//  AXChartView
//
//  Created by xaoxuu on 14/09/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import "AXChartView.h"


static CGFloat margin = 8.0;
// @xaoxuu: 连接点的宽度（直径）
static CGFloat pointRadius = 4;


// @xaoxuu: 顶部标签高度
static CGFloat topLabelHeight = 24;
// @xaoxuu: 底部标签高度
static CGFloat bottomLabelHeight = 20;

static CGFloat popViewHeight = 28;
static CGFloat popViewWeight = 50;


@interface AXChartView ()

@property (assign, nonatomic) NSUInteger itemCount;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *itemValues;
@property (strong, nonatomic) NSMutableArray<NSString *> *itemTitles;


@property (strong, nonatomic) NSMutableArray<NSValue *> *valuePoints;

@property (assign, nonatomic) CGFloat frameWidth;
@property (assign, nonatomic) CGFloat frameHeight;

@property (assign, nonatomic) CGFloat chartWidth;
@property (assign, nonatomic) CGFloat chartHeight;
@property (assign, nonatomic) CGFloat itemWidth;



@property(nonatomic,strong) UIView *popView;    //运动数据的节点
@property(nonatomic,strong) UILabel *popLabel;   //运动节点对应的lb

@property(nonatomic,strong) CAShapeLayer *arrowLayer;   //箭头指向
@property(nonatomic,strong) CAShapeLayer *borderLayer;  //边框layer

@property (assign, nonatomic) NSUInteger currentIndex;

@end

@implementation AXChartView

#pragma mark - public

- (void)reloadData{
    [self.itemValues removeAllObjects];
    [self.itemTitles removeAllObjects];
    self.itemCount = 0;
    
    [self.valuePoints removeAllObjects];
    
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
    while (self.layer.sublayers.count) {
        [self.layer.sublayers.lastObject removeFromSuperlayer];
    }
    
    
    [self setNeedsDisplay];
    
    
}

#pragma mark - life cirlce

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self _init];
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _frameWidth = frame.size.width;
    _frameHeight = frame.size.height;
}
- (void)_init{
    
    
    _valuePoints = [NSMutableArray array];
    self.lineWidth = 1;
    self.accentColor = [UIColor grayColor];
    self.lineColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor lightGrayColor];
    
}


- (void)prepareToDraw{
    self.chartWidth = self.frame.size.width - 2 * margin;
    self.chartHeight = self.frame.size.height - topLabelHeight - bottomLabelHeight - margin;
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    
    // @xaoxuu: 渐变色背景
    if ([self.delegate respondsToSelector:@selector(chartViewWillSetGradientLayer:)]) {
        // @xaoxuu: 渐变色图层作为背景
        CALayer *bgLayer = [CALayer layer];
        bgLayer.frame = self.bounds;
        bgLayer.backgroundColor = [UIColor redColor].CGColor;
        [self.layer addSublayer:bgLayer];
        // @xaoxuu: 绘制渐变色层
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        [gradientLayer setColors:@[(id)[UIColor colorWithRed:248/255.0 green:207/255.0 blue:54/255.0 alpha:1.00].CGColor, (id)[UIColor colorWithRed:253/255.0 green:166/255.0 blue:65/255.0 alpha:1.00].CGColor]];
        [gradientLayer setStartPoint:CGPointMake(0, 0)];
        [gradientLayer setEndPoint:CGPointMake(1, 1)];
        [self.delegate chartViewWillSetGradientLayer:gradientLayer];
        gradientLayer.frame = self.bounds;
        [bgLayer addSublayer:gradientLayer];
    }
    
    CGFloat halfWidth = 0.5 * self.chartWidth;
    
    
    // @xaoxuu: 顶部标签
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin/2, halfWidth, topLabelHeight)];
    title.text = self.title;
    title.font = [UIFont systemFontOfSize:13];
    title.textColor = self.lineColor;
    [self addSubview:title];
    
    UILabel *currentValue = [[UILabel alloc] initWithFrame:CGRectMake(margin + halfWidth, margin/2, halfWidth, topLabelHeight)];
    currentValue.textAlignment = NSTextAlignmentRight;
    currentValue.text = self.itemValues.lastObject.stringValue;
    currentValue.font = [UIFont boldSystemFontOfSize:15];
    currentValue.textColor = self.lineColor;
    [self addSubview:currentValue];
    
    // @xaoxuu: 顶部横线
    CALayer *topLine = [CALayer layer];
    topLine.frame = CGRectMake(margin, margin + topLabelHeight, self.chartWidth, 0.5);
    topLine.backgroundColor = self.lineColor.CGColor;
    [self.layer addSublayer:topLine];
    
    //底部标签
    NSInteger steps = 1;
    if ([self.dataSource respondsToSelector:@selector(chartViewShowTitleForIndexWithSteps)]) {
        steps = MAX(1, [self.dataSource chartViewShowTitleForIndexWithSteps]);
    }
    CGFloat labelWidth = steps * self.itemWidth;
    __block CGFloat lastLeft = margin;
    [self.itemTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!(idx%steps)) {
            UILabel *verLb=  [[UILabel alloc] init];
            verLb.font = [UIFont systemFontOfSize:12];
            verLb.text = obj;
            verLb.textColor = self.lineColor;
            verLb.textAlignment = NSTextAlignmentCenter;
            verLb.adjustsFontSizeToFitWidth = YES;
//            CGFloat left = margin + (idx - 0.5) * self.itemWidth;
            CGFloat width = labelWidth;
            if (idx == 0) {
//                left = margin;
                width = 0.5 * labelWidth;
                verLb.textAlignment = NSTextAlignmentLeft;
            } else if (idx == self.itemTitles.count - 1) {
                width = 0.5 * labelWidth;
                verLb.textAlignment = NSTextAlignmentRight;
            }
            CGRect frame = CGRectMake(lastLeft, self.frameHeight - bottomLabelHeight - margin/2, width, bottomLabelHeight);
            lastLeft += width;
            verLb.frame = frame;
            [self addSubview:verLb];
        }
        
    }];
    
    
}


- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    [self prepareToDraw];
    
    CGFloat top = topLabelHeight;
    CGFloat bottom = self.chartHeight + top;
    CGFloat left = margin;
    CGFloat right = margin + self.chartWidth;
    
    CGFloat itemWidth = self.itemWidth;
    [[UIColor whiteColor] setStroke];
    [self.backgroundColor setFill];
    
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    UIBezierPath *strokePath = [UIBezierPath bezierPath];
    fillPath.lineWidth = self.lineWidth;
    fillPath.lineCapStyle = kCGLineCapRound; //线条拐角
    fillPath.lineJoinStyle = kCGLineJoinRound; //终点处理
    strokePath.lineCapStyle = kCGLineCapRound; //线条拐角
    strokePath.lineJoinStyle = kCGLineJoinRound; //终点处理
    
    // @xaoxuu: 起始/终止点
    CGPoint startPoint = CGPointMake(left, bottom);
    CGPoint endPoint = CGPointMake(right, bottom);
    [fillPath moveToPoint:startPoint];
    [strokePath moveToPoint:startPoint];
    
    // @xaoxuu: 找出最大值，确定比例
    __block NSNumber *maxValue = @0;
    [self.itemValues enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (maxValue.doubleValue < obj.doubleValue) {
            maxValue = obj;
        }
    }];
    if ([self.dataSource respondsToSelector:@selector(chartViewMaxValue)]) {
        NSNumber *tmp = [self.dataSource chartViewMaxValue];
        if (maxValue.doubleValue < tmp.doubleValue) {
            maxValue = tmp;
        }
    }
    [self.itemValues enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat height = 0;
        if (maxValue.doubleValue > 0) {
            height = 0.75 * self.chartHeight * self.itemValues[idx].doubleValue / maxValue.doubleValue;
        } else {
            // @xaoxuu: 最大值为0,取值可能在0以下
            
        }
        CGPoint po = CGPointMake(left + itemWidth * idx, bottom - height);
        [self.valuePoints addObject:[NSValue valueWithCGPoint:po]];
        
        CALayer *circle = [CALayer layer];
        circle.frame = CGRectMake(0, 0, pointRadius, pointRadius);
        circle.cornerRadius = 0.5*pointRadius;
        circle.position = po;
        circle.backgroundColor = self.lineColor.CGColor;
        [self.layer addSublayer:circle];
        
        [fillPath addLineToPoint:po];
        if (idx == 0) {
            [strokePath moveToPoint:po];
        } else {
            [strokePath addLineToPoint:po];
        }
        
    }];
    [fillPath addLineToPoint:endPoint];
    [fillPath addLineToPoint:startPoint];
    [fillPath fill];
    [strokePath stroke];
    
    // @xaoxuu: 将填充层半透明
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = fillPath.CGPath;
    fillLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.4].CGColor;
    [self.layer addSublayer:fillLayer];
    
    
    CAShapeLayer *strokeLayer = [CAShapeLayer layer];
    strokeLayer.fillColor = [UIColor clearColor].CGColor;
    strokeLayer.strokeColor = [UIColor whiteColor].CGColor;
    strokeLayer.path = strokePath.CGPath;
    [self.layer addSublayer:strokeLayer];
    
    
}


#pragma mark - event


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self showTipWithPoint:touchPoint];
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self showTipWithPoint:touchPoint];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.popView.hidden = YES;
        self.popLabel.hidden = YES;
        self.currentIndex = NSUIntegerMax;
    });
    
}

- (void)startAnimation {
    //路径动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.fromValue = @(0);
    pathAnimation.toValue = @(1);
    pathAnimation.duration = 1.5;
    pathAnimation.repeatCount = 1;
    [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addAnimation:pathAnimation forKey:@"strokePathAnimation"];
    }];
}

#pragma mark - priv

- (void)showTipWithPoint:(CGPoint)touchPoint{
    
    if (touchPoint.y > margin + topLabelHeight) {
        [self.valuePoints enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint point = [obj CGPointValue];
            if (touchPoint.x > (point.x - 0.5 * self.itemWidth) && touchPoint.x < (point.x + 0.5 * self.itemWidth)) {
                if (self.currentIndex != idx) {
                    [self selectIndex:idx];
                }
            }
        }];
    }
    
}


- (void)selectIndex:(NSUInteger)index{
    self.currentIndex = index;
    if ([self.delegate respondsToSelector:@selector(chartViewDidSelectItemWithIndex:)]) {
        [self.delegate chartViewDidSelectItemWithIndex:index];
    }
    [self addSubview:self.popView];
    [self addSubview:self.popLabel];
    self.popView.hidden = NO;
    self.popLabel.hidden = NO;
    CGPoint point = self.valuePoints[index].CGPointValue;
    if (point.y < 0) {
        point = CGPointMake(point.x, 0);
    }
    [self.popView setCenter:point];
    
    NSString *stepsStr = [NSString stringWithFormat:@"%@",self.itemValues[index]];
    
    self.popLabel.text = stepsStr;
    
    // @xaoxuu: 是不是靠近左边界
    BOOL isLeft = NO;
    CGFloat left = point.x - 0.5 * self.itemWidth + 0.5*(self.itemWidth - popViewWeight);
    if (left < margin) {
        isLeft = YES;
        left = self.valuePoints[index].CGPointValue.x;
    }
    // @xaoxuu: 是不是靠近右边界
    BOOL isRight = NO;
    CGFloat right = left + popViewWeight;
    if (right > margin + self.chartWidth) {
        isRight = YES;
        left = self.valuePoints[index].CGPointValue.x - popViewWeight;
    }
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.popLabel.textAlignment = NSTextAlignmentCenter;
        CGFloat y;
        if (point.y > self.frameHeight/2) {
            y = point.y - (15 + popViewHeight);
        } else {
            y = point.y + 15;
        }
        CGRect frame = CGRectMake(left, y, popViewWeight, popViewHeight);
        self.popLabel.frame = frame;
    } completion:nil];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, (point.y > self.frameHeight/2 ? popViewHeight : 0))];
    if (isLeft) {
        [path addLineToPoint:CGPointMake(0, (point.y > self.frameHeight/2 ? popViewHeight+5 : 0-5))];
        [path addLineToPoint:CGPointMake(5, (point.y > self.frameHeight/2 ? popViewHeight : 0))];
    } else if (isRight) {
        [path addLineToPoint:CGPointMake(popViewWeight-5, (point.y > self.frameHeight/2 ? popViewHeight : 0))];
        [path addLineToPoint:CGPointMake(popViewWeight, (point.y > self.frameHeight/2 ? popViewHeight+5 : 0-5))];
    } else {
        [path addLineToPoint:CGPointMake(0.5*popViewWeight-5, (point.y > self.frameHeight/2 ? popViewHeight : 0))];
        [path addLineToPoint:CGPointMake(0.5*popViewWeight, (point.y > self.frameHeight/2 ? popViewHeight+5 : 0-5))];
        [path addLineToPoint:CGPointMake(0.5*popViewWeight+5, (point.y > self.frameHeight/2 ? popViewHeight : 0))];
    }
    [path addLineToPoint:CGPointMake(popViewWeight, (point.y > self.frameHeight/2 ? popViewHeight : 0))];
    
    
    self.arrowLayer.path = path.CGPath;
    [path addLineToPoint:CGPointMake(popViewWeight, (point.y > self.frameHeight/2 ? 0 : popViewHeight))];
    [path addLineToPoint:CGPointMake(0, (point.y > self.frameHeight/2 ? 0 : popViewHeight))];
    [path closePath];
    self.borderLayer.path = path.CGPath;
    
}

- (NSUInteger)itemCount{
    if (!_itemCount) {
        if ([self.dataSource respondsToSelector:@selector(chartViewItemsCount)]) {
            _itemCount = [self.dataSource chartViewItemsCount];
        }
    }
    return _itemCount;
}

- (NSMutableArray<NSNumber *> *)itemValues{
    if (!_itemValues.count) {
        if ([self.dataSource respondsToSelector:@selector(chartViewValueForIndex:)]) {
            _itemValues = [NSMutableArray array];
            for (int i = 0; i < self.itemCount; i++) {
                NSNumber *value = [self.dataSource chartViewValueForIndex:i];
                [_itemValues addObject:value];
            }
        }
    }
    return _itemValues;
}

- (NSMutableArray<NSString *> *)itemTitles{
    if (!_itemTitles.count) {
        if ([self.dataSource respondsToSelector:@selector(chartViewTitleForIndex:)]) {
            _itemTitles = [NSMutableArray array];
            for (int i = 0; i < self.itemCount; i++) {
                [_itemTitles addObject:[self.dataSource chartViewTitleForIndex:i]];
            }
        }
    }
    return _itemTitles;
}


- (CGFloat)itemWidth{
    if (!_itemWidth) {
        _itemWidth = self.chartWidth / (self.itemCount-1);
    }
    return _itemWidth;
}



- (UIView *)popView{
    if (!_popView) {
        _popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*pointRadius, 2*pointRadius)];
        _popView.backgroundColor = self.accentColor;
        _popView.layer.cornerRadius = pointRadius;
        _popView.layer.borderColor = [UIColor whiteColor].CGColor;
        _popView.layer.borderWidth = 0.5*pointRadius;
    }
    return _popView;
}

- (UILabel *)popLabel{
    if (!_popLabel) {
        _popLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, popViewWeight, popViewHeight)];
        _popLabel.backgroundColor = [UIColor whiteColor];
        _popLabel.font = [UIFont systemFontOfSize:13];
        _popLabel.numberOfLines = 1;
        _popLabel.textAlignment = NSTextAlignmentCenter;
        _popLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _popLabel;
}



- (CAShapeLayer *)arrowLayer
{
    if (!_arrowLayer) {
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.strokeColor = [UIColor whiteColor].CGColor;
        _arrowLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.popLabel.layer addSublayer:_arrowLayer];
    }
    return _arrowLayer;
}

- (CAShapeLayer *)borderLayer
{
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.strokeColor = self.accentColor.CGColor;
        _borderLayer.lineWidth = 1;
        _borderLayer.lineJoin = kCALineCapRound;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        [self.popLabel.layer addSublayer:_borderLayer];
    }
    return _borderLayer;
}

@end
