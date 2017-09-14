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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AXChartView *v1 = [[AXChartView alloc] initWithFrame:CGRectMake(16, 28, self.view.frame.size.width - 32, 200)];
    [self.view addSubview:v1];
    v1.dataSource = self;
    v1.delegate = self;
    v1.title = @"AXChartView";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)chartViewItemsCount{
    return 21;
}

- (NSNumber *)chartViewValueForIndex:(NSUInteger)index{
    return @(arc4random_uniform(2000));
}

- (NSString *)chartViewTitleForIndex:(NSUInteger)index{
    return @(index).stringValue;
}
- (NSInteger)chartViewShowTitleForIndexWithSteps{
    return 2;
}


@end
