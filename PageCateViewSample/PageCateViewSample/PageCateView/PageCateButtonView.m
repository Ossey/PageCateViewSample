//
//  PageCateButtonView.m
//  PageCateViewSample
//
//  Created by Ossey on 27/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "PageCateButtonView.h"


@interface PageCateButton : UIButton

@property (nonatomic) CGFloat imageTitleSpace;

@end

@interface CateButtonContentView : UIView

@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat buttonMargin;
@property (nonatomic, assign) BOOL sizeToFltWhenScreenNotPaved;
@property (nonatomic, strong) NSArray<PageCateButtonItem *> *buttonItems;
@property (nonatomic, assign) CGFloat sizeToFltWidth;
/** 根据所有button 和 间距 计算到的总宽度 */
@property (nonatomic, assign) CGFloat scrollViewContentWidth;

@end


@interface NSString (DrawingAdditions)

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont*)font;

@end

@interface DefaultUnderLineView : UIImageView

@end

@interface PageCateButtonView ()

@property (nonatomic, strong) UIScrollView *cateTitleView;
@property (nonatomic, strong) CateButtonContentView *cateTitleContentView;
@property (nonatomic, strong) UIImageView *separatorView;
@property (nonatomic, strong) DefaultUnderLineView *underLineView;
@property (nonatomic, weak) PageCateButtonItem *previousSelectedBtnItem;
@property (nonatomic, assign) BOOL fristAppearUnderLine;

@end

@implementation PageCateButtonView
{
    /// scrollView右侧约束
    NSLayoutConstraint *_cateTitleViewRightConstraint;
}

@synthesize
underLineImage = _underLineImage,
underLineBackgroundColor = _underLineBackgroundColor,
selectedIndex = _selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame buttonItems:(NSArray<PageCateButtonItem *> *)buttonItems rightItem:(PageCateButtonItem *)rightItem {
    
    return [self initWithFrame:frame delegate:nil buttonItems:buttonItems rightItem:rightItem];
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<PageCateButtonViewDelegate>)delegate buttonItems:(NSArray<PageCateButtonItem *> *)buttonItems rightItem:(PageCateButtonItem *)rightItem {
    
    if (self = [self initWithFrame:frame]) {
        
        _delegate = delegate;
        _rightItem = rightItem;
        _buttonItems = buttonItems;
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self __setup];
    }
    return self;
}

- (void)__setup {
    
    _buttonMargin = 0.0;
    _underLineHeight = 1.0;
    _separatorHeight = 1.0;
    _automaticCenter = YES;
    _underLineBackgroundColor = [UIColor redColor];
    _separatorBackgroundColor = [UIColor blueColor];
    _fristAppearUnderLine = YES;
    _sizeToFltWhenScreenNotPaved = YES;
    _underLineStyle = PageCateButtonViewUnderLineStyleDefault;
    _separatorStyle = PageCateButtonViewSeparatorStyleDefault;
    [self addSubview:self.cateTitleView];
    [self.cateTitleView addSubview:self.cateTitleContentView];
}

- (void)setDelegate:(id<PageCateButtonViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadSubviews];
}

- (void)setButtonItems:(NSArray<PageCateButtonItem *> *)buttonItems {
    _buttonItems = buttonItems;
    
    [self reloadSubviews];
}

- (void)setSizeToFltWhenScreenNotPaved:(BOOL)sizeToFltWhenScreenNotPaved {
    if (_sizeToFltWhenScreenNotPaved == sizeToFltWhenScreenNotPaved) {
        return;
    }
    _sizeToFltWhenScreenNotPaved = sizeToFltWhenScreenNotPaved;
    self.cateTitleContentView.sizeToFltWhenScreenNotPaved = sizeToFltWhenScreenNotPaved;
    [self reloadSubviews];
}

- (void)setRightItem:(PageCateButtonItem *)rightItem {
    if (_rightItem.button == rightItem.button) {
        return;
    }
    _rightItem = rightItem;
    
    if (rightItem) {
        
        self.rightItem.index = self.buttonItems.count + 1;
        __weak typeof(self) weakSelf = self;
        self.rightItem.buttonItemClickBlock = ^(PageCateButtonItem *item) {
            [weakSelf rightButtonItemClick:item];
        };
        [self addSubview:self.rightItem.button];
    }
    
    [self reloadSubviews];
}


- (void)_removeAllConstraints {
    [self.cateTitleContentView removeConstraints:self.cateTitleContentView.constraints];
    [self.cateTitleView removeConstraints:self.cateTitleContentView.constraints];
    [self removeConstraints:self.cateTitleView.constraints];
    [self removeConstraints:self.rightItem.button.constraints];
    [self removeConstraints:self.separatorView.constraints];
    [self removeConstraint:_cateTitleViewRightConstraint];
    [self removeConstraints:self.cateTitleContentView.constraints];
}



- (void)reloadSubviews {
    
    [self setupConstraints];
    
    self.cateTitleContentView.scrollViewContentWidth = 0;
    for (NSInteger i = 0; i < self.buttonItems.count; ++i) {
        PageCateButtonItem *buttonItem = self.buttonItems[i];
        self.cateTitleContentView.scrollViewContentWidth += buttonItem.contentWidth;
    }
    
    self.cateTitleContentView.scrollViewContentWidth = _buttonMargin * (self.buttonItems.count + 1) + self.cateTitleContentView.scrollViewContentWidth;
    self.cateTitleContentView.scrollViewContentWidth = ceil(self.cateTitleContentView.scrollViewContentWidth);
    if (![self isCanScroll] && self.sizeToFltWhenScreenNotPaved) {
        self.cateTitleContentView.sizeToFltWidth = (self.cateTitleView.frame.size.width - (self.buttonItems.count - 1)*_buttonMargin) / self.buttonItems.count;
    } else {
        self.cateTitleContentView.sizeToFltWidth = 0;
    }
    
    self.cateTitleContentView.buttonItems = self.buttonItems;
    
    
    [self setUnderLineStyle:_underLineStyle];
    [self setSeparatorStyle:_separatorStyle];
    [self setSelectedIndex:self.selectedIndex];
    
}


- (void)setUnderLineStyle:(PageCateButtonViewUnderLineStyle)underLineStyle {
    _underLineStyle = underLineStyle;
    
    if (underLineStyle == PageCateButtonViewUnderLineStyleNone) {
        NSIndexSet *indexSet = [self.cateTitleView.subviews indexesOfObjectsPassingTest:^BOOL(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj isKindOfClass:[DefaultUnderLineView class]];
        }];
        NSArray *resultArray = [self.cateTitleView.subviews objectsAtIndexes:indexSet];
        for (DefaultUnderLineView *view in resultArray) {
            [view removeFromSuperview];
        }
        resultArray = nil;
        _underLineView = nil;
        return;
    }
    
    // 获取当前选中的buttonItem
    PageCateButtonItem *selectedItem = [self getCurrentSelectedButtonitem];
    if (!selectedItem) {
        return;
    }
    [self addSubview:self.underLineView];
    
    [self bringSubviewToFront:self.underLineView];
    self.underLineView.backgroundColor = self.underLineBackgroundColor;
    
    if (underLineStyle == PageCateButtonViewUnderLineStyleDefault) {
        [self updateUpderLinePointForButtonItem:selectedItem];
    }
    
}

- (void)setSeparatorStyle:(PageCateButtonViewSeparatorStyle)separatorStyle {
    _separatorStyle = separatorStyle;
    
    if (separatorStyle == PageCateButtonViewUnderLineStyleNone) {
        [_separatorView removeFromSuperview];
        _separatorView = nil;
    }
    else if (PageCateButtonViewUnderLineStyleDefault) {
        [self addSubview:self.separatorView];
        [self insertSubview:_separatorView belowSubview:_underLineView];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self selecteButtonItemWithIndex:selectedIndex];
}

- (void)selecteButtonItemWithIndex:(NSInteger)index {
    
    if (index > self.buttonItems.count - 1 || index < 0) {
        return;
    }
    PageCateButtonItem *buttonItem = self.buttonItems[index];
    [self buttonItemClick:buttonItem];
}

- (void)setButtonItemTitle:(NSString *)title forState:(UIControlState)state index:(NSInteger)index {
    if (index < self.buttonItems.count) {
        PageCateButtonItem *buttonItem = self.buttonItems[index];
        [buttonItem setTitle:title forState:state];
        [self setUnderLineStyle:self.underLineStyle];
    }
}

- (NSInteger)selectedIndex {
    
    return  _selectedIndex == 0 || _selectedIndex > self.buttonItems.count ? self.previousSelectedBtnItem.index : _selectedIndex;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)buttonItemClick:(PageCateButtonItem *)buttonItem {
    
    [self selectedButtonItemChange:buttonItem];
    [self setupCenterForButtonItem:buttonItem];
    [self updateUpderLinePointForButtonItem:buttonItem];
    [self _didSelectedButtonItem:buttonItem];
}

- (void)rightButtonItemClick:(PageCateButtonItem *)buttonItem {
    buttonItem.selected = !buttonItem.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageCateButtonView:didSelecteRightButtonItem:)]) {
        [self.delegate pageCateButtonView:self didSelecteRightButtonItem:buttonItem];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private delegate
////////////////////////////////////////////////////////////////////////

- (void)_didSelectedButtonItem:(PageCateButtonItem *)buttonItem {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageCateButtonView:didSelectedAtIndex:)]) {
        [self.delegate pageCateButtonView:self didSelectedAtIndex:buttonItem.index];
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)selectedButtonItemChange:(PageCateButtonItem *)buttonItem {
    
    if (!self.previousSelectedBtnItem) {
        buttonItem.selected = YES;
        self.previousSelectedBtnItem = buttonItem;
    }
    else if (buttonItem && self.previousSelectedBtnItem == buttonItem) {
        buttonItem.selected = YES;
    }
    else if (self.previousSelectedBtnItem && self.previousSelectedBtnItem != buttonItem) {
        self.previousSelectedBtnItem.selected = NO;
        buttonItem.selected  = YES;
        self.previousSelectedBtnItem = buttonItem;
    }
    
    if (self.itemTitleScale > 0) {
        for (NSInteger i = 0; i < self.buttonItems.count; ++i) {
            PageCateButtonItem *item = self.buttonItems[i];
            item.button.transform = CGAffineTransformMakeScale(1, 1);
        }
        buttonItem.button.transform = CGAffineTransformMakeScale(1 + self.itemTitleScale, 1 + self.itemTitleScale);
    }
}

- (void)setupCenterForButtonItem:(PageCateButtonItem *)buttonItem {
    
    if (!self.automaticCenter) {
        return;
    }
    
    if (self.cateTitleContentView.scrollViewContentWidth <= self.frame.size.width) {
        return;
    }
    
    // 本质：移动标题滚动视图的偏移量
    // 计算当选择的标题按钮的中心点x在屏幕屏幕中心点时，标题滚动视图的x轴的偏移量
    CGFloat offsetX = buttonItem.button.center.x - CGRectGetWidth(self.cateTitleView.frame) * 0.5;
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    CGFloat maxOffsetX = self.cateTitleView.contentSize.width - CGRectGetWidth(self.cateTitleView.frame);
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    [self.cateTitleView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)updateUpderLinePointForButtonItem:(PageCateButtonItem *)buttonItem {
    [self layoutIfNeeded];
    void (^animationBlock)() = ^{
        CGRect underLineFrame = self.underLineView.frame;
        if (self.sizeToFltWhenScreenNotPaved) {
            underLineFrame.size.width = self.cateTitleContentView.sizeToFltWidth ?: buttonItem.contentWidth;
        } else {
            underLineFrame.size.width = buttonItem.contentWidth;
        }
        underLineFrame.size.height = _underLineHeight;
        underLineFrame.origin.y = self.frame.size.height - _underLineHeight;
        self.underLineView.frame = underLineFrame;
        CGPoint center = self.underLineView.center;
        center.x = buttonItem.button.center.x;
        self.underLineView.center = center;
    };
    
    if (_fristAppearUnderLine) {
        animationBlock();
    } else {
        [UIView animateWithDuration:0.15 animations:animationBlock completion:^(BOOL finished) {
            _fristAppearUnderLine = NO;
        }];
    }
    
}


- (void)scrollButtonFormIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    
    PageCateButtonItem *fromItem = self.buttonItems[fromIndex];
    PageCateButtonItem *toItem = self.buttonItems[toIndex];
    _selectedIndex = toIndex;
    [self setupCenterForButtonItem:toItem];
    
    if (![self isCanScroll]) {
        if (self.underLineCanScroll) {
            // cateTitleView 不可以滚动，underLineView 可以滚动
            [self underLineViewnNotFollowCateTitleViewViewlWithProgress:progress fromButtonItem:fromItem toButtonItem:toItem];
        } else {
            // cateTitleView 不可以滚动，underLineView 也不可滚动
            [self underLineViewnNotFollowCateTitleViewViewlWithProgress1:progress fromButtonItem:fromItem toButtonItem:toItem];
        }
    } else {
        if (self.underLineCanScroll) {
            // cateTitleView 可以滚动，underLineView 随着滚动
            [self underLineViewFollowCateTitleViewViewlWithProgress:progress fromButtonItem:fromItem toButtonItem:toItem];
        } else {
            // cateTitleView 可以滚动，但是underLineView 不随着滚动
            [self underLineViewnNotFollowCateTitleViewViewlWithProgress1:progress fromButtonItem:fromItem toButtonItem:toItem];
        }
    }
    
    
    if (self.itemTitleScale) {
        // 左边缩放
        fromItem.button.transform = CGAffineTransformMakeScale((1 - progress) * self.itemTitleScale + 1, (1 - progress) * self.itemTitleScale + 1);
        // 右边缩放
        toItem.button.transform = CGAffineTransformMakeScale(progress * self.itemTitleScale + 1, progress * self.itemTitleScale + 1);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - underLineView 滚动
////////////////////////////////////////////////////////////////////////

// cateTitleView 不可以滚动，underLineView 可以滚动
- (void)underLineViewnNotFollowCateTitleViewViewlWithProgress:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem {
    // 改变按钮的状态
    if (progress >= 0.8) {
        /// 此处取 >= 0.8 而不是 1.0 为的是防止用户滚动过快而按钮的选中状态并没有改变
        [self selectedButtonItemChange:toItem];
    }
    
    if (self.underLineStyle == PageCateButtonViewUnderLineStyleDefault) {
        
        CGFloat moveTotalX = toItem.button.frame.origin.x - fromItem.button.frame.origin.x;
        CGFloat moveX = moveTotalX * progress;
        CGPoint center = self.underLineView.center;
        center.x = fromItem.button.center.x + moveX;
        self.underLineView.center = center;
    }
}

/// under line view 不跟随 cateTitleView滚动而滚动
- (void)underLineViewnNotFollowCateTitleViewViewlWithProgress1:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem {
    if (progress >= 0.5) {
        [self updateUpderLinePointForButtonItem:toItem];
        [self selectedButtonItemChange:toItem];
    } else {
        [self updateUpderLinePointForButtonItem:fromItem];
        [self selectedButtonItemChange:fromItem];
    }
}

// cateTitleView 可以滚动，underLineView 随着滚动
- (void)underLineViewFollowCateTitleViewViewlWithProgress:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem {
    /// 改变按钮的选择状态
    if (progress >= 0.8) {
        [self selectedButtonItemChange:toItem];
    }
    
    /// 计算 toItem／fromItem 之间的距离
    CGFloat totalOffsetX = toItem.button.frame.origin.x - fromItem.button.frame.origin.x;
    /// 计算 toItem／fromItem 宽度的差值
    CGFloat totalDistance = CGRectGetMaxX(toItem.button.frame) - CGRectGetMaxX(fromItem.button.frame);
    /// 计算 underLineView 滚动时 X 的偏移量
    CGFloat offsetX;
    /// 计算 underLineView 滚动时宽度的偏移量
    offsetX = totalOffsetX * progress;
    CGFloat distance = progress * (totalDistance - totalOffsetX);
    /// 计算 underLineView 新的 frame
    CGRect underLineFrame = self.underLineView.frame;
    underLineFrame.origin.x = fromItem.button.frame.origin.x + offsetX;
    underLineFrame.size.width = fromItem.button.frame.size.width + distance;
    self.underLineView.frame = underLineFrame;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)setUnderLineHeight:(CGFloat)underLineHeight {
    _underLineHeight = underLineHeight;
    
    CGRect frame = self.underLineView.frame;
    frame.size.height = underLineHeight;
    frame.origin.y = self.frame.size.height - underLineHeight;
    self.underLineView.frame = frame;
    
}

- (void)setBounces:(BOOL)bounces {
    self.cateTitleView.bounces = bounces;
}

- (BOOL)bounces {
    return self.cateTitleView.bounces;
}

- (void)setUnderLineImage:(UIImage *)underLineImage {
    _underLineImage = underLineImage;
    
    if (_underLineImage) {
        _underLineBackgroundColor = [UIColor clearColor];
        self.underLineView.backgroundColor = [UIColor clearColor];
        self.underLineView.image = underLineImage;
    }
}

- (UIColor *)underLineBackgroundColor {
    
    return _underLineBackgroundColor ?: [UIColor clearColor];
    
}

- (void)setUnderLineBackgroundColor:(UIColor *)underLineBackgroundColor {
    _underLineBackgroundColor = underLineBackgroundColor;
    if (underLineBackgroundColor) {
        self.underLineView.image = [UIImage new];
        _underLineImage = [UIImage new];
        self.underLineView.backgroundColor = underLineBackgroundColor;
    }
}

- (void)setSeparatorBackgroundColor:(UIColor *)separatorBackgroundColor {
    _separatorBackgroundColor = separatorBackgroundColor;
    if (separatorBackgroundColor) {
        self.separatorView.image = [UIImage new];
        _separatorImage = [UIImage new];
        self.separatorView.backgroundColor = separatorBackgroundColor;
    }
}

- (void)setSeparatorHeight:(CGFloat)separatorHeight {
    _separatorHeight = separatorHeight;
    
    [self setupConstraints];
}

- (PageCateButtonItem *)getButtonItemByButton:(UIButton *)button {
    NSUInteger foundIdxInItems = [self.buttonItems indexOfObjectPassingTest:^BOOL(PageCateButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = obj.button == button;
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (foundIdxInItems != NSNotFound) {
        return [self.buttonItems objectAtIndex:foundIdxInItems];
    }
    return nil;
}

- (PageCateButtonItem *)getCurrentSelectedButtonitem {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"] ;
    NSArray *selectedItems = [self.buttonItems filteredArrayUsingPredicate:predicate];
    return selectedItems.firstObject;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

- (void)setupConstraints {

    [self _removeAllConstraints];
    
    
    NSMutableArray<NSString *> *subviewKeyArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *subviewDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cateTitleView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cateTitleView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    if (!self.rightItem.button) {
        _cateTitleViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.cateTitleView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0];
        
    } else {
        
        _cateTitleViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.cateTitleView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.rightItem.button
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0.0];
        
        // 消除约束的警告：把其中一个关于superview的约束等级修改为High，就可以了；既消除了警告，也不影响视图的现实
        // rightButton
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.rightItem.contentWidth];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:0.0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0.0];
        [self addConstraint:top];
        [self addConstraint:bottom];
        right.priority = 999;
        [self addConstraint:right];
        [self addConstraint:width];
        
        
    }
    
    [self addConstraint:_cateTitleViewRightConstraint];
    
    [subviewKeyArray addObject:@"cateTitleContentView"];
    subviewDict[subviewKeyArray.lastObject] = self.cateTitleContentView;
    
    NSLayoutConstraint *cateTitleViewBottom = nil;
    if ([self canDisplaySeparatorView]) {
        [subviewKeyArray addObject:@"separatorView"];
        subviewDict[subviewKeyArray.lastObject] = self.separatorView;
        // 注意: @"|-[separatorView]-|"和@"|[separatorView]|"是不同的，@"|-[separatorView]-|"会依赖leftMargin和rightMargin，默认为8的间距，而@"|[separatorView]|"无间距
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[separatorView]|"
                                                                     options:kNilOptions metrics:nil
                                                                       views:subviewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cateTitleContentView][separatorView(separatorHeight@999)]|"
                                                                     options:kNilOptions
                                                                     metrics:@{@"separatorHeight": @(_separatorHeight)}
                                                                       views:subviewDict]];
        
        // scrollView bottom
        cateTitleViewBottom = [NSLayoutConstraint constraintWithItem:self.cateTitleView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.separatorView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0];
    }
    else {
        [_separatorView removeFromSuperview];
        _separatorView = nil;
        [self.cateTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cateTitleContentView]|"
                                                                                   options:kNilOptions
                                                                                   metrics:nil
                                                                                     views:subviewDict]];
        // scrollView bottom
        cateTitleViewBottom = [NSLayoutConstraint constraintWithItem:self.cateTitleView
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0.0];
    }
    cateTitleViewBottom.priority = UILayoutPriorityDefaultHigh;
    [self addConstraint:cateTitleViewBottom];

    
    [self.cateTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cateTitleContentView]|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:subviewDict]];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.cateTitleContentView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.cateTitleView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1.0
                                  constant:0.0];
    height.priority = UILayoutPriorityDefaultHigh;
    [self.cateTitleView addConstraint:height];

    [self setNeedsLayout];
}

- (BOOL)canDisplaySeparatorView {
    return self.separatorStyle != PageCateButtonViewSeparatorStyleNone
    && _separatorView.superview;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (UIScrollView *)cateTitleView {
    if (_cateTitleView == nil) {
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        _cateTitleView = scrollView;
        //        _cateTitleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - self.rightItem.contentWidth, CGRectGetHeight(self.frame));
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _cateTitleView;
}
- (DefaultUnderLineView *)underLineView {
    if (!_underLineView) {
        _underLineView = [[DefaultUnderLineView alloc] init];
        _underLineView.backgroundColor = [UIColor redColor];
        _underLineView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _underLineView;
}

- (UIView *)cateTitleContentView {
    if (!_cateTitleContentView) {
        _cateTitleContentView = [CateButtonContentView new];
        _cateTitleContentView.backgroundColor = [UIColor clearColor];
        _cateTitleContentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _cateTitleContentView;
}

- (UIView *)separatorView {
    if (_separatorView == nil) {
        UIImageView *separatorView = [[UIImageView alloc] init];
        separatorView.image = self.separatorImage;
        separatorView.backgroundColor = self.separatorBackgroundColor;
        _separatorView = separatorView;
        separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _separatorView;
}



- (BOOL)isCanScroll {
    if (self.rightItem.button) {
        return self.cateTitleContentView.scrollViewContentWidth > self.bounds.size.width - self.rightItem.contentWidth;
    }
    return self.cateTitleContentView.scrollViewContentWidth > self.bounds.size.width;
}

@end

@implementation PageCateButtonItem

@synthesize textFont = _textFont;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _button = [PageCateButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.font = self.textFont;
        _button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _button.contentMode = UIViewContentModeScaleAspectFit;
        [_button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        //        [_button setTitleColor:[UIColor redColor] forState:(UIControlStateSelected)];
        [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)buttonClick:(UIButton *)btn {
    if (self.buttonItemClickBlock) {
        self.buttonItemClickBlock(self);
    }
}

- (void)setSelected:(BOOL)selected {
    self.button.selected = selected;
}

- (BOOL)isSelected {
    return self.button.isSelected;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [_button setTitle:title forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [_button setImage:image forState:state];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _button.titleLabel.font = textFont;
}

- (CGFloat)contentWidth {
    if (_contentWidth <= 0) {
        
        NSString *currentText = self.button.currentTitle;
        UIImage *currentImage = self.button.currentImage;
        _contentWidth = [currentText sizeWithMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.textFont].width;
        /// 只有文字， 没有图片时
        if (currentText.length && !currentImage) {
            return _contentWidth += 10;
        }
        /// 没有文字， 只有图片时
        if (!currentText.length && currentImage != nil) {
            return _contentWidth += currentImage.size.width;
            
        }
        
        /// 图片和文字都有
        if (currentText.length && currentImage) {
            return _contentWidth = currentImage.size.width + _contentWidth + 10;
        }
    }
    return _contentWidth;
}

- (UIFont *)textFont {
    if (!_textFont) {
        _textFont = [UIFont systemFontOfSize:15];
    }
    return _textFont;
}


@end

@implementation NSString (DrawingAdditions)

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont*)font {
    
    CGSize textSize = CGSizeZero;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
        NSStringDrawingUsesFontLeading;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByCharWrapping];
        
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
        
        CGRect rect = [self boundingRectWithSize:maxSize
                                         options:opts
                                      attributes:attributes
                                         context:nil];
        textSize = rect.size;
    }
    else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [self sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    }
    
    return textSize;
}


@end


@implementation DefaultUnderLineView


@end


@implementation PageCateButton {
    CGSize _titleLabelSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}


// 图片太大，文本显示不出来，控制button中image的尺寸
// imageRectForContentRect:和titleRectForContentRect:不能互相调用imageView和titleLael,不然会死循环
- (CGRect)imageRectForContentRect:(CGRect)bounds {
    if (CGSizeEqualToSize(_titleLabelSize, CGSizeZero)) {
        return CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    }
    return CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height-_titleLabelSize.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (self.imageView.image) {
            return CGRectMake(0.0, self.imageView.bounds.size.height, self.bounds.size.width, self.bounds.size.height-self.imageView.bounds.size.height);
    }
    return CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);

}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    _titleLabelSize = [title sizeWithMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.titleLabel.font];
}


@end

@implementation CateButtonContentView

- (void)setButtonItems:(NSArray<PageCateButtonItem *> *)buttonItems {
    _buttonItems = buttonItems;
    
   
    [self reloadCateButtons];
}

- (void)reloadCateButtons {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray<NSString *> *subviewKeyArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *subviewDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *metrics = @{@"leftMargin": @(self.buttonMargin), @"sizeToFltWidth": @(self.sizeToFltWidth)}.mutableCopy;
    NSMutableString *verticalFormat = [NSMutableString new];
    
    for (NSInteger i = 0; i < self.buttonItems.count; i++) {
        PageCateButtonItem *buttonItem = self.buttonItems[i];
        buttonItem.index = i;
        
        buttonItem.buttonItemClickBlock = ^(PageCateButtonItem *item) {
            UIView *superView = self.superview;
            do {
                if ([superView respondsToSelector:@selector(buttonItemClick:)]) {
                    [superView performSelectorOnMainThread:@selector(buttonItemClick:) withObject:item waitUntilDone:NO];
                    superView = nil;
                }
                superView = superView.superview;
            } while (superView);
        };
        [self addSubview:buttonItem.button];
        buttonItem.button.translatesAutoresizingMaskIntoConstraints = NO;
        [subviewKeyArray addObject:[NSString stringWithFormat:@"button_%ld", i]];
        subviewDict[subviewKeyArray.lastObject] = buttonItem.button;
        
        // 设置垂直之间的约束
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[%@(>=0)]|", subviewKeyArray[i]] options:kNilOptions metrics:metrics views:subviewDict]];
        
        // 设置水平之间的约束
        CGFloat leftMargin = self.buttonMargin;
        
        void (^verticalFormatBlock)(NSString *widthKey) = ^(NSString *widthKey){
            if (i == self.buttonItems.count - 1) {
                [verticalFormat appendFormat:@"-(%.f@750)-[%@(%@)]-(%.f@750)-", leftMargin, subviewKeyArray[i], widthKey, leftMargin];
            }
            else {
                [verticalFormat appendFormat:@"-(%.f@750)-[%@(%@)]", leftMargin, subviewKeyArray[i], widthKey];
            }
        };
        
        
        if (!self.isCanScroll && self.sizeToFltWhenScreenNotPaved) {
            verticalFormatBlock(@"sizeToFltWidth");
        }
        else {
            NSString *contentWidthKey = [NSString stringWithFormat:@"contentWidth_%ld", i];
            [metrics setValue:@(buttonItem.contentWidth) forKey:contentWidthKey];
            verticalFormatBlock(contentWidthKey);
        }
        
        
    }
    
    if (verticalFormat.length) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|%@|", verticalFormat] options:kNilOptions metrics:metrics views:subviewDict]];
    }
    
}

@end
