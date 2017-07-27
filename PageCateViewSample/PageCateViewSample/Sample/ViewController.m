//
//  ViewController.m
//  PageCateViewSample
//
//  Created by Ossey on 27/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "ViewController.h"
#import "PageCateButtonView.h"
#import "PageContainerView.h"
#import "Sample1TableViewController.h"

@interface ViewController () <PageContainerViewDelegate, PageCateButtonViewDelegate>
@property (nonatomic, strong) PageCateButtonView *pageTitleView;
@property (nonatomic, strong) PageContainerView *pageContentView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupPageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupPageView {
    
    Sample1TableViewController *oneVC = [[Sample1TableViewController alloc] init];
    oneVC.view.backgroundColor = [UIColor yellowColor];
    Sample1TableViewController *twoVC = [[Sample1TableViewController alloc] init];
    oneVC.view.backgroundColor = [UIColor blueColor];
    Sample1TableViewController *threeVC = [[Sample1TableViewController alloc] init];
    oneVC.view.backgroundColor = [UIColor orangeColor];
    Sample1TableViewController *fourVC = [[Sample1TableViewController alloc] init];
    oneVC.view.backgroundColor = [UIColor greenColor];
    
    NSMutableArray *childArr = @[oneVC, twoVC, threeVC, fourVC].mutableCopy;
    /// pageContentView
    CGFloat contentViewHeight = self.view.frame.size.height - 108;
    
    self.pageContentView = [[PageContainerView alloc] initWithFrame:CGRectMake(0, 108, self.view.frame.size.width, contentViewHeight) parentVC:self childVCs:childArr];
    _pageContentView.delegate = self;
    [self.view addSubview:_pageContentView];
    
    NSMutableArray *titleArr = @[@"精选", @"电影", @"OC", @"Swift"].mutableCopy;
    
    [titleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PageCateButtonItem *item = [PageCateButtonItem new];
        item.title = obj;
        [titleArr replaceObjectAtIndex:idx withObject:item];
    }];
    /// pageTitleView
    self.pageTitleView = [[PageCateButtonView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44) delegate:self cateItems:titleArr rightItem:nil];
    [self.view addSubview:_pageTitleView];
    _pageTitleView.underLineCanScroll = NO;
    _pageTitleView.selectedIndex = 1;
}

- (void)pageCateButtonView:(PageCateButtonView *)view didSelectedAtIndex:(NSInteger)index {
    [self.pageContentView setPageCententViewCurrentIndex:index];
}

- (void)pageTitleView:(PageCateButtonView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentView setPageCententViewCurrentIndex:selectedIndex];
}

- (void)pageContainerView:(PageContainerView *)pageContentView progress:(CGFloat)progress fromIndex:(NSInteger)fromItem toIndex:(NSInteger)toIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress formIndex:fromItem toIndex:toIndex];

}




@end
