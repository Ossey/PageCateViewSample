//
//  PageContainerView.m
//  PageCateViewSample
//
//  Created by Ossey on 28/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "PageContainerView.h"
#import "Masonry.h"

@interface PageContainerViewFlowLayout : UICollectionViewFlowLayout

@end

@interface PageContainerViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *channelView;

@end

@interface PageContainerView () <UICollectionViewDelegate, UICollectionViewDataSource, PageCateButtonViewDelegate>

@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, strong) NSArray *childViewControllers;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGPoint startScrollOffset;
@property (nonatomic, strong) PageCateButtonView *cateButtonView;
@property (nonatomic, strong) PageContainerViewFlowLayout *flowLayout;
@property (nonatomic, assign) NSInteger totalChanelCount;

/** 触发页面滚动的对象：PageContainerView 或 PageCateButtonItem */
@property (nonatomic, weak) id triggerScrollTarget;


@end

@implementation PageContainerView

- (instancetype)initWithFrame:(CGRect)frame parentViewController:(UIViewController *)parentViewController childViewControllers:(NSArray *)childViewControllers {
    if (self = [super initWithFrame:frame]) {
        self.parentViewController = parentViewController;
        self.childViewControllers = childViewControllers;
        for (UIViewController *vc in self.childViewControllers) {
            [self.parentViewController addChildViewController:vc];
        }
        [self __setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<PageContainerViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        [self __setup];
    }
    return self;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _flowLayout = [PageContainerViewFlowLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:_flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[PageContainerViewCell class] forCellWithReuseIdentifier:@"PageContainerView.PageContainerViewCell"];
    }
    return _collectionView;
}

- (void)__setup {
    self.startScrollOffset = CGPointZero;
    
    [self addSubview:self.collectionView];
}

- (void)setDelegate:(id<PageContainerViewDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }
    _delegate = delegate;
    
    self.cateButtonView = [delegate pageCateButtonViewForContainerView];
    self.cateButtonView.delegate = self;
}

-(UIViewController *)getCurrentViewController {
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

- (void)setChildViewControllers:(NSArray *)childViewControllers {
    _childViewControllers = childViewControllers;
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
    if (self.triggerScrollTarget == self.cateButtonView) {
        return;
    }
    
    [self __scrolling];
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
        // 计算 fromIndex
        fromIndex = currentOffsetX / scrollViewW;
        // 计算 toIndex
        toIndex = fromIndex + 1;
        if (toIndex >= self.totalChanelCount) {
            progress = 1;
            toIndex = fromIndex;
        }
        // 如果完全划过去
        if (currentOffsetX - self.startScrollOffset.x == scrollViewW) {
            progress = 1;
            toIndex = fromIndex;
        }
    }
    else {
        // 右滑
        progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
        // 计算 toIndex
        toIndex = currentOffsetX / scrollViewW;
        // 计算 fromIndex
        fromIndex = toIndex + 1;
        if (fromIndex >= self.totalChanelCount) {
            fromIndex = self.totalChanelCount - 1;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContainerView:didScrollWithProgress:fromIndex:toIndex:)]) {
        [self.delegate pageContainerView:self didScrollWithProgress:progress fromIndex:fromIndex toIndex:toIndex];
    }
}

- (NSInteger)totalChanelCount {
    if (self.cateButtonView) {
        return self.cateButtonView.cateItems.count;
    }
    return self.childViewControllers.count;
}
- (void)scrollToIndex:(NSInteger)toIndex {
    CGFloat offsetX = toIndex * self.collectionView.frame.size.width;
    self.collectionView.contentOffset = CGPointMake(offsetX, 0);
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PageCateButtonViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)pageCateButtonView:(PageCateButtonView *)view didSelectedAtIndex:(NSInteger)index {
    self.triggerScrollTarget = view;
    [self scrollToIndex:index];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.collectionView.scrollEnabled = scrollEnabled;
}


@end

@implementation PageContainerViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.itemSize = self.collectionView.frame.size;
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
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentView addSubview:channelView];
    _channelView = channelView;
    
    
    [_channelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.channelView.hidden = NO;
    }
    
    return self;
}


- (void)dealloc {
    
    NSLog(@"%s", __func__);
}

@end
