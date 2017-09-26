//
//  PageContainerView.h
//  PageCateViewSample
//
//  Created by Ossey on 28/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageCateButtonView.h"

NS_ASSUME_NONNULL_BEGIN

@class PageContainerView;

@protocol PageContainerViewDelegate <NSObject>

@required
- (PageCateButtonView *)pageCateButtonViewForContainerView;

- (PageCateButtonItem *)pageContainerView:(PageContainerView *)containerView buttonItemAtIndex:(NSInteger)index;
- (NSInteger)numberOfButtonItemsInPageContainerView;

@optional
- (UIView *)pageCateChannelViewForContainerView:(PageContainerView *)containerView forIndex:(NSInteger)index;
- (void)pageContainerView:(PageContainerView *)pageContentView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
- (PageCateButtonItem *)rightButtonItemForPageCateButtonView;

@end

@interface PageContainerView : UIView <PageCateButtonViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, strong) NSArray<UIViewController *> *childViewControllers;

@property (nonatomic, weak) id<PageContainerViewDelegate> delegate;
@property (nonatomic, assign) BOOL scrollEnabled;
/** 允许多手势同时存在, default is YES, 控制侧滑返回 */
@property (nonatomic, assign) BOOL shouldAllowRecognizeSimultaneously;

- (void)scrollToIndex:(NSInteger)toIndex;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END



