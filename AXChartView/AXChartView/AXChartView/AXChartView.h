//
//  AXChartView.h
//  AXChartView
//
//  Created by xaoxuu on 14/09/2017.
//  Copyright © 2017 xaoxuu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AXChartViewDataSource <NSObject>

/**
 总列数
 
 @return 总列数
 */
- (NSUInteger)chartViewItemsCount;


/**
 第index列的值
 
 @param index 列索引
 @return 第index列的值
 */
- (NSNumber *)chartViewValueForIndex:(NSUInteger)index;


/**
 第index列的标题
 
 @param index 列索引
 @return 第index列的标题
 */
- (NSString *)chartViewTitleForIndex:(NSUInteger)index;

@optional


/**
 当item过多时无法全部显示出来，需要决定每几个显示一个

 @return 当item过多时无法全部显示出来，需要决定每几个显示一个
 */
- (NSInteger)chartViewShowTitleForIndexWithSteps;

/**
 最大值（如果实际值有超过此值的，按照实际的最大值计算）

 @return 最大值（如果实际值有超过此值的，按照实际的最大值计算）
 */
- (NSNumber *)chartViewMaxValue;


@end

@protocol AXChartViewDelegate <NSObject>

@optional
/**
 选中了某一列
 
 @param index 列索引
 */
- (void)chartViewDidSelectItemWithIndex:(NSUInteger)index;


/**
 将设置渐变色图层
 
 @param gradientLayer 渐变色图层
 */
- (void)chartViewWillSetGradientLayer:(CAGradientLayer *)gradientLayer;

@end


@interface AXChartView : UIView

/**
 数据源
 */
@property (weak, nonatomic) id<AXChartViewDataSource> dataSource;

/**
 代理
 */
@property (weak, nonatomic) id<AXChartViewDelegate> delegate;

/**
 线宽
 */
@property (assign, nonatomic) CGFloat lineWidth;

/**
 强调色
 */
@property (strong, nonatomic) UIColor *accentColor;

/**
 线条颜色
 */
@property (strong, nonatomic) UIColor *lineColor;

/**
 图表标题
 */
@property (copy, nonatomic) NSString *title;


/**
 reload chart view with data source
 */
- (void)reloadData;




@end
