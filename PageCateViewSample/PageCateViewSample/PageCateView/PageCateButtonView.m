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

@interface DefaultIndIcatoView : UIImageView

@end

@interface CateButtonContentView : UIView

@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat itemHorizontalSpacing;
@property (nonatomic, assign) BOOL sizeToFltWhenScreenNotPaved;
@property (nonatomic, strong) NSArray<PageCateButtonItem *> *buttonItems;
@property (nonatomic, assign) CGFloat sizeToFltWidth;
/** 根据所有button 和 间距 计算到的总宽度 */
@property (nonatomic, assign) CGFloat scrollViewContentWidth;
@property (nonatomic, assign) PageCateButtonViewIndicatoStyle indicatoStyle;
@property (nonatomic, strong) DefaultIndIcatoView *indicatoView;
@property (nonatomic, strong) UIColor *indicatoBackgroundColor;
@property (nonatomic, strong) UIImage *indicatoImage;
@property (nonatomic, assign) CGFloat indicatoHeight;
@property (nonatomic, assign) BOOL fristAppearIndicato;
@property (nonatomic, assign) CGFloat separatorHeight;

- (PageCateButtonItem *)getCurrentSelectedButtonitem;
- (void)updateIndicatoViewPointForButtonItem:(PageCateButtonItem *)buttonItem;
// cateTitleView 不可以滚动，indicato 可以滚动
- (void)indicatoViewnNotFollowCateTitleViewViewlWithProgress:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem;
/// indicato 不跟随 cateTitleView滚动而滚动
- (void)indicatoViewnNotFollowCateTitleViewViewlWithProgress1:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem;
// cateTitleView 可以滚动，indicato 随着滚动
- (void)indicatoViewFollowCateTitleViewViewlWithProgress:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem;

- (void)updateButtonsConstraints;

@end


@interface NSString (DrawingAdditions)

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont*)font;

@end


@interface PageCateButtonView ()

@property (nonatomic, strong) UIScrollView *cateTitleView;
@property (nonatomic, strong) CateButtonContentView *cateTitleContentView;
@property (nonatomic, strong) UIImageView *separatorView;
@property (nonatomic, weak) PageCateButtonItem *previousSelectedBtnItem;
@property (nonatomic, strong) PageCateButtonItem *rightItem;
@property (nonatomic, strong) NSArray<PageCateButtonItem *> *buttonItems;

@end

@implementation PageCateButtonView
{
    /// scrollView右侧约束
    NSLayoutConstraint *_cateTitleViewRightConstraint;
}

@synthesize
indicatoImage = _indicatoImage,
indicatoBackgroundColor = _indicatoBackgroundColor,
selectedIndex = _selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame delegate:(nonnull id<PageCateButtonViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __setup];
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, nil);
    @throw nil;
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
    
    _itemHorizontalSpacing = 0.0;
    _separatorHeight = 1.0;
    _automaticCenter = YES;
    _separatorBackgroundColor = [UIColor blueColor];
    _indicatoStyle = PageCateButtonViewIndicatoStyleDefault;
    _separatorStyle = PageCateButtonViewSeparatorStyleDefault;
    [self addSubview:self.cateTitleView];
    [self.cateTitleView addSubview:self.cateTitleContentView];
    
    [self.cateTitleView addObserver:self
                         forKeyPath:NSStringFromSelector(@selector(contentOffset))
                            options:NSKeyValueObservingOptionNew
                            context:NULL];
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf setupButtonSizeToFltWidth];
        [weakSelf setupConstraints];
        [weakSelf.cateTitleContentView updateButtonsConstraints];
        PageCateButtonItem *currentItem = weakSelf.buttonItems[weakSelf.selectedIndex];
        [weakSelf.cateTitleContentView updateIndicatoViewPointForButtonItem:currentItem];
        weakSelf.selectedIndex = weakSelf.selectedIndex;
        [weakSelf.cateTitleView setContentOffset:CGPointMake(0, 0) animated:YES];
    }];
}

- (void)dealloc {
    [self.cateTitleView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Observer
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        //
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setDelegate:(id<PageCateButtonViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadSubviews];
}


- (void)setSizeToFltWhenScreenNotPaved:(BOOL)sizeToFltWhenScreenNotPaved {
    if ([self isCanScroll]) {
        return;
    }
    self.cateTitleContentView.sizeToFltWhenScreenNotPaved = sizeToFltWhenScreenNotPaved;
    [self reloadSubviews];
}


- (void)_removeAllConstraints {
    [self.cateTitleContentView removeConstraints:self.cateTitleContentView.constraints];
    [self.cateTitleView removeConstraints:self.cateTitleView.constraints];
    [self.rightItem.button removeConstraints:self.rightItem.button.constraints];
    [self.separatorView removeConstraints:self.separatorView.constraints];
    [self removeConstraint:_cateTitleViewRightConstraint];
    // 只移除self != firstItem, 防止将外界添加给self的约束移除掉了
    [[self.constraints mutableCopy] enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.firstItem isEqual:self]) {
            [self removeConstraint:obj];
        }
    }];
}



- (void)reloadSubviews {
    
    PageCateButtonItem *rightItem  = [self _rightButtonItemForPageCateButtonView];
    if (self.rightItem != rightItem) {
        [self.rightItem.button removeFromSuperview];
        self.rightItem = rightItem;
    }
    
    NSMutableArray *buttonItems = @[].mutableCopy;
    for (NSInteger i = 0; i < [self _numberOfButtonItemsInPageCateButtonView] ; ++i) {
        PageCateButtonItem *item = [self.delegate pageCateButtonView:self atIndex:i];
        NSParameterAssert([item isKindOfClass:[PageCateButtonItem class]]);
        [buttonItems addObject:item];
    }
    self.buttonItems = buttonItems;
    
    if (self.rightItem.button) {
        self.rightItem.index = self.buttonItems.count + 1;
        __weak typeof(self) weakSelf = self;
        self.rightItem.buttonItemClickBlock = ^(PageCateButtonItem *item) {
            [weakSelf rightButtonItemClick:item];
        };
        [self addSubview:self.rightItem.button];
    }
    
    [self setupConstraints];
    
    self.cateTitleContentView.separatorHeight = _separatorHeight;
    self.cateTitleContentView.indicatoHeight = _indicatoHeight;
    
    [UIView performWithoutAnimation:^{
        [self layoutIfNeeded];
    }];
    
    [self setupButtonSizeToFltWidth];
    
    
    self.cateTitleContentView.buttonItems = self.buttonItems;
    
    
    [self setSelectedIndex:self.selectedIndex];
    [self setIndicatoStyle:_indicatoStyle];
    [self setSeparatorStyle:_separatorStyle];
    
}

- (void)setupButtonSizeToFltWidth {
    self.cateTitleContentView.scrollViewContentWidth = 0;
    for (NSInteger i = 0; i < self.buttonItems.count; ++i) {
        PageCateButtonItem *buttonItem = self.buttonItems[i];
        self.cateTitleContentView.scrollViewContentWidth += buttonItem.contentWidth;
    }
    
    self.cateTitleContentView.scrollViewContentWidth = _itemHorizontalSpacing * (self.buttonItems.count + 1) + self.cateTitleContentView.scrollViewContentWidth;
    CGFloat contentViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    contentViewWidth =  self.rightItem.button ? contentViewWidth - self.rightItem.contentWidth : contentViewWidth;
    self.cateTitleContentView.scrollViewContentWidth = ceil(self.cateTitleContentView.scrollViewContentWidth);
    if (![self isCanScroll] && self.sizeToFltWhenScreenNotPaved) {
        self.cateTitleContentView.sizeToFltWidth = (contentViewWidth - (self.buttonItems.count - 1)*_itemHorizontalSpacing) / self.buttonItems.count;
    } else {
        self.cateTitleContentView.sizeToFltWidth = 0;
    }
    
    self.cateTitleContentView.isCanScroll = [self isCanScroll];
}


- (void)setIndicatoStyle:(PageCateButtonViewIndicatoStyle)indicatoStyle {
    _indicatoStyle = indicatoStyle;
    
    self.cateTitleContentView.indicatoStyle = indicatoStyle;
    
}

- (void)setSeparatorStyle:(PageCateButtonViewSeparatorStyle)separatorStyle {
    _separatorStyle = separatorStyle;
    
    if (separatorStyle == PageCateButtonViewIndicatoStyleNone) {
        [_separatorView removeFromSuperview];
        _separatorView = nil;
    }
    else if (PageCateButtonViewIndicatoStyleDefault) {
        [self addSubview:self.separatorView];
        [self insertSubview:_separatorView belowSubview:_cateTitleView];
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
        [self setIndicatoStyle:self.indicatoStyle];
    }
}

- (void)setButtonItemImage:(UIImage *)image forState:(UIControlState)state index:(NSInteger)index {
    if (index < self.buttonItems.count) {
        PageCateButtonItem *buttonItem = self.buttonItems[index];
        [buttonItem setImage:image forState:state];
        [self setIndicatoStyle:self.indicatoStyle];
    }
}

- (NSInteger)selectedIndex {
    if (_selectedIndex == 0 || _selectedIndex > self.buttonItems.count) {
        _selectedIndex = self.previousSelectedBtnItem.index;
    }
    return _selectedIndex;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)buttonItemClick:(PageCateButtonItem *)buttonItem {
    
    [self selectedButtonItemChange:buttonItem];
    [self setupCenterForButtonItem:buttonItem];
    [self.cateTitleContentView updateIndicatoViewPointForButtonItem:buttonItem];
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
    _selectedIndex = buttonItem.index;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageCateButtonView:didSelectedIndex:previousIndex:)]) {
        [self.delegate pageCateButtonView:self didSelectedIndex:buttonItem.index previousIndex:self.previousSelectedBtnItem.index];
    }
    
    [self applyButtonSelectedState:buttonItem];
}

- (void)applyButtonSelectedState:(PageCateButtonItem *)buttonItem {
    // 更新上次选中按钮的状态
    if (!self.previousSelectedBtnItem) {
        self.previousSelectedBtnItem = buttonItem;
    }
    else if (buttonItem && self.previousSelectedBtnItem == buttonItem) {
    }
    else if (self.previousSelectedBtnItem && self.previousSelectedBtnItem != buttonItem) {
        self.previousSelectedBtnItem.selected = NO;
        self.previousSelectedBtnItem = buttonItem;
    }
}


- (PageCateButtonItem *)_rightButtonItemForPageCateButtonView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightButtonItemForPageCateButtonView)]) {
        return [self.delegate rightButtonItemForPageCateButtonView];
    }
    return nil;
}

- (BOOL)canDisplayRightButton {
    if (self.rightItem.button && self.rightItem.button.superview) {
        return YES;
    }
    return NO;
}

//- (NSArray<PageCateButtonItem *> *)_buttonItemsForPageCateButtonView {
//    if (self.delegate) {
//        return [self.delegate buttonItemsForPageCateButtonView];
//    }
//    return nil;
//}

- (NSInteger)_numberOfButtonItemsInPageCateButtonView {
    return [self.delegate numberOfButtonItemsInPageCateButtonView];
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)selectedButtonItemChange:(PageCateButtonItem *)buttonItem {
    
    buttonItem.selected = YES;
    
    // 对选中的按钮进行缩放
    if (self.itemScale > 0) {
        for (NSInteger i = 0; i < self.buttonItems.count; ++i) {
            // 先恢复所有按钮的缩放值
            PageCateButtonItem *item = self.buttonItems[i];
            item.button.transform = CGAffineTransformMakeScale(1, 1);
        }
        // 当大当前点击的按钮的缩放值
        buttonItem.button.transform = CGAffineTransformMakeScale(1 + self.itemScale,
                                                                 1 + self.itemScale);
    }
}

- (void)setupCenterForButtonItem:(PageCateButtonItem *)buttonItem {
    // 自动滚动到中心
    if (!self.automaticCenter) {
        return;
    }
    
    if (self.cateTitleContentView.scrollViewContentWidth <= self.cateTitleView.frame.size.width) {
        return;
    }
    
    // 本质：移动标题滚动视图的偏移量
    // 计算当选择的标题按钮的中心点x在屏幕屏幕中心点时，标题滚动视图的x轴的偏移量
    CGFloat offsetX = buttonItem.button.center.x - CGRectGetWidth(self.cateTitleView.frame) * 0.5;
    offsetX = MAX(0, offsetX);
    
    CGFloat maxOffsetX = self.cateTitleView.contentSize.width - CGRectGetWidth(self.cateTitleView.frame);
    offsetX = MIN(offsetX, maxOffsetX);
    
    [self.cateTitleView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}




- (void)scrollButtonFormIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    
    PageCateButtonItem *fromItem = self.buttonItems[fromIndex];
    PageCateButtonItem *toItem = self.buttonItems[toIndex];
    _selectedIndex = toIndex;
    [self setupCenterForButtonItem:toItem];
    [self applyButtonSelectedState:toItem];
    /*
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"];
     NSArray *selectedButtons = [self.buttonItems filteredArrayUsingPredicate:predicate];
     if (selectedButtons.count > 1 && [selectedButtons containsObject:toItem]) {
     [selectedButtons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
     toItem.selected = YES;
     }
     */
    if (![self isCanScroll]) {
        if (self.indicatoScrollAnimated) {
            // 改变按钮的状态
            if (progress >= 0.8) {
                /// 此处取 >= 0.8 而不是 1.0 为的是防止用户滚动过快而按钮的选中状态并没有改变
                [self selectedButtonItemChange:toItem];
            }
            // cateTitleView 不可以滚动，indicatoView 可以滚动
            [self.cateTitleContentView indicatoViewnNotFollowCateTitleViewViewlWithProgress:progress fromButtonItem:fromItem toButtonItem:toItem];
        } else {
            /// 改变按钮的选择状态
            if (progress >= 0.5) {
                [self selectedButtonItemChange:toItem];
            } else {
                [self selectedButtonItemChange:fromItem];
            }
            // cateTitleView 不可以滚动，indicatoView 也不可滚动
            [self.cateTitleContentView indicatoViewnNotFollowCateTitleViewViewlWithProgress1:progress fromButtonItem:fromItem toButtonItem:toItem];
        }
    } else {
        if (self.indicatoScrollAnimated) {
            /// 改变按钮的选择状态
            if (progress >= 0.8) {
                [self selectedButtonItemChange:toItem];
            }
            // cateTitleView 可以滚动，indicatoView 随着滚动
            [self.cateTitleContentView indicatoViewFollowCateTitleViewViewlWithProgress:progress fromButtonItem:fromItem toButtonItem:toItem];
        } else {
            // cateTitleView 可以滚动，但是indicatoView 不随着滚动
            [self.cateTitleContentView indicatoViewnNotFollowCateTitleViewViewlWithProgress1:progress fromButtonItem:fromItem toButtonItem:toItem];
        }
    }
    
    
    if (self.itemScale) {
        // fromItem缩小
        fromItem.button.transform = CGAffineTransformMakeScale((1 - progress) * self.itemScale + 1,
                                                               (1 - progress) * self.itemScale + 1);
        // toItem放大
        toItem.button.transform = CGAffineTransformMakeScale(progress * self.itemScale + 1,
                                                             progress * self.itemScale + 1);
    }
}



////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)setIndicatoHeight:(CGFloat)indicatoHeight {
    
    _indicatoHeight = indicatoHeight;
    
    self.cateTitleContentView.indicatoHeight = indicatoHeight;
    
}

- (void)setBounces:(BOOL)bounces {
    self.cateTitleView.bounces = bounces;
}

- (BOOL)bounces {
    return self.cateTitleView.bounces;
}

- (void)setIndicatoImage:(UIImage *)indicatoImage {
    _indicatoImage = indicatoImage;
    
    self.cateTitleContentView.indicatoImage = indicatoImage;
}

- (UIColor *)indicatoBackgroundColor {
    
    return _indicatoBackgroundColor ?: [UIColor clearColor];
    
}

- (void)setIndicatoBackgroundColor:(UIColor *)indicatoBackgroundColor {
    _indicatoBackgroundColor = indicatoBackgroundColor;
    self.cateTitleContentView.indicatoBackgroundColor = indicatoBackgroundColor;
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
    self.cateTitleContentView.separatorHeight = separatorHeight;
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

- (BOOL)sizeToFltWhenScreenNotPaved {
    return self.cateTitleContentView.sizeToFltWhenScreenNotPaved;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setupConstraints {
    
    [self _removeAllConstraints];
    
    
    NSMutableArray<NSString *> *subviewKeyArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *subviewDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [subviewKeyArray addObject:@"cateTitleContentView"];
    subviewDict[subviewKeyArray.lastObject] = self.cateTitleContentView;
    
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
    
    
    if (![self canDisplayRightButton]) {
        _cateTitleViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.cateTitleView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0.0];
        [self.rightItem.button removeFromSuperview];
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
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:self.rightItem.contentWidth],
                               [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0.0],
                               [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:-self.separatorHeight],
                               [NSLayoutConstraint constraintWithItem:self.rightItem.button
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:0.0]
                               ]];
        
    }
    
    [self addConstraint:_cateTitleViewRightConstraint];
    
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

    [self addConstraint:cateTitleViewBottom];
    
    // cateTitleContentView
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cateTitleContentView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:-_separatorHeight]];
    
    
    [self.cateTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cateTitleContentView]|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:subviewDict]];
   
    [self layoutIfNeeded];
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
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        scrollView.clipsToBounds = NO;
    }
    return _cateTitleView;
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
        [self addSubview:_separatorView];
        [self insertSubview:_separatorView belowSubview:_cateTitleView];
    }
    return _separatorView;
}



- (BOOL)isCanScroll {
    CGFloat contentWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    if (self.rightItem.button) {
        return self.cateTitleContentView.scrollViewContentWidth >= contentWidth - self.rightItem.contentWidth;
    }
    return self.cateTitleContentView.scrollViewContentWidth >= contentWidth;
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


@implementation DefaultIndIcatoView


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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _fristAppearIndicato = YES;
        _indicatoBackgroundColor = [UIColor redColor];
        _sizeToFltWhenScreenNotPaved = YES;
        _indicatoHeight = 1.0;
    }
    return self;
}

- (void)setButtonItems:(NSArray<PageCateButtonItem *> *)buttonItems {
    _buttonItems = buttonItems;
    
    
    [self reloadCateButtons];
}

- (void)reloadCateButtons {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
    }
    
    [self updateButtonsConstraints];
}

- (void)updateButtonsConstraints {
    NSMutableArray<NSString *> *subviewKeyArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *subviewDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *metrics = @{@"leftMargin": @(self.itemHorizontalSpacing), @"sizeToFltWidth": @(self.sizeToFltWidth), @"bottomMargin": @(MAX(3, _indicatoHeight))}.mutableCopy;
    NSMutableString *verticalFormat = [NSMutableString new];
    
    for (NSInteger i = 0; i < self.buttonItems.count; i++) {
        PageCateButtonItem *buttonItem = self.buttonItems[i];
        [buttonItem.button removeConstraintsOfViewFromView:self];
        [subviewKeyArray addObject:[NSString stringWithFormat:@"button_%ld", i]];
        subviewDict[subviewKeyArray.lastObject] = buttonItem.button;
        
        // 设置垂直之间的约束
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[%@(>=0)]-(bottomMargin)-|", subviewKeyArray[i]] options:kNilOptions metrics:metrics views:subviewDict]];
        
        // 设置水平之间的约束
        CGFloat leftMargin = self.itemHorizontalSpacing;
        
        void (^verticalFormatBlock)(NSString *widthKey) = ^(NSString *widthKey){
            if (i == self.buttonItems.count - 1) {
                [verticalFormat appendFormat:@"-(%.f@1000.0)-[%@(%@)]-(%.f@1000.0)-", leftMargin, subviewKeyArray[i], widthKey, leftMargin];
            }
            else {
                [verticalFormat appendFormat:@"-(%.f@1000.0)-[%@(%@)]", leftMargin, subviewKeyArray[i], widthKey];
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

////////////////////////////////////////////////////////////////////////
#pragma mark - indicatoView 滚动
////////////////////////////////////////////////////////////////////////

// cateTitleView 不可以滚动，indicatoView 可以滚动
- (void)indicatoViewnNotFollowCateTitleViewViewlWithProgress:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem {
    
    
    if (self.indicatoStyle == PageCateButtonViewIndicatoStyleDefault) {
        
        CGFloat moveTotalX = toItem.button.frame.origin.x - fromItem.button.frame.origin.x;
        CGFloat moveX = moveTotalX * progress;
        CGPoint center = self.indicatoView.center;
        center.x = fromItem.button.center.x + moveX;
        self.indicatoView.center = center;
    }
}

/// under line view 不跟随 cateTitleView滚动而滚动
- (void)indicatoViewnNotFollowCateTitleViewViewlWithProgress1:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem {
    if (progress >= 0.5) {
        [self updateIndicatoViewPointForButtonItem:toItem];
    } else {
        [self updateIndicatoViewPointForButtonItem:fromItem];
    }
}

// cateTitleView 可以滚动，indicatoView 随着滚动
- (void)indicatoViewFollowCateTitleViewViewlWithProgress:(CGFloat)progress fromButtonItem:(PageCateButtonItem *)fromItem toButtonItem:(PageCateButtonItem *)toItem {
    
    /// 计算 toItem／fromItem 之间的距离
    CGFloat totalOffsetX = toItem.button.frame.origin.x - fromItem.button.frame.origin.x;
    /// 计算 toItem／fromItem 宽度的差值
    CGFloat totalDistance = CGRectGetMaxX(toItem.button.frame) - CGRectGetMaxX(fromItem.button.frame);
    /// 计算 indicatoView 滚动时 X 的偏移量
    CGFloat offsetX = totalOffsetX * progress;
    /// 计算 indicatoView 滚动时宽度的偏移量
    CGFloat distance = progress * (totalDistance - totalOffsetX);
    /// 计算 indicatoView 新的 frame
    CGRect indicatoFrame = self.indicatoView.frame;
    indicatoFrame.origin.x = fromItem.button.frame.origin.x + offsetX;
    indicatoFrame.size.width = fromItem.button.frame.size.width + distance;
    self.indicatoView.frame = indicatoFrame;
}

- (void)setIndicatoStyle:(PageCateButtonViewIndicatoStyle)indicatoStyle {
    _indicatoStyle = indicatoStyle;
    
    if (indicatoStyle == PageCateButtonViewIndicatoStyleNone) {
        NSIndexSet *indexSet = [self.subviews indexesOfObjectsPassingTest:^BOOL(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj isKindOfClass:[DefaultIndIcatoView class]];
        }];
        NSArray *resultArray = [self.subviews objectsAtIndexes:indexSet];
        for (DefaultIndIcatoView *view in resultArray) {
            [view removeFromSuperview];
        }
        resultArray = nil;
        _indicatoView = nil;
        return;
    }
    
    // 获取当前选中的buttonItem
    PageCateButtonItem *selectedItem = [self getCurrentSelectedButtonitem];
    if (!selectedItem) {
        return;
    }
    [self addSubview:self.indicatoView];
    
    [self bringSubviewToFront:self.indicatoView];
    self.indicatoView.backgroundColor = self.indicatoBackgroundColor;
    
    if (indicatoStyle == PageCateButtonViewIndicatoStyleDefault) {
        [self updateIndicatoViewPointForButtonItem:selectedItem];
    }
    
}

- (void)updateIndicatoViewPointForButtonItem:(PageCateButtonItem *)buttonItem {
    [UIView performWithoutAnimation:^{
        [self layoutIfNeeded];
    }];
    void (^animationBlock)() = ^{
        self.indicatoHeight = _indicatoHeight;
        CGRect indicatoFrame = self.indicatoView.frame;
        if (self.sizeToFltWhenScreenNotPaved) {
            indicatoFrame.size.width = MAX(0, self.sizeToFltWidth ?: buttonItem.contentWidth);
        } else {
            indicatoFrame.size.width = MAX(0, buttonItem.contentWidth);
        }
        indicatoFrame.origin.x = MAX(0, indicatoFrame.origin.x);
        indicatoFrame.origin.y = MAX(0, indicatoFrame.origin.y);
        self.indicatoView.frame = indicatoFrame;
        CGPoint center = self.indicatoView.center;
        center.x = buttonItem.button.center.x;
        self.indicatoView.center = center;
    };
    
    if (_fristAppearIndicato) {
        animationBlock();
        _fristAppearIndicato = NO;
    } else {
        [UIView animateWithDuration:0.2 animations:animationBlock completion:^(BOOL finished) {
            _fristAppearIndicato = NO;
        }];
    }
    
}

- (DefaultIndIcatoView *)indicatoView {
    if (!_indicatoView) {
        _indicatoView = [[DefaultIndIcatoView alloc] init];
        _indicatoView.backgroundColor = [UIColor redColor];
        _indicatoView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _indicatoView;
}

- (PageCateButtonItem *)getCurrentSelectedButtonitem {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"] ;
    NSArray *selectedItems = [self.buttonItems filteredArrayUsingPredicate:predicate];
    return selectedItems.firstObject;
}

- (void)setIndicatoBackgroundColor:(UIColor *)indicatoBackgroundColor {
    _indicatoBackgroundColor = indicatoBackgroundColor;
    if (indicatoBackgroundColor) {
        self.indicatoView.image = [UIImage new];
        _indicatoImage = [UIImage new];
        self.indicatoView.backgroundColor = indicatoBackgroundColor;
    }
}

- (void)setIndicatoImage:(UIImage *)indicatoImage {
    _indicatoImage = indicatoImage;
    
    if (_indicatoImage) {
        _indicatoBackgroundColor = [UIColor clearColor];
        self.indicatoView.backgroundColor = [UIColor clearColor];
        self.indicatoView.image = indicatoImage;
    }
}

- (void)setIndicatoHeight:(CGFloat)indicatoHeight {
    
    _indicatoHeight = indicatoHeight;
    
    CGRect frame = self.indicatoView.frame;
    frame.size.height = MAX(0, indicatoHeight);
    frame.size.width = MAX(0, frame.size.width);
    frame.origin.y = self.frame.size.height - indicatoHeight + _separatorHeight;
    frame.origin.y = MAX(0, frame.origin.y);
    frame.origin.x = MAX(0, frame.origin.x);
    self.indicatoView.frame = frame;
    
}

- (void)setSeparatorHeight:(CGFloat)separatorHeight {
    _separatorHeight = separatorHeight;
    [self setIndicatoHeight:_indicatoHeight];
}
@end



@implementation UIView (ConstraintsExtend)

- (void)removeConstraintsOfViewFromView:(UIView *)view {
    for (NSLayoutConstraint *c in view.constraints.copy) {
        if (c.firstItem == self || c.secondItem == self) {
            [view removeConstraint:c];
        }
    }
}

@end
