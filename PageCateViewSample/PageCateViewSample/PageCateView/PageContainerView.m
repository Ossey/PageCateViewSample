//
//  PageContainerView.m
//  PageCateViewSample
//
//  Created by Ossey on 28/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "PageContainerView.h"

/// scrollView 滚动中的方向
typedef NS_ENUM(NSInteger, PageContainerViewScrollingDirection) {
    PageContainerViewScrollingDirectionNotKnow,
    PageContainerViewScrollingDirectionLeft,
    PageContainerViewScrollingDirectionRight,
    PageContainerViewScrollingDirectionUp,
    PageContainerViewScrollingDirectionDown,
};

@interface PageContainerViewFlowLayout : UICollectionViewFlowLayout

@end

@interface PageCollectionView : UICollectionView

@property (nonatomic, copy) BOOL (^shouldRecognizeSimultaneouslyBlock)(UIGestureRecognizer *gestureRecognizer);
/** 允许多手势同时存在，default is YES */
@property (nonatomic, assign) BOOL shouldAllowRecognizeSimultaneously;
/** scrollView 滚动中的方向，相对于上次滚动 */
@property (nonatomic, assign) PageContainerViewScrollingDirection scrollingDirection;

@end

@interface PageContainerViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *channelView;

@end

@interface PageContainerView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) PageCollectionView *collectionView;
@property (nonatomic, assign) CGPoint startScrollOffset;
@property (nonatomic, strong) PageCateButtonView *cateButtonView;
@property (nonatomic, strong) PageContainerViewFlowLayout *flowLayout;
@property (nonatomic, assign) NSInteger totalChanelCount;

/** 触发页面滚动的对象：PageContainerView 或 PageCateButtonItem */
@property (nonatomic, weak) id triggerScrollTarget;
@property (nonatomic, assign) NSInteger currentIndex;


@end

@implementation PageContainerView

@synthesize rootViewController = _rootViewController;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupViews];
    }
    return self;
}


- (void)setRootViewController:(UIViewController *)rootViewController {
    if (_rootViewController != rootViewController) {
        return;
    }
    _rootViewController = rootViewController;
    [self reloadData];
    
}

- (void)setChildViewControllers:(NSArray<UIViewController *> *)childViewControllers {
    _childViewControllers = childViewControllers;
    
    NSArray *tempArray = [self.rootViewController.childViewControllers mutableCopy];
    [tempArray enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }];
    tempArray = nil;
    
    for (UIViewController *vc in childViewControllers) {
        [self.rootViewController addChildViewController:vc];
    }
    
    [self reloadData];
}


- (UIViewController *)rootViewController {
    if (!_rootViewController) {
        _rootViewController = [self getCurrentViewController];
    }
    return _rootViewController;
}

- (PageCollectionView *)collectionView {
    if (!_collectionView) {
        _flowLayout = [PageContainerViewFlowLayout new];
        _collectionView = [[PageCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[PageContainerViewCell class] forCellWithReuseIdentifier:@"PageContainerView.PageContainerViewCell"];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _collectionView;
}

- (void)setupViews {
    self.shouldAllowRecognizeSimultaneously = YES;
    self.startScrollOffset = CGPointZero;
    [self addSubview:self.collectionView];
    NSDictionary *viewDict = @{@"collectionView": self.collectionView};
    
    NSArray *collectionViewConstraints = @[
                                           [NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|" options:kNilOptions metrics:nil views:viewDict],
                                           
                                           [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:kNilOptions metrics:nil views:viewDict]
                                           ];
    [self addConstraints:[collectionViewConstraints valueForKeyPath:@"@unionOfArrays.self"]];
    
}

- (void)setShouldAllowRecognizeSimultaneously:(BOOL)shouldAllowRecognizeSimultaneously {
    _shouldAllowRecognizeSimultaneously = shouldAllowRecognizeSimultaneously;
    self.collectionView.shouldAllowRecognizeSimultaneously = shouldAllowRecognizeSimultaneously;
}

- (void)setDelegate:(id<PageContainerViewDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }
    _delegate = delegate;
    
    self.cateButtonView = [delegate pageCateButtonViewForContainerView];
}

- (UIViewController *)getCurrentViewController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

- (void)setCateButtonView:(PageCateButtonView *)cateButtonView {
    _cateButtonView = cateButtonView;
    [self.collectionView reloadData];
}


////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource
////////////////////////////////////////////////////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalChanelCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PageContainerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PageContainerView.PageContainerViewCell" forIndexPath:indexPath];
    
    UIView *channelView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageCateChannelViewForContainerView:forIndex:)]) {
        channelView = [self.delegate pageCateChannelViewForContainerView:self forIndex:indexPath.row];
    } else {
        UIViewController *childVC = self.childViewControllers[indexPath.item];
        channelView = childVC.view;
    }
    cell.channelView = channelView;
    return cell;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate
////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.triggerScrollTarget = self;
    self.startScrollOffset = scrollView.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (CGSizeEqualToSize(scrollView.contentSize, CGSizeZero) ||
        scrollView.contentSize.height <= 0) {
        // mark: 第一次滚动collectionView时contentSize不对，height为0，导致无论如何刷新的都是一个cell
        [self scrollToIndex:self.currentIndex animated:NO];
    }
    if (self.triggerScrollTarget == self.cateButtonView) {
        return;
    }
    
    [self __scrolling];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.triggerScrollTarget == self.cateButtonView) {
        return;
    }
    [self __scrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.triggerScrollTarget == self.cateButtonView) {
        return;
    }
    if (!decelerate) {
        [self __scrolling];
    }
}


- (void)__scrolling {
    CGFloat progress = 0;
    NSInteger fromIndex = 0;
    NSInteger toIndex = 0;
    // 判断是左滑还是右滑
    CGFloat currentOffsetX = self.collectionView.contentOffset.x;
    CGFloat scrollViewW = self.collectionView.bounds.size.width;
    if (currentOffsetX > self.startScrollOffset.x) {
        // 左滑
        progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
        // fromIndex
        fromIndex = currentOffsetX / scrollViewW;
        // toIndex
        toIndex = fromIndex + 1;
        if (toIndex >= self.totalChanelCount) {
            progress = 1;
            toIndex = fromIndex;
        }
        // 直接滑过去
        if (currentOffsetX - self.startScrollOffset.x == scrollViewW) {
            progress = 1;
            toIndex = fromIndex;
        }
    }
    else {
        // 右滑
        progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
        // toIndex
        toIndex = currentOffsetX / scrollViewW;
        // fromIndex
        fromIndex = toIndex + 1;
        if (fromIndex >= self.totalChanelCount) {
            fromIndex = self.totalChanelCount - 1;
        }
    }
    [self __didScrollFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)__didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    BOOL flag = fromIndex == toIndex && fromIndex != 0;
    if (!flag && self.delegate && [self.delegate respondsToSelector:@selector(pageContainerView:didScrollFromIndex:toIndex:progress:)]) {
        [self.delegate pageContainerView:self didScrollFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
    [self.cateButtonView scrollButtonFormIndex:fromIndex toIndex:toIndex progress:progress];
    self.currentIndex = toIndex;
}

- (NSInteger)totalChanelCount {
    if (self.cateButtonView) {
        return self.cateButtonView.buttonItems.count;
    }
    return self.childViewControllers.count;
}

- (void)scrollToIndex:(NSInteger)toIndex {
    [self scrollToIndex:toIndex animated:YES];
}

- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated {
    self.currentIndex = toIndex;
    [self layoutIfNeeded];
    CGFloat offsetX = toIndex * MAX(self.collectionView.frame.size.width, [UIScreen mainScreen].bounds.size.width);
    [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PageCateButtonViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)pageCateButtonView:(PageCateButtonView *)view didSelectedIndex:(NSInteger)selectedIndex previousIndex:(NSInteger)previousIndex {
    self.triggerScrollTarget = view;
    [self scrollToIndex:selectedIndex];
    [self __didScrollFromIndex:previousIndex toIndex:selectedIndex progress:1.0];
}


- (NSInteger)numberOfButtonItemsInPageCateButtonView {
    return [self.delegate numberOfButtonItemsInPageContainerView];
}

- (PageCateButtonItem *)pageCateButtonView:(PageCateButtonView *)buttonView atIndex:(NSInteger)index {
    return [self.delegate pageContainerView:self buttonItemAtIndex:index];
}

- (PageCateButtonItem *)rightButtonItemForPageCateButtonView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightButtonItemForPageCateButtonView)]) {
        return [self.delegate rightButtonItemForPageCateButtonView];
    }
    return nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.collectionView.scrollEnabled = scrollEnabled;
}

- (void)reloadData {
    [self.collectionView reloadData];
}


@end

@implementation PageContainerViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.itemSize = self.collectionView.frame.size.width ? self.collectionView.frame.size : CGSizeMake([UIScreen mainScreen].bounds.size.width, self.collectionView.frame.size.height);
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
}

@end

@implementation PageContainerViewCell



- (void)setChannelView:(UIView *)channelView {
    NSParameterAssert(channelView);
    if (_channelView == channelView) {
        return;
    }
    [channelView removeConstraintsOfViewFromView:self.contentView];
    _channelView = channelView;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_channelView) {
        _channelView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:channelView];
        NSDictionary *viewDict = @{@"channelView": channelView};
        NSArray *channelViewConstraints = @[
                                            [NSLayoutConstraint constraintsWithVisualFormat:@"|[channelView]|" options:kNilOptions metrics:nil views:viewDict],
                                            
                                            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[channelView]|" options:kNilOptions metrics:nil views:viewDict]
                                            ];
        [self addConstraints:[channelViewConstraints valueForKeyPath:@"@unionOfArrays.self"]];
    }
    
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
}

@end

static void * PageCollectionViewContentOffsetContext = &PageCollectionViewContentOffsetContext;

@implementation PageCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self commonInit];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:PageCollectionViewContentOffsetContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == PageCollectionViewContentOffsetContext && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        if ([change[@"new"] CGPointValue].y > [change[@"old"] CGPointValue].y  ) { // 向上滚动
            self.scrollingDirection = PageContainerViewScrollingDirectionUp;
        } else if ([change[@"new"] CGPointValue].y < [change[@"old"] CGPointValue].y  ) { // 向下滚动
            self.scrollingDirection = PageContainerViewScrollingDirectionDown;
        }
        
        if ([change[@"new"] CGPointValue].x > [change[@"old"] CGPointValue].x  ) { // 向左滚动
            self.scrollingDirection = PageContainerViewScrollingDirectionLeft;
        } else if ([change[@"new"] CGPointValue].x < [change[@"old"] CGPointValue].x  ) { // 向右滚动
            self.scrollingDirection = PageContainerViewScrollingDirectionRight;
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *touchView = [super hitTest:point withEvent:event];
    __weak typeof(self) weakSelf = self;
    // 是否运行多手势同时存在
    self.shouldRecognizeSimultaneouslyBlock = ^BOOL(UIGestureRecognizer *gestureRecognizer) {
        if (weakSelf.contentOffset.x <= 0.0 && self.shouldAllowRecognizeSimultaneously && self.scrollingDirection == PageContainerViewScrollingDirectionRight) {
            return YES;
        }
        return NO;
    };
    return touchView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer.view == self) {
        if (self.shouldRecognizeSimultaneouslyBlock) {
            return self.shouldRecognizeSimultaneouslyBlock(gestureRecognizer);
        }
    }
    return NO;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:PageCollectionViewContentOffsetContext];
}

@end
