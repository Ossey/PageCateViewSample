//
//  PageCateButtonView.h
//  PageCateViewSample
//
//  Created by Ossey on 27/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PageCateButtonViewUnderLineStyle) {
    PageCateButtonViewUnderLineStyleNone,
    PageCateButtonViewUnderLineStyleDefault
};

typedef NS_ENUM(NSInteger, PageCateButtonViewSeparatorStyle) {
    PageCateButtonViewSeparatorStyleNone,
    PageCateButtonViewSeparatorStyleDefault
};

@class PageCateButtonView, PageCateButtonItem;


@protocol PageCateButtonViewDelegate <NSObject>

@optional
- (void)pageCateButtonView:(PageCateButtonView *)view didSelectedAtIndex:(NSInteger)index;
- (void)pageCateButtonView:(PageCateButtonView *)view didSelecteRightButtonItem:(PageCateButtonItem *)rightItem;

@end

@interface PageCateButtonView : UIView

@property (nonatomic, weak) id<PageCateButtonViewDelegate> delegate;
@property (nonatomic, strong) NSArray<PageCateButtonItem *> *buttonItems;
@property (nonatomic, strong) PageCateButtonItem *rightItem;
@property (nonatomic, assign) CGFloat buttonMargin;
@property (nonatomic, assign) UIColor *currentItemBackGroundColor;
@property (nonatomic, strong) UIColor *underLineBackgroundColor;
@property (nonatomic, assign) CGFloat underLineHeight;
@property (nonatomic, assign) CGFloat separatorHeight;
@property (nonatomic, strong) UIImage *underLineImage;
@property (nonatomic, strong) UIImage *separatorImage;
@property (nonatomic, strong) UIColor *separatorBackgroundColor;
@property (nonatomic, assign) BOOL automaticCenter;
@property (nonatomic, assign) PageCateButtonViewUnderLineStyle underLineStyle;
@property (nonatomic, assign) PageCateButtonViewSeparatorStyle separatorStyle;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL underLineCanScroll;
/** 当buttonItem总共未占满一屏幕时，是否自适应buttonItem的宽度，让其铺满屏幕 */
@property (nonatomic, assign) BOOL sizeToFltWhenScreenNotPaved;

/** 标题按钮缩放比例, 默认为0, 有效范围0.0~1.0 */
@property (nonatomic, assign) CGFloat itemTitleScale;

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(nullable id<PageCateButtonViewDelegate>)delegate
                  buttonItems:(NSArray<PageCateButtonItem *> *)buttonItems
                    rightItem:(PageCateButtonItem *)rightItem;
- (instancetype)initWithFrame:(CGRect)frame
                  buttonItems:(NSArray<PageCateButtonItem *> *)buttonItems
                    rightItem:(PageCateButtonItem *)rightItem;

- (void)setButtonItemTitle:(NSString *)title forState:(UIControlState)state index:(NSInteger)index;

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
