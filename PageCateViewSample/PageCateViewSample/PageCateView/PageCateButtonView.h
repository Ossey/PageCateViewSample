//
//  PageCateButtonView.h
//  PageCateViewSample
//
//  Created by Ossey on 27/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PageCateButtonViewIndicatoStyle) {
    PageCateButtonViewIndicatoStyleNone,
    PageCateButtonViewIndicatoStyleDefault
};

typedef NS_ENUM(NSInteger, PageCateButtonViewSeparatorStyle) {
    PageCateButtonViewSeparatorStyleNone,
    PageCateButtonViewSeparatorStyleDefault
};

@class PageCateButtonView, PageCateButtonItem;


@protocol PageCateButtonViewDelegate <NSObject>

- (NSArray<PageCateButtonItem *> *)buttonItemsForPageCateButtonView;
@optional
- (void)pageCateButtonView:(PageCateButtonView *)view didSelectedAtIndex:(NSInteger)index;
- (void)pageCateButtonView:(PageCateButtonView *)view didSelecteRightButtonItem:(PageCateButtonItem *)rightItem;
- (PageCateButtonItem *)rightButtonItemForPageCateButtonView;

@end

@interface PageCateButtonView : UIView

@property (nonatomic, weak) id<PageCateButtonViewDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<PageCateButtonItem *> *buttonItems;
@property (nonatomic, strong, readonly) PageCateButtonItem *rightItem;
@property (nonatomic, assign) CGFloat itemHorizontalSpacing;
@property (nonatomic, assign) UIColor *currentItemBackGroundColor;
@property (nonatomic, strong) UIColor *indicatoBackgroundColor;
@property (nonatomic, assign) CGFloat indicatoHeight;
@property (nonatomic, assign) CGFloat separatorHeight;
@property (nonatomic, strong) UIImage *indicatoImage;
@property (nonatomic, strong) UIImage *separatorImage;
@property (nonatomic, strong) UIColor *separatorBackgroundColor;
@property (nonatomic, assign) BOOL automaticCenter;
@property (nonatomic, assign) PageCateButtonViewIndicatoStyle indicatoStyle;
@property (nonatomic, assign) PageCateButtonViewSeparatorStyle separatorStyle;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL bounces;
/** 控制指示器是否跟随滚动的动画 */
@property (nonatomic, assign) BOOL indicatoScrollAnimated;
/** 当buttonItem总共未占满一屏幕时，是否自适应buttonItem的宽度，让其铺满屏幕 */
@property (nonatomic, assign) BOOL sizeToFltWhenScreenNotPaved;

/** 标题按钮缩放比例, 默认为0, 有效范围0.0~1.0 */
@property (nonatomic, assign) CGFloat itemScale;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setButtonItemTitle:(NSString *)title forState:(UIControlState)state index:(NSInteger)index;
- (void)setButtonItemImage:(UIImage *)image forState:(UIControlState)state index:(NSInteger)index;

- (void)scrollButtonFormIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end

@interface PageCateButtonItem : NSObject

@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, strong, readonly) UIButton *button;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, copy) void (^buttonItemClickBlock)(PageCateButtonItem *item);
- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state;
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
