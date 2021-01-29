//
//  FCChartView.h
//  ZSXFirstChartDemo
//
//  Created by 邹时新 on 2018/6/12.
//  Copyright © 2018年 zoushixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCChartCollectionViewCell.h"


typedef enum : NSUInteger {
    FCChartViewTypeSectionAndRowFixation,//行列固定
    FCChartViewTypeOnlySectionFixation,//行固定
    FCChartViewTypeOnlyRowFixation,//列固定
    FCChartViewTypeNoFixation,//无固定
} FCChartViewType;


typedef enum : NSUInteger {
    FCChartCollectionViewTypeMain,//非悬浮主区域
    FCChartCollectionViewTypeSuspendRow,//悬浮列区域
    FCChartCollectionViewTypeSuspendSection,//悬浮行区域
} FCChartCollectionViewType;


@class FCChartView;
@protocol FCChartViewDataSource <NSObject>

@required

- (NSInteger)chartView:(FCChartView *_Nullable)chartView numberOfItemsInSection:(NSInteger)section;

- (__kindof UICollectionViewCell *)collectionViewCell:(UICollectionViewCell *)collectionViewCell collectionViewType:(FCChartCollectionViewType)type cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (__kindof UICollectionViewCell *)collectionViewCell:(UICollectionViewCell *)collectionViewCell collectionViewType:(FCChartCollectionViewType)type cellForItemAtIndexPath:(NSIndexPath *)indexPath cellForView:(FCChartView*)chartView;
/**
 对应item尺寸大小
 */
- (CGSize)chartView:(FCChartView *)chartView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 总列数量 默认为1
 */
- (NSInteger)numberOfSectionsInChartView:(FCChartView *)chartView;

@optional

-(void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath cellForView:(FCChartView*)chartView;
/**
 悬浮锁定列数
 */
- (NSInteger)numberOfSuspendSectionsInChartView:(FCChartView *)chartView;


/**
 悬浮锁定行数

 @param chartView 当前对象
 @param section 第几列
 @return 行数
 */
- (NSInteger)chartView:(FCChartView *_Nullable)chartView numberOfSuspendItemsInSection:(NSInteger)section;


@end


@interface FCChartView : UIView
@property (nonatomic,strong)UICollectionView *mainCV;

- (instancetype)initWithFrame:(CGRect)frame type:(FCChartViewType)type dataSource:(id<FCChartViewDataSource>)dataSource suspendSection:(NSInteger)suspendSection;

- (void)registerClass:(nullable Class)cellClass;

@property (nonatomic,weak)id <FCChartViewDataSource> _Nullable dataSource;


@property (nonatomic,assign)NSInteger suspendSection;
/**
 行悬浮区域颜色 默认灰色
 */
@property (nonatomic,strong)UIColor * _Nullable suspendRowColor;

/**
 列悬浮区域颜色 默认灰色
 */
@property (nonatomic,strong)UIColor * _Nullable suspendSectionColor;

/**
 主区域颜色
 */
@property (nonatomic,strong)UIColor * _Nullable mainColor;


/**
 重新加载
 */
- (void)reload;



@end
