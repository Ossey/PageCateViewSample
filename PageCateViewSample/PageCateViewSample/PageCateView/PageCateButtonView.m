//
//  PageCateButtonView.m
//  PageCateViewSample
//
//  Created by Ossey on 27/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "PageCateButtonView.h"


typedef NS_ENUM(NSUInteger, PageCateButtonEdgeInsetsStyle) {
    PageCateButtonEdgeInsetsStyleImageLeft,
    PageCateButtonEdgeInsetsStyleImageRight,
    PageCateButtonEdgeInsetsStyleImageTop,
    PageCateButtonEdgeInsetsStyleImageBottom
};

@interface PageCateButton : UIButton

@property (nonatomic) PageCateButtonEdgeInsetsStyle edgeInsetsStyle;

@property (nonatomic) CGFloat imageTitleSpace;

@end


@interface NSString (DrawingAdditions)

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont*)font;

@end

@interface DefaultUnderLineView : UIImageView

@end

@interface PageCateButtonView ()

@property (nonatomic, strong) UIScrollView *cateTitleView;
/** 根据所有button 和 间距 计算到的总宽度 */
@property (nonatomic, assign) CGFloat scrollViewContentWidth;
/** 底部分割线 */
@property (nonatomic, strong) UIImageView *separatorView;
/** 下划线 */
@property (nonatomic, strong) DefaultUnderLineView *underLineView;
/** 上次选中的按钮 */
@property (nonatomic, weak) PageCateButtonItem *previousSelectedBtnItem;

@property (nonatomic, assign) BOOL fristAppearUnderLine;

@end

@implementation PageCateButtonView

@synthesize
underLineImage = _underLineImage,
underLineBackgroundColor = _underLineBackgroundColor,
selectedIndex = _selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame delegate:nil cateItems:nil rightItem:nil];
}

- (instancetype)initWithFrame:(CGRect)frame cateItems:(NSArray<PageCateButtonItem *> *)cateItems rightItem:(PageCateButtonItem *)rightItem {
    
    return [self initWithFrame:frame delegate:nil cateItems:cateItems rightItem:rightItem];
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<PageCateButtonViewDelegate>)delegate cateItems:(NSArray<PageCateButtonItem *> *)cateItems rightItem:(PageCateButtonItem *)rightItem {
    
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.cateTitleView];
        _delegate = delegate;
        _rightItem = rightItem;
        _buttonMargin = 10;
        _underLineHeight = 1.0;
        _separatorHeight = 1.0;
        _automaticCenter = YES;
        _underLineBackgroundColor = [UIColor redColor];
        _separatorBackgroundColor = [UIColor blueColor];
        _cateItems = cateItems;
        _fristAppearUnderLine = YES;
        _underLineStyle = PageCateButtonViewUnderLineStyleDefault;
        _separatorStyle = PageCateButtonViewSeparatorStyleDefault;
    }
    return self;
}

- (void)setDelegate:(id<PageCateButtonViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadSubviews];
}

- (void)setCateItems:(NSArray<PageCateButtonItem *> *)cateItems {
    _cateItems = cateItems;
    
    [self reloadSubviews];
}

- (void)setRightItem:(PageCateButtonItem *)rightItem {
    _rightItem = rightItem;
    
    [self reloadSubviews];
}

- (void)reloadSubviews {
    
    for (NSInteger i = 0; i < self.cateItems.count; ++i) {
        PageCateButtonItem *buttonItem = self.cateItems[i];
        self.scrollViewContentWidth += buttonItem.contentWidth;
    }

    self.scrollViewContentWidth = _buttonMargin * (self.cateItems.count + 1) + self.scrollViewContentWidth;
    if (self.rightItem) {
        self.scrollViewContentWidth += self.rightItem.contentWidth + _buttonMargin;
    }
    self.scrollViewContentWidth = ceil(self.scrollViewContentWidth);
    
    if ([self isCanScroll]) {
        CGFloat bX = 0;
        CGFloat bY = 0;
        CGFloat bH = self.frame.size.height - self.separatorHeight;
        for (NSInteger i = 0; i < self.cateItems.count; i++) {
            PageCateButtonItem *buttonItem = self.cateItems[i];
            CGFloat bW = buttonItem.contentWidth+self.buttonMargin;
            buttonItem.button.frame = CGRectMake(bX, bY, bW, bH);
            bX += bW;
            buttonItem.index = i;
            __weak typeof(self) weakSelf = self;
            buttonItem.buttonItemClickBlock = ^(PageCateButtonItem *item) {
                [weakSelf buttonItemClick:item];
            };
            [self.cateTitleView addSubview:buttonItem.button];
        }
        if (self.rightItem) {
            CGFloat bW = self.rightItem.contentWidth+self.buttonMargin;
            bX += bW;
            self.rightItem.button.frame = CGRectMake(bX, bY, bW, bH);
            self.rightItem.index = self.cateItems.count + 1;
            __weak typeof(self) weakSelf = self;
            self.rightItem.buttonItemClickBlock = ^(PageCateButtonItem *item) {
                [weakSelf rightButtonItemClick:item];
            };
            [self.cateTitleView addSubview:self.rightItem.button];
            
        }
        CGFloat scrollViewWidth = self.rightItem ? CGRectGetMaxX(self.rightItem.button.frame) : CGRectGetMaxX(self.cateItems.lastObject.button.frame);
        self.cateTitleView.contentSize = CGSizeMake(scrollViewWidth, self.bounds.size.height);
    } else {
        CGFloat bY = 0;
        CGFloat bW = self.bounds.size.width / self.cateItems.count;
        CGFloat bH = self.bounds.size.height - self.separatorHeight;
        CGFloat bX = 0;
        for (NSInteger i = 0; i < self.cateItems.count; i++) {
            bX = i * bW;
            PageCateButtonItem *buttonItem = self.cateItems[i];
            buttonItem.button.frame = CGRectMake(bX, bY, bW, bH);
            buttonItem.index = i;
            __weak typeof(self) weakSelf = self;
            buttonItem.buttonItemClickBlock = ^(PageCateButtonItem *item) {
                [weakSelf buttonItemClick:item];
            };
            [self.cateTitleView addSubview:buttonItem.button];
        }
        if (self.rightItem) {
            CGFloat bW = self.rightItem.contentWidth+self.buttonMargin;
            bX += bW;
            self.rightItem.button.frame = CGRectMake(bX, bY, bW, bH);
            self.rightItem.index = self.cateItems.count + 1;
            __weak typeof(self) weakSelf = self;
            self.rightItem.buttonItemClickBlock = ^(PageCateButtonItem *item) {
                [weakSelf rightButtonItemClick:item];
            };
            [self.cateTitleView addSubview:self.rightItem.button];
        }
        self.cateTitleView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    }
    
    [self setSelectedIndex:self.selectedIndex];
    [self setUnderLineStyle:_underLineStyle];
    [self setSeparatorStyle:_separatorStyle];
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
    [self.cateTitleView addSubview:self.underLineView];
    
    [self.cateTitleView bringSubviewToFront:self.underLineView];
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
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self selecteButtonItemWithIndex:selectedIndex];
}

- (void)selecteButtonItemWithIndex:(NSInteger)index {
    
    if (index > self.cateItems.count - 1 || index < 0) {
        return;
    }
    PageCateButtonItem *buttonItem = self.cateItems[index];
    [self buttonItemClick:buttonItem];
}

- (void)setButtonItemTitle:(NSString *)title index:(NSInteger)index {
    if (index < self.cateItems.count) {
        PageCateButtonItem *buttonItem = self.cateItems[index];
        buttonItem.title = title;
        [self setUnderLineStyle:self.underLineStyle];
    }
}

- (NSInteger)selectedIndex {
    
    return  _selectedIndex == 0 || _selectedIndex > self.cateItems.count ? self.previousSelectedBtnItem.index : _selectedIndex;
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
        for (NSInteger i = 0; i < self.cateItems.count; ++i) {
            PageCateButtonItem *item = self.cateItems[i];
            item.button.transform = CGAffineTransformMakeScale(1, 1);
        }
        buttonItem.button.transform = CGAffineTransformMakeScale(1 + self.itemTitleScale, 1 + self.itemTitleScale);
    }
}

- (void)setupCenterForButtonItem:(PageCateButtonItem *)buttonItem {
    
    if (!self.automaticCenter) {
        return;
    }
    
    if (self.scrollViewContentWidth <= self.frame.size.width) {
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
    void (^animationBlock)() = ^{
        CGRect underLineFrame = self.underLineView.frame;
        underLineFrame.size.width = buttonItem.contentWidth;
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

/// 给外界提供的方法
- (void)setPageTitleViewWithProgress:(CGFloat)progress formIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    PageCateButtonItem *fromItem = self.cateItems[fromIndex];
    PageCateButtonItem *toItem = self.cateItems[toIndex];
    
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

- (PageCateButtonItem *)getButtonItemByButton:(UIButton *)button {
    NSUInteger foundIdxInItems = [self.cateItems indexOfObjectPassingTest:^BOOL(PageCateButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = obj.button == button;
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (foundIdxInItems != NSNotFound) {
        return [self.cateItems objectAtIndex:foundIdxInItems];
    }
    return nil;
}

- (PageCateButtonItem *)getCurrentSelectedButtonitem {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"] ;
    NSArray *selectedItems = [self.cateItems filteredArrayUsingPredicate:predicate];
    return selectedItems.firstObject;
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
        _cateTitleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - self.rightItem.contentWidth, CGRectGetHeight(self.frame));
    }
    return _cateTitleView;
}
- (DefaultUnderLineView *)underLineView {
    if (!_underLineView) {
        _underLineView = [[DefaultUnderLineView alloc] init];
        _underLineView.backgroundColor = [UIColor redColor];
    }
    return _underLineView;
}

- (UIView *)separatorView {
    if (_separatorView == nil) {
        UIImageView *separatorView = [[UIImageView alloc] init];
        separatorView.image = self.separatorImage;
        separatorView.backgroundColor = self.separatorBackgroundColor;
        _separatorView = separatorView;
        CGRect frame = _separatorView.frame;
        frame.origin.y = CGRectGetHeight(self.cateTitleView.frame);
        frame.size.height = _separatorHeight;
        frame.size.width = CGRectGetWidth(self.frame);
        frame.origin.x = 0;
        _separatorView.frame = frame;
        
    }
    return _separatorView;
}



- (BOOL)isCanScroll {
    return self.scrollViewContentWidth > self.bounds.size.width;
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
        [_button setTitleColor:[UIColor redColor] forState:(UIControlStateSelected)];
        [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        PageCateButton *btn = (PageCateButton *)_button;
        btn.edgeInsetsStyle = PageCateButtonEdgeInsetsStyleImageTop;
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

- (void)setTitle:(NSString *)title {
    _title = title;
    [_button setTitle:title forState:UIControlStateNormal];
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    UIImage *image = [UIImage imageNamed:imageName];
//    image = [self scaleToSize:image size:CGSizeMake(30, 30)];
    [_button setImage:image forState:UIControlStateNormal];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _button.titleLabel.font = textFont;
}

- (CGFloat)contentWidth {
    if (_contentWidth <= 0) {
        
        NSString *currentText = self.button.currentTitle;
        UIImage *currentImage = self.button.currentImage;
        _contentWidth = [self.title sizeWithMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.textFont].width;
        /// 只有文字， 没有图片时
        if (currentText.length && !currentImage) {
            return _contentWidth;
        }
        /// 没有文字， 只有图片时
        if (!currentText.length && currentImage != nil) {
            return currentImage.size.width;
            
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

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
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


@implementation PageCateButton

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.edgeInsetsStyle = _edgeInsetsStyle;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    [self setEdgeInsetsStyle:_edgeInsetsStyle];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    [self setEdgeInsetsStyle:_edgeInsetsStyle];
}

- (void)setEdgeInsetsStyle:(PageCateButtonEdgeInsetsStyle)edgeInsetsStyle {
    
    [self setTitleEdgeInsets:UIEdgeInsetsZero];
    [self setImageEdgeInsets:UIEdgeInsetsZero];
    
    [self layoutIfNeeded];
    
    _edgeInsetsStyle = edgeInsetsStyle;
    CGFloat space = self.imageTitleSpace;
    CGFloat imageViewWidth = CGRectGetWidth(self.imageView.frame);
    CGFloat labelWidth = CGRectGetWidth(self.titleLabel.frame);
    
    if (labelWidth == 0) {
        CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
        labelWidth  = titleSize.width;
    }
    
    CGFloat imageInsetsTop = 0.0f;
    CGFloat imageInsetsLeft = 0.0f;
    CGFloat imageInsetsBottom = 0.0f;
    CGFloat imageInsetsRight = 0.0f;
    
    CGFloat titleInsetsTop = 0.0f;
    CGFloat titleInsetsLeft = 0.0f;
    CGFloat titleInsetsBottom = 0.0f;
    CGFloat titleInsetsRight = 0.0f;
    
    switch (edgeInsetsStyle) {
        case PageCateButtonEdgeInsetsStyleImageRight:
        {
            space = space * 0.5;
            
            imageInsetsLeft = labelWidth + space;
            imageInsetsRight = -imageInsetsLeft;
            
            titleInsetsLeft = - (imageViewWidth + space);
            titleInsetsRight = -titleInsetsLeft;
        }
            break;
            
        case PageCateButtonEdgeInsetsStyleImageLeft:
        {
            space = space * 0.5;
            
            imageInsetsLeft = -space;
            imageInsetsRight = -imageInsetsLeft;
            
            titleInsetsLeft = space;
            titleInsetsRight = -titleInsetsLeft;
        }
            break;
        case PageCateButtonEdgeInsetsStyleImageBottom:
        {
            CGFloat imageHeight = CGRectGetHeight(self.imageView.frame);
            CGFloat labelHeight = CGRectGetHeight(self.titleLabel.frame);
            CGFloat buttonHeight = CGRectGetHeight(self.frame);
            CGFloat boundsCentery = (imageHeight + space + labelHeight) * 0.5;
            
            CGFloat centerX_button = CGRectGetMidX(self.bounds); // bounds
            CGFloat centerX_titleLabel = CGRectGetMidX(self.titleLabel.frame);
            CGFloat centerX_image = CGRectGetMidX(self.imageView.frame);
            
            CGFloat imageBottomY = CGRectGetMaxY(self.imageView.frame);
            CGFloat titleTopY = CGRectGetMinY(self.titleLabel.frame);
            
            imageInsetsTop = buttonHeight - (buttonHeight * 0.5 - boundsCentery) - imageBottomY;
            imageInsetsLeft = centerX_button - centerX_image;
            imageInsetsRight = - imageInsetsLeft;
            imageInsetsBottom = - imageInsetsTop;
            
            titleInsetsTop = (buttonHeight * 0.5 - boundsCentery) - titleTopY;
            titleInsetsLeft = -(centerX_titleLabel - centerX_button);
            titleInsetsRight = - titleInsetsLeft;
            titleInsetsBottom = - titleInsetsTop;
            
        }
            break;
        case PageCateButtonEdgeInsetsStyleImageTop:
        {
            CGFloat imageHeight = CGRectGetHeight(self.imageView.frame);
            CGFloat labelHeight = CGRectGetHeight(self.titleLabel.frame);
            CGFloat buttonHeight = CGRectGetHeight(self.frame);
            CGFloat boundsCentery = (imageHeight + space + labelHeight) * 0.5;
            
            CGFloat centerX_button = CGRectGetMidX(self.bounds); // bounds
            CGFloat centerX_titleLabel = CGRectGetMidX(self.titleLabel.frame);
            CGFloat centerX_image = CGRectGetMidX(self.imageView.frame);
            
            CGFloat imageTopY = CGRectGetMinY(self.imageView.frame);
            CGFloat titleBottom = CGRectGetMaxY(self.titleLabel.frame);
            
            imageInsetsTop = (buttonHeight * 0.5 - boundsCentery) - imageTopY;
            imageInsetsLeft = centerX_button - centerX_image;
            imageInsetsRight = - imageInsetsLeft;
            imageInsetsBottom = - imageInsetsTop;
            
            titleInsetsTop = buttonHeight - (buttonHeight * 0.5 - boundsCentery) - titleBottom;
            titleInsetsLeft = -(centerX_titleLabel - centerX_button);
            titleInsetsRight = - titleInsetsLeft;
            titleInsetsBottom = - titleInsetsTop;
        }
            break;
            
        default:
            break;
    }
    
    self.imageEdgeInsets = UIEdgeInsetsMake(imageInsetsTop, imageInsetsLeft, imageInsetsBottom, imageInsetsRight);
    self.titleEdgeInsets = UIEdgeInsetsMake(titleInsetsTop, titleInsetsLeft, titleInsetsBottom, titleInsetsRight);
}

- (void)setImageTitleSpace:(CGFloat)imageTitleSpace {
    _imageTitleSpace = imageTitleSpace;
    
    [self setEdgeInsetsStyle:_edgeInsetsStyle];
}

@end
