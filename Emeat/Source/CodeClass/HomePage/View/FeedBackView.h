//
//  FeedBackView.h
//  Emeat
//
//  Created by liuheshun on 2018/8/8.
//  Copyright © 2018年 liuheshun. All rights reserved.
//

#import "MMPopupView.h"

@interface FeedBackView : UIView<UITextViewDelegate>

///
@property (nonatomic,strong) UIButton *titleLabBtn;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIButton *submitBtn;
@property (nonatomic,strong) UIButton *cancelBtn;




@end
