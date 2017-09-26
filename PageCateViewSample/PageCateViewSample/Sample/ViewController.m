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
#import "Masonry.h"

@interface ViewController () <PageContainerViewDelegate>
@property (nonatomic, strong) PageCateButtonView *cateButtonView;
@property (nonatomic, strong) PageContainerView *pageContentView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupPageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(testAction)];
}

- (void)testAction {
    [_cateButtonView setSizeToFltWhenScreenNotPaved:!_cateButtonView.sizeToFltWhenScreenNotPaved];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


static const NSInteger count = 8;


- (void)setupPageView {
    
    
    self.pageContentView = [[PageContainerView alloc] init];
    self.pageContentView.delegate = self;
    [self.view addSubview:_pageContentView];
        self.pageContentView.rootViewController = self;
    NSMutableArray *vcs = @[].mutableCopy;
    NSInteger i = 0;
    do {
        Sample1TableViewController *vc = [[Sample1TableViewController alloc] init];
        [vcs addObject:vc];
        i++;
    } while (i < count);
    self.pageContentView.childViewControllers = vcs;
    [_pageContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cateButtonView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.cateButtonView.selectedIndex = 1;
    self.cateButtonView.sizeToFltWhenScreenNotPaved = YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PageContainerViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)pageContainerView:(PageContainerView *)pageContentView
       didScrollFromIndex:(NSInteger)fromIndex
                  toIndex:(NSInteger)toIndex
                 progress:(CGFloat)progress {

}

- (NSInteger)numberOfButtonItemsInPageContainerView {
    return count;
}

- (PageCateButtonItem *)pageContainerView:(PageContainerView *)containerView buttonItemAtIndex:(NSInteger)index {
    
    PageCateButtonItem *buttonItem = [PageCateButtonItem new];
    buttonItem.contentWidth = 60;
    NSString *title = nil;
    if (index <= 6) {
        title = [NSString stringWithFormat:@"list%ld", index];
    }
    else {
        title = [NSString stringWithFormat:@"list%ld", index+10000];
    }
    [buttonItem setTitle:title forState:UIControlStateNormal];
    NSString *imageName = [NSString stringWithFormat:@"trip_sharing_%ld_publish_selected", index+1];
    [buttonItem setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return buttonItem;
}

- (PageCateButtonItem *)rightButtonItemForPageCateButtonView {
    PageCateButtonItem *item = [PageCateButtonItem new];
    NSString *title = @"right";
    [item setTitle:title forState:UIControlStateNormal];
    [item.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    item.button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    return item;
}

- (PageCateButtonView *)pageCateButtonViewForContainerView {
    return self.cateButtonView;
    
}

- (PageCateButtonView *)cateButtonView {
    if (!_cateButtonView) {
    
        _cateButtonView = [[PageCateButtonView alloc] initWithFrame:CGRectZero delegate:self.pageContentView];
        [self.view addSubview:_cateButtonView];
        _cateButtonView.indicatoScrollAnimated = YES;
        _cateButtonView.separatorHeight = 3.0;
        _cateButtonView.indicatoHeight = 5.0;
        _cateButtonView.itemScale = 0.05;
        _cateButtonView.bounces = YES;
        _cateButtonView.sizeToFltWhenScreenNotPaved = YES;
        CGFloat cateButtonViewTop = self.navigationController.isNavigationBarHidden ? 0 : 64;
        [_cateButtonView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.mas_equalTo(cateButtonViewTop);
            make.height.mas_equalTo(60);
        }];
    }
    [self.view bringSubviewToFront:_cateButtonView];
    return _cateButtonView;
}


@end
