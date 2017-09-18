# AXChartView
简单美观的统计图表，只有一个类！



效果图示：

![](https://user-images.githubusercontent.com/16400144/30470718-78958ab6-9a28-11e7-8db5-a6dba3c45740.png)



### 简单使用

创建：

```objective-c
AXChartView *v1 = [[AXChartView alloc] initWithFrame:CGRectMake(16, 28, self.view.frame.size.width - 32, 200)];
[self.view addSubview:v1];
self.v1 = v1;
v1.dataSource = self;
v1.delegate = self;
// 标题
v1.title = @"AXChartView";
// 线条粗细，默认为1
v1.lineWidth = 2;
// 平滑指数，默认为0，折线图
v1.smoothFactor = 1;
// 强调色，默认为灰色
v1.accentColor = [UIColor orangeColor];
```

必要参数：

```objective-c
/**
 总列数

 @return 总列数
 */
- (NSUInteger)chartViewItemsCount{
    return 7;
}

/**
 第index列的值
 
 @param index 列索引
 @return 第index列的值
 */
- (NSNumber *)chartViewValueForIndex:(NSUInteger)index{
    return @(arc4random_uniform(20000));
}

/**
 第index列的标题
 
 @param index 列索引
 @return 第index列的标题
 */
- (NSString *)chartViewTitleForIndex:(NSUInteger)index{
    return @(index+1).stringValue;
}
```



自定义：

```objective-c
// 每多少天显示一个列标题(当列数很多的时候用)
- (NSInteger)chartViewShowTitleForIndexWithSteps{
    return 2; 
}

// 右上角的摘要文字
- (NSString *)chartViewSummaryText:(UILabel *)label{
    return @"haha";
}

// 渐变的背景色
- (void)chartViewWillSetGradientLayer:(CAGradientLayer *)gradientLayer{
    [gradientLayer setColors:@[(id)[UIColor colorWithRed:248/255.0 green:207/255.0 blue:54/255.0 alpha:1.00].CGColor, (id)[UIColor colorWithRed:253/255.0 green:166/255.0 blue:65/255.0 alpha:1.00].CGColor]];
    [gradientLayer setStartPoint:CGPointMake(0, 0)];
    [gradientLayer setEndPoint:CGPointMake(1, 1)];
}
```

