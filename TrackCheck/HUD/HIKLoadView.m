//
//  HIKLoadView.m
//  VideoGo
//
//  Created by zhil.shi on 15/3/9.
//  Copyright (c) 2015年 HIKVison. All rights reserved.
//

#import "HIKLoadView.h"
#import "HIKLoadViewItem.h"
#import "HIKLoadViewItem+configPath.h"
static float SQUARE_FIT_LEN = 14.0;

@interface HIKLoadView ()

@property (nonatomic,strong) CALayer         *animationLayer;
@property (nonatomic,strong) HIKLoadViewItem *blueCircle;
@property (nonatomic,strong) HIKLoadViewItem *greenCircle;
@property (nonatomic,strong) HIKLoadViewItem *redCircle;
@property (nonatomic,strong) HIKLoadViewItem *yellowCircle;
@property (nonatomic,strong) UILabel         *percentLable;
@end

@implementation HIKLoadView
#pragma mark - init 初始化
- (instancetype)initWithHIKLoadViewStyle:(HIKLoadViewStyle)style
{
    self = [super init];
    if(!self)return nil;
    
    switch (style) {
        case HIKLoadViewStyleSqureClockWise:
        {
            [self setFrame:CGRectMake(0.0, 0.0, SQUARE_FIT_LEN, SQUARE_FIT_LEN)];
            [self p_setUp];
            [self p_setUpCircleLayersCenter];
        }
            break;
        case HIKLoadViewStyleSqureCornersClockWise:
        {
            [self setFrame:CGRectMake(0.0, 0.0, SQUARE_FIT_LEN, SQUARE_FIT_LEN)];
            [self p_setUp];
            [self p_setUpCorcleLayersSquareCorners];
        }
            break;
            
        default:
            break;
    }
    
    return self;
}

- (instancetype)initWithHIKLoadViewStyle:(HIKLoadViewStyle)style frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self)return nil;
    
    switch (style) {
        case HIKLoadViewStyleSqureClockWise:
        {
            [self p_setUp];
            [self p_setUpCircleLayersCenter];
        }
            break;
        case HIKLoadViewStyleSqureCornersClockWise:
        {
            [self p_setUp];
            [self p_setUpCorcleLayersSquareCorners];
        }
            break;
            
        default:
            break;
    }
    
    return self;
}

#pragma mark -setUp 私有方法相关设置
- (void)p_setUp
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self p_setUpCircleLayers];
    
}

/**
 *  初始化需要的layer
 */
- (void)p_setUpCircleLayers
{
    if(!self.animationLayer)
    {
        self.animationLayer = self.layer;
    }
    
    if(!self.yellowCircle)
    {
        UIImage* yellowImage = [UIImage imageNamed:@"logo_loading_4"];
        self.yellowCircle    = [HIKLoadViewItem initWithImage:yellowImage];
        [self.animationLayer addSublayer:self.yellowCircle.colorCirculeLayer];
    }
    
    if(!self.redCircle)
    {
        UIImage* redImage = [UIImage imageNamed:@"logo_loading_3"];
        self.redCircle    = [HIKLoadViewItem initWithImage:redImage];
        [self.animationLayer addSublayer:self.redCircle.colorCirculeLayer];
    }
    
    if(!self.greenCircle)
    {
        UIImage* greenImage = [UIImage imageNamed:@"logo_loading_2"];
        self.greenCircle    = [HIKLoadViewItem initWithImage:greenImage];
        [self.animationLayer addSublayer:self.greenCircle.colorCirculeLayer];
    }
    
    if(!self.blueCircle)
    {
        UIImage* blueImage = [UIImage imageNamed:@"logo_loading_1"];
        self.blueCircle    = [HIKLoadViewItem initWithImage:blueImage];
        [self.animationLayer addSublayer:self.blueCircle.colorCirculeLayer];
    }
    
}
/**
 *  初始化百分比显示lable
 */
- (void)p_initPercentLable
{
    if(self.percentLable)return;
    
    self.percentLable = [[UILabel alloc]init];
    [self.percentLable setBackgroundColor:[UIColor clearColor]];
    [self.percentLable setTextAlignment:NSTextAlignmentCenter];
    
}
/**
 *  移除layers傻姑娘的所有动画
 */
- (void)p_removeAllAniamations
{
    [self.blueCircle.colorCirculeLayer removeAllAnimations];
    [self.greenCircle.colorCirculeLayer removeAllAnimations];
    [self.redCircle.colorCirculeLayer removeAllAnimations];
    [self.yellowCircle.colorCirculeLayer removeAllAnimations];
}
/**
 *  设置正方形顺时针旋转动画
 */
- (void)p_setUpAnimations
{
    [self.blueCircle configKeyFrameAnimationForColorLayerWithStartLoadingStyle:HIKLoadViewStartFromLeftTop];
    [self.greenCircle configKeyFrameAnimationForColorLayerWithStartLoadingStyle:HIKLoadViewStartFromRightTop];
    [self.redCircle configKeyFrameAnimationForColorLayerWithStartLoadingStyle:HIKLoadViewStartFromLeftBottom];
    [self.yellowCircle configKeyFrameAnimationForColorLayerWithStartLoadingStyle:HIKLoadViewStartFromRightBottom];
}

- (void)p_setUpCircleLayersCenter
{
    CGPoint centerPoint = CGPointMake(SQUARE_FIT_LEN/2.0, SQUARE_FIT_LEN/2.0);
    [self.yellowCircle setPosition:centerPoint];
    [self.redCircle setPosition:centerPoint];
    [self.greenCircle setPosition:centerPoint];
    [self.blueCircle setPosition:centerPoint];
}

- (void)p_stayCircleLayersPresentationLayerPosition
{
    [self.yellowCircle stayOnPresentationLayerPosition];
    [self.redCircle stayOnPresentationLayerPosition];
    [self.greenCircle stayOnPresentationLayerPosition];
    [self.blueCircle stayOnPresentationLayerPosition];
    [self.greenCircle.colorCirculeLayer setOpacity:0];
    [self.redCircle.colorCirculeLayer setOpacity:0];
    [self.blueCircle.colorCirculeLayer setOpacity:0];
    [self.yellowCircle.colorCirculeLayer setOpacity:0];

}

/**
 *  设置起始位置为正方形四角
 */
- (void)p_setUpCorcleLayersSquareCorners
{
    CGPoint leftTop     = CGPointMake(0.0, 0.0);
    CGPoint rightTop    = CGPointMake(SQUARE_FIT_LEN, 0.0);
    CGPoint rightBottom = CGPointMake(SQUARE_FIT_LEN, SQUARE_FIT_LEN);
    CGPoint leftBottom  = CGPointMake(0.0, SQUARE_FIT_LEN);
    [self.blueCircle setPosition:leftTop];
    [self.greenCircle setPosition:rightTop];
    [self.yellowCircle setPosition:rightBottom];
    [self.redCircle setPosition:leftBottom];
}


#pragma mark -animations
- (void)updateReadytoClockwiseAnimationWithPercent:(float)percent
{
    if(percent < 0.0 || percent > 1.0)
    {
        return;
    }
    
    percent = ((int)(percent * 10))/10.0;

    
    CGPoint center            = CGPointMake(CGRectGetMidX(self.frame) -CGRectGetMinX(self.frame), CGRectGetMidY(self.frame)-CGRectGetMinY(self.frame));
    CGPoint blueTargetPoint   = CGPointMake(center.x  * (1-percent), center.y * (1-percent));
    CGPoint greenTargetPoint  = CGPointMake(center.x * (1+percent), center.y * (1-percent));
    CGPoint yellowTargetPoint = CGPointMake(center.x * (1+percent), center.y * (1+percent));
    CGPoint redTargetPoint    = CGPointMake(center.x * (1-percent), center.y * (1+percent));
    
    [self.blueCircle setPosition:blueTargetPoint];//blue最上层，透明度不设置
    [self.greenCircle setPosition:greenTargetPoint];
    [self.redCircle setPosition:redTargetPoint];
    [self.yellowCircle setPosition:yellowTargetPoint];
    [self.blueCircle.colorCirculeLayer setOpacity:1.0];
    [self.redCircle.colorCirculeLayer setOpacity:percent];
    [self.greenCircle.colorCirculeLayer setOpacity:percent];
    [self.yellowCircle.colorCirculeLayer setOpacity:percent];

    
}

- (void)startSquareClcokwiseAnimation
{
    [self p_removeAllAniamations];
    [self p_setUpCircleLayersCenter];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self p_setUpAnimations];
    });

}

- (void)stopSquareClockwiseAnimation
{
    [self p_stayCircleLayersPresentationLayerPosition];
    [self p_removeAllAniamations];
}

@end
