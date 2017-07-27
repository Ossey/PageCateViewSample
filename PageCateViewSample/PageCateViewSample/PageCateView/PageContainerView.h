//
//  PageContainerView.h
//  PageCateViewSample
//
//  Created by Ossey on 28/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageContainerView;

@protocol PageContainerViewDelegate <NSObject>

@optional
- (void)pageContainerView:(PageContainerView *)pageContentView progress:(CGFloat)progress fromIndex:(NSInteger)fromItem toIndex:(NSInteger)toIndex;

@end

@interface PageContainerView : UIView

/**
 *  对象方法创建 SGPageContentView
 *
 *  @param frame     frame
 *  @param parentVC     当前控制器
 *  @param childVCs     子控制器个数
 */
- (instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC childVCs:(NSArray *)childVCs;


@property (nonatomic, weak) id<PageContainerViewDelegate> delegate;
@property (nonatomic, assign) BOOL isScrollEnabled;

/** 给外界提供的方法，获取 SGPageTitleView 选中按钮的下标, 必须实现 */
- (void)setPageCententViewCurrentIndex:(NSInteger)currentIndex;

@end
