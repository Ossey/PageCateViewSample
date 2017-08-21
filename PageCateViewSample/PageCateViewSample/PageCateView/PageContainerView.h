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
- (NSArray<PageCateButtonItem *> *)buttonItemsForPageCateButtonView;

@optional
- (UIView *)pageCateChannelViewForContainerView:(PageContainerView *)containerView forIndex:(NSInteger)index;
- (void)pageContainerView:(PageContainerView *)pageContentView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
- (PageCateButtonItem *)rightButtonItemForPageCateButtonView;

@end

@interface PageContainerView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, strong) NSArray<UIViewController *> *childViewControllers;

@property (nonatomic, weak) id<PageContainerViewDelegate> delegate;
@property (nonatomic, assign) BOOL scrollEnabled;

- (void)scrollToIndex:(NSInteger)toIndex;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END


