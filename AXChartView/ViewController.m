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
    v1.title = @"AXChartView";
    v1.lineWidth = 2;
    v1.smoothFactor = 0.5;
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


- (NSUInteger)chartViewItemsCount{
    return 7;
}

- (NSNumber *)chartViewValueForIndex:(NSUInteger)index{
    return @(arc4random_uniform(20000));
}

- (NSString *)chartViewTitleForIndex:(NSUInteger)index{
    return @(index+1).stringValue;
}

//- (NSInteger)chartViewShowTitleForIndexWithSteps{
//    return 2; // 每两天显示一个
//}

//- (NSString *)chartViewSummaryText:(UILabel *)label{
//    return @"haha";
//}

- (void)chartViewWillSetGradientLayer:(CAGradientLayer *)gradientLayer{
    [gradientLayer setColors:@[(id)[UIColor colorWithRed:248/255.0 green:207/255.0 blue:54/255.0 alpha:1.00].CGColor, (id)[UIColor colorWithRed:253/255.0 green:166/255.0 blue:65/255.0 alpha:1.00].CGColor]];
    [gradientLayer setStartPoint:CGPointMake(0, 0)];
    [gradientLayer setEndPoint:CGPointMake(1, 1)];
}

@end
