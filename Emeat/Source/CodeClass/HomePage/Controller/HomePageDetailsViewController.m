  //
//  HomePageDetailsViewController.m
//  Emeat
//
//  Created by liuheshun on 2017/11/20.
//  Copyright © 2017年 liuheshun. All rights reserved.
//

#import "HomePageDetailsViewController.h"
#import "HomePageDetailsHeadView.h"
#import "HomePageCommentDetailsTableViewCell.h"
#import "HomePageDetailsBottomView.h"
#import "LoginViewController.h"
#import "HomePageDetailsBuyNoticeView.h"
#import "HomePageShoppingDetailsTableViewCell.h"
#import "ActionSheetView.h"
#import "ShareImageViewController.h"
#import "SaleMoneyViewController.h"
#import "ShopCertificationViewController.h"
#import "UIImage+GIF.h"
#import "SaleShareImageViewController.h"
#import "SaleMoneyViewController.h"

#import "YNPageViewController.h"
#import "UIView+YNPageExtend.h"
#import "HomePageDetailsGoodsViewController.h"
#import "HomePageDetailsCommentsViewController.h"


@interface HomePageDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate ,YNPageViewControllerDataSource, YNPageViewControllerDelegate>
//轮播图
@property (nonatomic,strong) SDCycleScrollView *cycleScrollView;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIView *headBgView;


@property (nonatomic,strong) HomePageDetailsHeadView *headView;
@property (nonatomic,strong) HomePageDetailsBottomView *bottomView;
@property (nonatomic,strong) HomePageDetailsBuyNoticeView *buyNoticeView;

///轮播图数据源
@property (nonatomic,strong) NSMutableArray *bannerDataArray;
///详情图片数据源
@property (nonatomic,strong) NSMutableArray *detailsDataArray;

///商品详情
@property (nonatomic,strong) NSMutableArray *headDataArray;

///多规格
@property (nonatomic,strong) NSMutableArray *specsListMarray;
///头部高度
@property (nonatomic,assign) CGFloat headViewHeiht;

///0=分销(C端商品参与分销) 1=分享(B端商品)
@property (nonatomic,strong) NSString *isShowShareString;
///分销商id
@property (nonatomic,strong) NSString *distributorUid;

///分销弹窗view
@property (nonatomic,strong) ActionSheetView *actionsheet;


@end

@implementation HomePageDetailsViewController
{
    BOOL isClickGoods;
}


-(void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [GlobalHelper shareInstance].isLoginState = [user valueForKey:@"isLoginState"];
    self.navigationController.navigationBarHidden = YES;
    
    //获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者
    [center addObserver:self selector:@selector(InfoNotificationAction:) name:@"refreshHomePageDetailsControllerWithNotification" object:nil];
    
}
-(void)InfoNotificationAction:(NSNotification*)notification{
   // DLog(@"use == %@" , notification.userInfo)
    self.detailsId =  notification.userInfo[@"detailsId"];
    [self requsetDetailsData];
    [self requestBadNumValue];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshHomePageDetailsControllerWithNotification" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(238, 238, 238, 1);
    self.navItem.title = @"商品详情";
    
    
    
//    isClickGoods = YES;
//
    [self requsetDetailsData];
    [self showNavBarLeftItem ];
    [self requestSalePeopleId];
    ////
    
}


#pragma mark ==========设置子控制器

- (void)setupPageVC {
    
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionTop;
    configration.headerViewCouldScale = YES;
    /// 控制tabbar 和 nav
    configration.showTabbar = YES;
    configration.showNavigation = YES;
    //configration.lineWidthEqualFontWidth = YES;
    configration.showBottomLine = YES;
    configration.scrollMenu = NO;
    configration.aligmentModeCenter = NO;
    configration.menuHeight = 44*kScale;
    configration.showBottomLine = YES;
//    configration.showScrollLine = NO;
    configration.bottomLineBgColor = RGB(136, 136, 136, 1);
    configration.converColor = [UIColor redColor];
   // configration.lineHeight = 0.5;
    configration.bottomLineHeight = 0.5;
    configration.selectedItemColor = RGB(231, 35, 36, 1);
    configration.selectedItemFont = [UIFont systemFontOfSize:15*kScale];
    configration.itemFont = [UIFont systemFontOfSize:15*kScale];
    
//
//    NSMutableArray *buttonArrayM = @[].mutableCopy;
//    for (int i = 0; i < 2; i++) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setBackgroundImage:[UIImage imageNamed:@"anniu"] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"anniuxuanzhong"] forState:UIControlStateSelected];
//
//        /// seTitle -> sizeToFit -> 自行调整位置
//        /// button.imageEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 0);
//        [buttonArrayM addObject:button];
//    }
//    configration.buttonArray = buttonArrayM;
//
    
    
    //    configration.contentHeight
    /// 设置悬浮停顿偏移量
    configration.suspenOffsetY = 0;
    
    
    YNPageViewController *vc = [YNPageViewController pageViewControllerWithControllers:self.getArrayVCs
                                                                                titles:[self getArrayTitles]
                                                                                config:configration];
    vc.dataSource = self;
    vc.delegate = self;
    
    self.headBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, self.headViewHeiht)];
    self.headBgView.backgroundColor = [UIColor purpleColor];
    
    
    vc.headerView = self.headBgView;
    /// 指定默认选择index 页面
    vc.pageIndex = 0;
    
    
    
    
    
    /// 作为自控制器加入到当前控制器
    [vc addSelfToParentViewController:self];
    /// 如果隐藏了导航条可以 适当改y值
    vc.view.yn_y = kBarHeight;
   // [self.view addSubview:self.navView];
    
    [self addheadViews];
}


-(void)addheadViews{
    self.headView = [[HomePageDetailsHeadView alloc] initWithFrame:CGRectMake(0, 0, kWidth, self.headViewHeiht)];
    [self.headBgView addSubview:self.headView];

    self.headView.backgroundColor = [UIColor whiteColor];
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kWidth, 300*kScale) delegate:self placeholderImage:[UIImage imageNamed:@"商品主图加载"]];   //placeholder
    cycleScrollView.imageURLStringsGroup = self.bannerDataArray;
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    cycleScrollView.showPageControl = YES;//是否显示分页控件
    cycleScrollView.currentPageDotColor = [UIColor orangeColor]; // 自定义分页控件小圆标颜色
    [self.headView addSubview:cycleScrollView];
    self.cycleScrollView = cycleScrollView;
    
    
    ///头部赋值
    if (self.headDataArray.count!=0) {
        HomePageModel *model = [self.headDataArray firstObject];
        [self.headView configHeadViewWithModel:model];
    }
    
    ///是否可以查看价格
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if ([[user valueForKey:@"approve"] isEqualToString:@"1"]) {
        
        
    }else if ([[user valueForKey:@"approve"] isEqualToString:@"0"] || [[user valueForKey:@"approve"] isEqualToString:@"2"]){
        ///点击查看价格点击事件
        [self.headView.newspriceBtnLab addTarget:self action:@selector(checkPricesAction) forControlEvents:1];
    }
    
    [self.headView.noticeBtn addTarget:self action:@selector(noticeBtnAvtion) forControlEvents:1];
    
    __weak __typeof(self) weakSelf = self;
    self.headView.changeGoodsDetailsBlock = ^{
        isClickGoods = YES;
        [weakSelf.tableView reloadData];
    };
    
    self.headView.changeCommentDetailsBlock = ^{
        isClickGoods = NO;
        [weakSelf.tableView reloadData];
    };
    
    
    ///切换规格
    self.headView.returnSelectIndex = ^(NSInteger selectIndex) {
        
        HomePageModel *model = [GlobalHelper shareInstance].specsListMarray[selectIndex];
        weakSelf.detailsId = [NSString stringWithFormat:@"%ld" ,(long)model.commodityId] ;
        weakSelf.fromBaner = @"0"; ///此处不能传sp的ID
        [weakSelf requsetDetailsData];
        
    };

}



- (NSArray *)getArrayVCs {
    
    HomePageDetailsGoodsViewController *vc_1 = [[HomePageDetailsGoodsViewController alloc] init];
    
    HomePageDetailsCommentsViewController *vc_2 = [[HomePageDetailsCommentsViewController alloc] init];
    vc_1.fromBaner = self.fromBaner;
    vc_1.detailsId = self.detailsId;
    
    vc_2.fromBaner = self.fromBaner;
    vc_2.detailsId = self.detailsId;
    
    return @[vc_1, vc_2];
}

- (NSArray *)getArrayTitles {
    if (self.specsListMarray.count != 0) {
        HomePageModel *specsListModel = [self.specsListMarray firstObject];
        if ([specsListModel.isMeal isEqualToString:@"1"]) {
            return @[@"套餐详情", @"评价详情"];

        }else{
             return @[@"商品详情", @"评价详情"];
        }
    }
    return @[@"商品详情", @"评价详情"];
}



#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index {
    //PersonalViewController *vc = pageViewController.controllersM[index];
    UIViewController *vc = pageViewController.controllersM[index];
    
        if ([vc isKindOfClass:[HomePageDetailsGoodsViewController class]]) {
            return [(HomePageDetailsGoodsViewController *)vc tableView];
        } else {
            return [(HomePageDetailsCommentsViewController *)vc tableView];
        }
   // return [vc tableView];
}
#pragma mark - YNPageViewControllerDelegate
- (void)pageViewController:(YNPageViewController *)pageViewController
            contentOffsetY:(CGFloat)contentOffset
                  progress:(CGFloat)progress {
    
    
}




-(void)showNavBarLeftItem{
    
    self.leftButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"fanhui"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction)];
    [self.navBar pushNavigationItem:self.navItem animated:NO];
    [self.navItem setLeftBarButtonItem:self.leftButton];
    
    
}


-(void)leftItemAction{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark ==========//////请求分销商ID
//////请求分销商ID
-(void)requestSalePeopleId{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic = [self checkoutData];
    
    [MHNetworkManager postReqeustWithURL:[NSString stringWithFormat:@"%@/cas/d/getDistributor" ,baseUrl] params:dic successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"code"] integerValue] == 00 ) {
            
            self.distributorUid = [NSString stringWithFormat:@"%@" ,returnData[@"data"][@"distributorUid"]];
            
        }else{
            
        }
        
        DLog(@"分销 ===== %@" ,returnData);
        
        
    } failureBlock:^(NSError *error) {
        
        
    } showHUD:NO];
 
    
}

#pragma mark = 商品详情数据

-(void)requsetDetailsData{
    [SVProgressHUD show];
    self.bannerDataArray = [NSMutableArray array];
    self.detailsDataArray = [NSMutableArray array];
    self.headDataArray = [NSMutableArray array];
    self.specsListMarray = [NSMutableArray array];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
  
    NSString *str;
    if ([self.fromBaner isEqualToString:@"1"]) {////来自banner
        str = [NSString stringWithFormat:@"%@/m/mobile/commodity/commodityDeatilByCode?commodityCode=%@&mtype=%@&appVersionNumber=%@&user=%@" ,baseUrl ,self.detailsId,mTypeIOS ,[user valueForKey:@"appVersionNumber"] ,[user valueForKey:@"user"]];
    }
    else ///来自商品列表
    {
        str = [NSString stringWithFormat:@"%@/m/mobile/commodity/commodityDeatil?id=%@&mtype=%@&appVersionNumber=%@&user=%@" , baseUrl ,self.detailsId,mTypeIOS ,[user valueForKey:@"appVersionNumber"] ,[user valueForKey:@"user"]];
    }
    
    //DLog(@"详情接口==== %@" ,str);
    
    [MHNetworkManager getRequstWithURL:str params:nil successBlock:^(NSDictionary *returnData) {
        DLog(@"详情返回结果=== %@" ,returnData);
            if ([[returnData[@"status"] stringValue] isEqualToString:@"200"]) {
                
               
                
                HomePageModel *bannerModel = [HomePageModel yy_modelWithJSON:returnData[@"data"]];
                [GlobalHelper shareInstance].homePageDetailsId = [NSString stringWithFormat:@"%ld" ,bannerModel.id];

                CGSize r = [bannerModel.commodityDesc boundingRectWithSize:CGSizeMake(kWidth-30*kScale, 1000*kScale) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f*kScale]} context:nil].size;
                
                if ([bannerModel.showType isEqualToString:@"SOGO"]){///B端
                    self.headViewHeiht = (521-20)*kScale +r.height;
                    self.isShowShareString = @"1";
                }else{
                    self.headViewHeiht = (471-20)*kScale +r.height;
                    self.isShowShareString = @"0";
                }
                
                ///
                [self showNavBarItemRight];

                
                if (bannerModel) {
                    [self.headDataArray addObject:bannerModel];
                    self.bannerDataArray = [NSMutableArray arrayWithArray:[bannerModel.commodityBanner componentsSeparatedByString:@","]];
                    
                    NSMutableArray *imvMarray = [NSMutableArray arrayWithArray:[bannerModel.commodityDetail componentsSeparatedByString:@","]];
                    
                    for (NSString *imvString in imvMarray) {
                        HomePageModel *detailsModel = [HomePageModel new];
                        detailsModel.commodityDetail = imvString;
                        [self.detailsDataArray addObject:detailsModel];
                    }
                    
                    
                    
                    self.productTitle = bannerModel.commodityName;
                    self.productContent = bannerModel.commodityDesc;
                    self.productImageURL = [self.bannerDataArray firstObject];
                    self.productPrices = [NSString stringWithFormat:@"%ld" ,bannerModel.unitPrice];
                    self.priceTypes = bannerModel.priceTypes;
                    NSString *isMeal = [NSString stringWithFormat:@"%@" ,bannerModel.isMeal];
                    
                    
                    for (NSDictionary *specsListDic in returnData[@"data"][@"specsList"]) {
                        HomePageModel *specsListModel = [HomePageModel yy_modelWithJSON:specsListDic];
                        specsListModel.isMeal = isMeal;
                        [self.specsListMarray addObject:specsListModel];
                    }
                    [GlobalHelper shareInstance].specsListMarray = self.specsListMarray;
                    
                    [self setupPageVC];
                    [self.view addSubview:self.bottomView];
                    [self setBottomViewFrame];
                    
                    [self setButtonBadgeValue:self.bottomView.cartBtn badgeValue:[NSString stringWithFormat:@"%ld",(long)[GlobalHelper shareInstance].shoppingCartBadgeValue ] badgeOriginX:MaxX(self.bottomView.cartBtn.imageView)-5 badgeOriginY:Y(self.bottomView.cartBtn.imageView)-12];
                    
                   // [self.tableView reloadData];
                }
              
            }else{

                [[GlobalHelper shareInstance] emptyViewNoticeText:@"您浏览的商品已下架, 换一个吧" NoticeImageString:@"下架商品" viewWidth:56*kScale viewHeight:65*kScale UITableView:(UITableView*)self.view isShowBottomBtn:NO bottomBtnTitle:@""];
            }
        [SVProgressHUD dismiss];

        } failureBlock:^(NSError *error) {
            
            [SVProgressHUD dismiss];

        } showHUD:NO];
    [SVProgressHUD show];


}





//
////商品详情事件
//-(void)goodsDetailsBtnAction{
//    isClickGoods = YES;
//    [self.tableView reloadData];
//}
////商品 评价详情事件
//-(void)pingjiaDetailsBtnAction{
//    isClickGoods = NO;
//    [self.tableView reloadData];
//
//}

#pragma mark = 提示

-(void)noticeBtnAvtion{

    
    [self.buyNoticeView showBuyNotice];
    
}


-(void)connectRightItemAction{
   // DLog(@"联系客服");
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"4001106111"];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

#pragma mark=====================链接分享============================

-(void)linkingOfShare{
    
  
    NSArray *titlearr = @[@"",@"微信好友",@"微信朋友圈",@""];
    NSArray *imageArr = @[@"",@"微信",@"朋友圈",@""];
    ActionSheetView *actionsheet  = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"分享至" and:ShowTypeIsShareStyle];
    actionsheet.otherBtnFont = 14.0f;
    actionsheet.otherBtnColor = RGB(51, 51, 51, 1);
    actionsheet.cancelBtnFont = 14.0f;
    actionsheet.cancelBtnColor = RGB(51, 51, 51, 1);
    
    [actionsheet setBtnClick:^(NSInteger btnTag) {
        
        
        if (btnTag ==0) {
        }else if (btnTag ==1){
            //分享到聊天
            [self wxchatWebShare:WXSceneSession];
        }else if (btnTag ==2){
            //分享到朋友圈
            [self wxchatWebShare:WXSceneTimeline];
        }else if (btnTag == 3){
        }
        
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
}

- (UIImage *)handleImageWithURLStr:(NSString *)imageURLStr {
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLStr]];
    NSData *newImageData = imageData;
    // 压缩图片data大小
    newImageData = UIImageJPEGRepresentation([UIImage imageWithData:newImageData scale:0.1], 0.1f);
    UIImage *image = [UIImage imageWithData:newImageData];
    
    // 压缩图片分辨率(因为data压缩到一定程度后，如果图片分辨率不缩小的话还是不行)
    CGSize newSize = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,(NSInteger)newSize.width, (NSInteger)newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

///分享

-(void)wxchatWebShare:(int)scene{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.productTitle;
    message.description = self.productContent;
    
    [message setThumbImage:[self handleImageWithURLStr:self.productImageURL]];
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    if ([self.isShowShareString isEqualToString:@"0"]) {///分销分享
    
        webpageObject.webpageUrl = [NSString stringWithFormat:@"%@/breaf/beef_detail.html?ds=%@&disuid=%@" ,baseUrl,self.detailsId ,self.distributorUid];

    }else{
    ///分享
        webpageObject.webpageUrl = [NSString stringWithFormat:@"%@/breaf/beef_detail.html?ds=%@" ,baseUrl,self.detailsId];
    }
    message.mediaObject = webpageObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
    
}




#pragma ma=====================进入分销平台

-(void)ClickSaleMoneyAction{
    
    [self.actionsheet tappedCancel];

    SaleMoneyViewController *VC = [SaleMoneyViewController new];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark ==================分享

-(void)shareRightItemAction{

    if ([self.isShowShareString isEqualToString:@"0"]) {///分销分享
        
        DLog(@"分销");
        NSArray *titlearr = @[@"",@"链接",@"图片",@""];
        NSArray *imageArr = @[@"",@"链接",@"图片",@""];
        self.actionsheet  = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"分享" and:ShowTypeIsShareStyle];
        self.actionsheet.otherBtnFont = 14.0f;
        self.actionsheet.otherBtnColor = RGB(51, 51, 51, 1);
        self.actionsheet.cancelBtnFont = 14.0f;
        self.actionsheet.cancelBtnColor = RGB(51, 51, 51, 1);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"点我了解赛鲜推手计划" forState:0];
        btn.titleLabel.font = [UIFont systemFontOfSize:12.0f*kScale];
        [btn setTitleColor:RGB(231, 35, 36, 1) forState:0];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.actionsheet addSubview:btn];
        [btn addTarget:self action:@selector(ClickSaleMoneyAction) forControlEvents:1];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(self.actionsheet.mas_bottom).with.offset(-65*kScale);
            make.right.equalTo(self.actionsheet.mas_right).with.offset(-20*kScale);
            make.height.equalTo(@(20*kScale));
            make.width.equalTo(@(140*kScale));
        }];
        
        
        // underline Terms and condidtions
        NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:btn.titleLabel.text];
        
        //设置下划线...
        /*
         NSUnderlineStyleNone                                    = 0x00, 无下划线
         NSUnderlineStyleSingle                                  = 0x01, 单行下划线
         NSUnderlineStyleThick NS_ENUM_AVAILABLE(10_0, 7_0)      = 0x02, 粗的下划线
         NSUnderlineStyleDouble NS_ENUM_AVAILABLE(10_0, 7_0)     = 0x09, 双下划线
         */
        [tncString addAttribute:NSUnderlineStyleAttributeName
                          value:@(NSUnderlineStyleSingle)
                          range:(NSRange){0,[tncString length]}];
        //此时如果设置字体颜色要这样
        //    [tncString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]  range:NSMakeRange(0,[tncString length])];
        
        //设置下划线颜色...
        [tncString addAttribute:NSUnderlineColorAttributeName value:RGB(231, 35, 36, 1) range:(NSRange){0,[tncString length]}];
        [btn setAttributedTitle:tncString forState:UIControlStateNormal];

        
        __weak __typeof(self) weakSelf = self;

        [self.actionsheet setBtnClick:^(NSInteger btnTag) {
            
            if (btnTag ==0) {
                
            }else if (btnTag ==1){
                
                [weakSelf linkingOfShare];//分销链接分享
                
            }else if (btnTag ==2){//分销图片分享
                
                
                SaleShareImageViewController *VC = [SaleShareImageViewController new];
                VC.productTitle = weakSelf.productTitle;
                VC.productContent = self.productContent;
                VC.productImageURL = self.productImageURL;
                VC.detailsId = self.detailsId;
                VC.productPrices = self.productPrices;
                VC.priceTypes = self.priceTypes;
                VC.distributorUid = self.distributorUid;
                
                [self.navigationController pushViewController:VC animated:YES];
                
            }else if (btnTag ==3){
                
            }
            
            
        }];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.actionsheet];
        
        
       

    }else{
//
   // DLog(@"分享");
    NSArray *titlearr = @[@"",@"链接",@"图片",@""];
    NSArray *imageArr = @[@"",@"链接",@"图片",@""];
    ActionSheetView *actionsheet  = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"分享" and:ShowTypeIsShareStyle];
    actionsheet.otherBtnFont = 14.0f;
    actionsheet.otherBtnColor = RGB(51, 51, 51, 1);
    actionsheet.cancelBtnFont = 14.0f;
    actionsheet.cancelBtnColor = RGB(51, 51, 51, 1);
    [actionsheet setBtnClick:^(NSInteger btnTag) {
        
        if (btnTag ==0) {
            
        }else if (btnTag ==1){
            
            [self linkingOfShare];//链接分享
            
        }else if (btnTag ==2){//图片分享
            
            ShareImageViewController *VC = [ShareImageViewController new];
            VC.productTitle = self.productTitle;
            VC.productContent = self.productContent;
            VC.productImageURL = self.productImageURL;
            VC.detailsId = self.detailsId;
            VC.productPrices = self.productPrices;
            VC.priceTypes = self.priceTypes;
            [self.navigationController pushViewController:VC animated:YES];
            
        }else if (btnTag ==3){
            
        }
        
        
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
        
    }
}


-(void)showNavBarItemRight{
    
//
//    if ([self.isShowShareString isEqualToString:@"0"]) {///C端分销
//
//
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"摇2" ofType:@"gif"];
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        UIImage *image = [UIImage sd_animatedGIFWithData:data];
//
//        UIButton *rightKefy = [UIButton buttonWithType:UIButtonTypeCustom];
//        [rightKefy setImage:[UIImage imageNamed:@"kefu"] forState:0];
//        rightKefy.frame = CGRectMake(kWidth-90*kScale, kStatusBarHeight, 40*kScale, 44*kScale);
//        [rightKefy addTarget:self action:@selector(connectRightItemAction) forControlEvents:1];
//
//        [self.view addSubview:rightKefy];
//
//
//
//        UIButton *rightShareImage = [UIButton buttonWithType:UIButtonTypeCustom];
//        [rightShareImage setImage:image forState:0];
//        rightShareImage.frame = CGRectMake(kWidth-45*kScale, kStatusBarHeight+11*kScale, 30*kScale, 22*kScale);
//
//        [rightShareImage addTarget:self action:@selector(shareRightItemAction) forControlEvents:1];
//
//        [self.view addSubview:rightShareImage];
//    }else if ([self.isShowShareString isEqualToString:@"1"]){
        UIBarButtonItem *connectRightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"kefu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]style:UIBarButtonItemStylePlain target:self action:@selector(connectRightItemAction)];
        
        
        UIBarButtonItem *shareRightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"fenxiang"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]style:UIBarButtonItemStylePlain target:self action:@selector(shareRightItemAction)];
        
        
        [self.navBar pushNavigationItem:self.navItem animated:NO];
        [self.navItem setRightBarButtonItems:[NSArray arrayWithObjects:shareRightItem ,connectRightItem, nil]];
        
        
  //  }
    
    

    
}






-(HomePageDetailsBuyNoticeView *)buyNoticeView{
    if (!_buyNoticeView) {
        _buyNoticeView = [[HomePageDetailsBuyNoticeView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight-LL_TabbarSafeBottomMargin)];
        _buyNoticeView.backgroundColor = RGB(0, 0, 0, 0.6);
    }
    return _buyNoticeView;
}

-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kBarHeight, kWidth, kHeight-kBarHeight-49-LL_TabbarSafeBottomMargin) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isClickGoods == NO) {
        return 4;
    }
    return self.detailsDataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isClickGoods == NO) {
        return 220*kScale;
    }
    // 先从缓存中查找图片
    HomePageModel *model = self.detailsDataArray[indexPath.row];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey: model.commodityDetail];
    // 没有找到已下载的图片就使用默认的占位图，当然高度也是默认的高度了，除了高度不固定的文字部分。
    if (!image) {
        
        image = [UIImage imageNamed:@"small_placeholder"];
    }
    //手动计算cell
    CGFloat imgHeight = image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width;
    model.cellHeight = imgHeight;

    return imgHeight;
  
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {

        return self.headViewHeiht;
    }
    return 15;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        
        self.headView = [[HomePageDetailsHeadView alloc] initWithFrame:CGRectMake(0, 0, kWidth, self.headViewHeiht)];
//            [self.headView setSDCycleScrollView:self.bannerDataArray];
        
        
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kWidth, 300*kScale) delegate:self placeholderImage:[UIImage imageNamed:@"商品主图加载"]];   //placeholder
        cycleScrollView.imageURLStringsGroup = self.bannerDataArray;
        cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        cycleScrollView.showPageControl = YES;//是否显示分页控件
        cycleScrollView.currentPageDotColor = [UIColor orangeColor]; // 自定义分页控件小圆标颜色
        [self.headView addSubview:cycleScrollView];
        self.cycleScrollView = cycleScrollView;
        
        
        ///头部赋值
        if (self.headDataArray.count!=0) {
            HomePageModel *model = self.headDataArray[section];
            [self.headView configHeadViewWithModel:model];
        }
       
        ///是否可以查看价格
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        
        if ([[user valueForKey:@"approve"] isEqualToString:@"1"]) {
            
            
        }else if ([[user valueForKey:@"approve"] isEqualToString:@"0"] || [[user valueForKey:@"approve"] isEqualToString:@"2"]){
            ///点击查看价格点击事件
            [self.headView.newspriceBtnLab addTarget:self action:@selector(checkPricesAction) forControlEvents:1];
        }
        
            [self.headView.noticeBtn addTarget:self action:@selector(noticeBtnAvtion) forControlEvents:1];
            
            __weak __typeof(self) weakSelf = self;
            self.headView.changeGoodsDetailsBlock = ^{
                isClickGoods = YES;
                [weakSelf.tableView reloadData];
            };
            
            self.headView.changeCommentDetailsBlock = ^{
                isClickGoods = NO;
                [weakSelf.tableView reloadData];
            };
        

        ///切换规格
        self.headView.returnSelectIndex = ^(NSInteger selectIndex) {
           
            HomePageModel *model = [GlobalHelper shareInstance].specsListMarray[selectIndex];
            weakSelf.detailsId = [NSString stringWithFormat:@"%ld" ,(long)model.commodityId] ;
            weakSelf.fromBaner = @"0"; ///此处不能传sp的ID
            [weakSelf requsetDetailsData];

        };
        self.headView.backgroundColor = [UIColor whiteColor];
        return self.headView;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 15)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.01)];
    view.backgroundColor = RGB(238, 238, 238, 1);
    
    return view;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isClickGoods == NO) {
        
        HomePageCommentDetailsTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"comment_cell"];
        if (cell1 == nil) {
            cell1 = [[HomePageCommentDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"comment_cell"];
            
            //[cell1 setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
            cell1.backgroundColor = [UIColor whiteColor];
           
        
        }
       // [cell1 setGoodsStartArray:[NSMutableArray arrayWithObjects:@"1" ,@"2", nil] andCommentDescImvArray:[NSMutableArray arrayWithObjects:@"1" ,@"2" ,@"3", nil] CommentsLabsMarray:[NSMutableArray arrayWithObjects:@"1" ,@"2", nil]];
        return cell1;
    }else
    {
    HomePageShoppingDetailsTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"shoppingDetails_cell"];
    if (cell1 == nil) {
        cell1 = [[HomePageShoppingDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"shoppingDetails_cell"];
        
        [cell1 setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
        cell1.backgroundColor = [UIColor whiteColor];
        
    }
    if (self.detailsDataArray.count!=0) {
      //  DLog(@"yyyyy== %@" ,self.detailsDataArray);
        HomePageModel *model = self.detailsDataArray[indexPath.row];
        [cell1 configCell:model forIndexPath:indexPath tableView:self.tableView];
    }
    
    return cell1;
    }
}




#pragma mark ==============查看价格

-(void)checkPricesAction{
    
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if ([[user valueForKey:@"isLoginState"] isEqualToString:@"0"]) {
        LoginViewController *VC = [LoginViewController new];
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }else if ([[user valueForKey:@"isLoginState"] isEqualToString:@"1"]){
        
        
        if ([[user valueForKey:@"approve"] isEqualToString:@"0"]) {///认证未通过
            MMPopupItemHandler block = ^(NSInteger index){
                if (index == 0) {
                    NSString *str = [NSString stringWithFormat:@"tel:%@",@"4001106111"];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                    });
                }
            };
            NSArray *items = @[MMItemMake(@"联系客服", MMItemTypeNormal, block) , MMItemMake(@"再等等", MMItemTypeNormal, block)];
            MMMyCustomView *alertView =  [[MMMyCustomView alloc] initWithTitle:@"认证提示" detail:@"您的认证申请还未通过，请耐心等待！\n客服热线：4001106111" items:items];
            
            alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
            
            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleDark;
            
            [alertView show];
            
            
            
        }else  if ([[user valueForKey:@"approve"] isEqualToString:@"2"]) {///未认证
            MMPopupItemHandler block = ^(NSInteger index){
                if (index == 0) {
                    
                    ShopCertificationViewController *VC = [ShopCertificationViewController new];
                    VC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:VC animated:YES];
                }
            };
            NSArray *items = @[MMItemMake(@"去认证", MMItemTypeNormal, block)];
            MMMyCustomView *alertView =  [[MMMyCustomView alloc] initWithTitle:@"认证提示" detail:@"您还未通过商户认证，请先提交认证申请!" items:items];
            
            alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
            
            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleDark;
            
            [alertView show];
            
            
        }
        
    }
    
    
    
}


#pragma mark  = 点击事件


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //隐藏tabBar
    
}

#pragma mark = 底部视图

-(HomePageDetailsBottomView*)bottomView{
    if (!_bottomView) {
        _bottomView = [[HomePageDetailsBottomView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [_bottomView.cartBtn addTarget:self action:@selector(cartBtnAction) forControlEvents:1];
        [_bottomView.addCartBtn addTarget:self action:@selector(addCartBtnAction) forControlEvents:1];
    }
    return _bottomView;
}

#pragma makr = 底部视图frame

-(void)setBottomViewFrame{
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@49);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-LL_TabbarSafeBottomMargin);
        
    }];
}


#pragma mark =购物车

-(void)cartBtnAction{
    
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    if (status == RealStatusNotReachable)
    {
        SVProgressHUD.minimumDismissTimeInterval = 2.0f;
        [SVProgressHUD showErrorWithStatus:@"好像断网了,请检查网络"];
        
    }else{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([[user valueForKey:@"isLoginState"] isEqualToString:@"1"])
    {
        
        ShoppingCartViewController *VC = [ShoppingCartViewController new];
        VC.isShowTabBarBottomView = YES;
        [self.navigationController pushViewController:VC animated:YES];
      
    }else
    {
        LoginViewController *VC = [LoginViewController new];
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
        
  
    }
    }
}

#pragma mark =加入购物车

-(void)addCartBtnAction{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([[user valueForKey:@"isLoginState"] isEqualToString:@"1"])
    {
        if ([self.isShowShareString isEqualToString:@"0"]) {///c端,
            
            //---
            if (self.headDataArray.count != 0) {
                HomePageModel *model = self.headDataArray[0];
                //加入购物车
                [self addCartPostDataWithProductId:model.id];
            }
        }else{
        
        if ([[user valueForKey:@"approve"] isEqualToString:@"0"]) {///认证未通过
            MMPopupItemHandler block = ^(NSInteger index){
                if (index == 0) {
                    NSString *str = [NSString stringWithFormat:@"tel:%@",@"4001106111"];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                    });
                }
            };
            NSArray *items = @[MMItemMake(@"联系客服", MMItemTypeNormal, block) , MMItemMake(@"再等等", MMItemTypeNormal, block)];
            MMMyCustomView *alertView =  [[MMMyCustomView alloc] initWithTitle:@"认证提示" detail:@"您的认证申请还未通过，请耐心等待！\n客服热线：4001106111" items:items];
            
            alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
            
            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleDark;
            
            [alertView show];
            
            
            
        }else  if ([[user valueForKey:@"approve"] isEqualToString:@"2"]) {///未认证
            MMPopupItemHandler block = ^(NSInteger index){

                if (index == 0) {
                    
                    ShopCertificationViewController *VC = [ShopCertificationViewController new];
                    VC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:VC animated:YES];
                }
            };
            NSArray *items = @[MMItemMake(@"去认证", MMItemTypeNormal, block)];
            MMMyCustomView *alertView =  [[MMMyCustomView alloc] initWithTitle:@"认证提示" detail:@"您还未通过商户认证，请先提交认证申请!" items:items];
            
            alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
            
            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleDark;
            
            [alertView show];
            
            
        }else if ([[user valueForKey:@"approve"] isEqualToString:@"1"]){
            
            
            /////
            
            //---
            if (self.headDataArray.count != 0) {
                HomePageModel *model = self.headDataArray[0];
                //加入购物车
                [self addCartPostDataWithProductId:model.id];
            }
         
            
        }
        
        
      
        }
       
    }else
    {
        
        LoginViewController *VC = [LoginViewController new];
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    
  
}



#pragma mark = 加入购物车数据

-(void)addCartPostDataWithProductId:(NSInteger)productId{
    [SVProgressHUD show];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *ticket = [user valueForKey:@"ticket"];
    NSString *secret = @"UHnyKzP5sNmh2EV0Dflgl4VfzbaWc4crQ7JElfw1cuNCbcJUau";
    NSString *nonce = [self ret32bitString];//随机数
    NSString *curTime = [self dateTransformToTimeSp];
    NSString *checkSum = [self sha1:[NSString stringWithFormat:@"%@%@%@" ,secret ,  nonce ,curTime]];
    
    [dic setValue:secret forKey:@"secret"];
    [dic setValue:nonce forKey:@"nonce"];
    [dic setValue:curTime forKey:@"curTime"];
    [dic setValue:checkSum forKey:@"checkSum"];
    [dic setValue:ticket forKey:@"ticket"];
    
#pragma mark---------------------------------需要更改productID--------------------------------
    
    //[dic setObject:[NSString stringWithFormat:@"%ld" ,productId] forKey:@"productId"];
    [dic setValue:[NSString stringWithFormat:@"%ld" ,productId] forKey:@"commodityId"];
    
    [dic setObject:@"1" forKey:@"quatity"];
    [dic setValue:mTypeIOS forKey:@"mtype"];
    
    [dic setValue:[user valueForKey:@"appVersionNumber"] forKey:@"appVersionNumber"];
    [dic setValue:[user valueForKey:@"user"] forKey:@"user"];
    if ([[user valueForKey:@"approve"] isEqualToString:@"0"] || [[user valueForKey:@"approve"] isEqualToString:@"2"]) {
        
        [dic setValue:@"PERSON" forKey:@"showType"];
        
    }else if ([[user valueForKey:@"approve"] isEqualToString:@"1"]){
        
        [dic setValue:@"SOGO" forKey:@"showType"];
        
    }
   // DLog(@"加入购物车 ==== %@" , dic);
    [MHNetworkManager  postReqeustWithURL:[NSString stringWithFormat:@"%@/m/auth/cart/add",baseUrl] params:dic successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"status"] integerValue] == 200) {
       //     SVProgressHUD.minimumDismissTimeInterval = 2;
//            SVProgressHUD.maximumDismissTimeInterval = 2;
//            [SVProgressHUD showSuccessWithStatus:returnData[@"msg"]];
            [SVProgressHUD dismiss];
            
            [GlobalHelper shareInstance].shoppingCartBadgeValue += 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shoppingCart" object:nil userInfo:nil];
            
            [self setButtonBadgeValue:self.bottomView.cartBtn badgeValue:[NSString stringWithFormat:@"%ld",[GlobalHelper shareInstance].shoppingCartBadgeValue ] badgeOriginX:MaxX(self.bottomView.cartBtn.imageView)-5 badgeOriginY:Y(self.bottomView.cartBtn.imageView)-12];
            
            [ShoppingCartTool addToShoppingCartWithGoodsImage:[UIImage imageNamed:@"dingdanxaingqingtu"] startPoint:CGPointMake(self.bottomView.addCartBtn.center.x, kHeight-50) endPoint:CGPointMake(self.bottomView.cartBtn.center.x, kHeight-50) completion:^(BOOL finished) {
                
                
            }];
        }
        else
        {
            SVProgressHUD.minimumDismissTimeInterval = 1;
            SVProgressHUD.maximumDismissTimeInterval = 3;
            [SVProgressHUD showErrorWithStatus:returnData[@"msg"]];
        }
      //  DLog(@"首页加入购物车== id=== %ld  %@" ,productId,returnData);
    } failureBlock:^(NSError *error) {
        
       // DLog(@"首页加入购物车error ========== id= %ld  %@" ,productId,error);
        
    } showHUD:NO];
    
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
