//
//  PageContainerView.h
//  PageCateViewSample
//
//  Created by Ossey on 28/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageCateButtonView.h"

@class PageContainerView;

@protocol PageContainerViewDelegate <NSObject>

@required
- (PageCateButtonView *)pageCateButtonViewForContainerView;

@optional
- (UIView *)pageCateChannelViewForContainerView:(PageContainerView *)containerView forIndex:(NSInteger)index;
- (void)pageContainerView:(PageContainerView *)pageContentView didScrollWithProgress:(CGFloat)progress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)pageCateButtonView:(PageCateButtonView *)view didSelectedAtIndex:(NSInteger)index;

@end

@interface PageContainerView : UIView

- (instancetype)initWithFrame:(CGRect)frame parentViewController:(UIViewController *)parentViewController childViewControllers:(NSArray *)childViewControllers;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<PageContainerViewDelegate>)delegate;

@property (nonatomic, weak) id<PageContainerViewDelegate> delegate;
@property (nonatomic, assign) BOOL scrollEnabled;

- (void)scrollToIndex:(NSInteger)toIndex;

@end
