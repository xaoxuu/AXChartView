//
//  ViewController.m
//  AXChartView
//
//  Created by xaoxuu on 14/09/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import "ViewController.h"
#import "AXChartView.h"

@interface ViewController () <AXChartViewDataSource, AXChartViewDelegate>

@property (strong, nonatomic) AXChartView *v1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.v1 reloadData];
}



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

// 每多少天显示一个列标题(当列数很多的时候用)
//- (NSInteger)chartViewShowTitleForIndexWithSteps{
//    return 2;
//}

// 右上角的摘要文字
//- (NSString *)chartViewSummaryText:(UILabel *)label{
//    return @"haha";
//}

// 渐变的背景色
- (void)chartViewWillSetGradientLayer:(CAGradientLayer *)gradientLayer{
    [gradientLayer setColors:@[(id)[UIColor colorWithRed:248/255.0 green:207/255.0 blue:54/255.0 alpha:1.00].CGColor, (id)[UIColor colorWithRed:253/255.0 green:166/255.0 blue:65/255.0 alpha:1.00].CGColor]];
    [gradientLayer setStartPoint:CGPointMake(0, 0)];
    [gradientLayer setEndPoint:CGPointMake(1, 1)];
}

@end
