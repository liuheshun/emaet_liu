//
//  HomePageCommentDetailsTableViewCell.m
//  Emeat
//
//  Created by liuheshun on 2017/11/21.
//  Copyright © 2017年 liuheshun. All rights reserved.
//

#import "HomePageCommentDetailsTableViewCell.h"

@implementation HomePageCommentDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
    }
    return self;
}




-(void)setGoodsStartArray:(NSMutableArray*)goodsStatArray andCommentDescImvArray:(NSMutableArray*)descImvArray CommentsLabsMarray:(NSMutableArray*)commentsLabsMarray ConfigWithConmmentsModel:(HomePageCommentsModel*)commentsModel{

    self.commentUserImv = [[UIImageView alloc] init];
    self.commentUserImv.layer.masksToBounds = YES;
    self.commentUserImv.layer.cornerRadius = 35*kScale/2;
    [self addSubview:self.commentUserImv];
    
    [self.commentUserImv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(15*kScale);
        make.top.equalTo(self.mas_top).with.offset(20*kScale);
        make.height.equalTo(@(35*kScale));
        make.width.equalTo(@(35*kScale));
    }];

    _commentNameLab = [[UILabel alloc] init];
    _commentNameLab.font = [UIFont systemFontOfSize:12.0f*kScale];
    [self addSubview:_commentNameLab];
    [self.commentNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.commentUserImv.mas_right).with.offset(5*kScale);
        make.top.equalTo(self.commentUserImv);
        make.height.equalTo(@(12*kScale));
        make.width.equalTo(@(50*kScale));
    }];
    _commentTimeLab = [[UILabel alloc] init];
    _commentTimeLab.font = [UIFont systemFontOfSize:12.0f*kScale];
    _commentTimeLab.textColor = RGB(136, 136, 136, 1);
    [self addSubview:_commentTimeLab];
    [self.commentTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.commentNameLab.mas_right).with.offset(10*kScale);
        make.top.equalTo(self.commentUserImv);
        make.height.equalTo(@(12*kScale));
        make.width.equalTo(@(120*kScale));
    }];

    _goodsLab = [[UILabel alloc] init];
    _goodsLab.font = [UIFont systemFontOfSize:12.0f*kScale];
    _goodsLab.textColor = RGB(136, 136, 136, 1);
    [self addSubview:_goodsLab];
    [self.goodsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.commentNameLab);
        make.top.equalTo(self.commentNameLab.mas_bottom).with.offset(10*kScale);
        make.height.equalTo(@(12*kScale));
        make.width.equalTo(@(35*kScale));
    }];


    for (int i = 0; i < 5; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i < goodsStatArray.count) {
            [btn setImage:[UIImage imageNamed:@"haoping"] forState:0];

        }else{
        [btn setImage:[UIImage imageNamed:@"pingjia"] forState:0];
        }
        [self addSubview:btn];
        self.goodsStarBtn = btn;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.goodsLab.mas_right).with.offset(5*kScale+20*i*kScale);
            make.top.equalTo(self.goodsLab).with.offset(0);
            make.width.and.height.equalTo(@(15*kScale));
        }];
        
        
    }

//    _sendLab = [[UILabel alloc] init];
//    _sendLab.font = [UIFont systemFontOfSize:12.0f];
//    _sendLab.textColor = RGB(136, 136, 136, 1);
//    [self addSubview:_sendLab];
//    [self.sendLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.goodsStarBtn.mas_right).with.offset(10);
//        make.top.equalTo(self.goodsStarBtn);
//        make.width.equalTo(@35);
//        make.height.equalTo(@12);
//    }];
//
//    for (int i = 0; i < 5; i++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        //btn.frame = CGRectMake(MaxX(self.sendLab)+5 +20*i, Y(self.goodsLab), 15*kScale, 15*kScale);
//        //btn.backgroundColor = [UIColor redColor];
//        if (i < sendStarArray.count) {
//            [btn setImage:[UIImage imageNamed:@"haoping"] forState:0];
//
//        }else{
//            [btn setImage:[UIImage imageNamed:@"pingjia"] forState:0];
//        }
//        [self addSubview:btn];
//        self.sendStarBtn = btn;
//
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.sendLab.mas_right).with.offset(5+20*i);
//            make.top.equalTo(self.goodsLab);
//            make.width.and.height.equalTo(@15);
//        }];
//
//    }

    for (int i= 0; i<commentsLabsMarray.count; i++) {
        
            UIButton *commentsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            commentsBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f*kScale];
            [commentsBtn setTitle:commentsLabsMarray[i] forState:0];

        [self addSubview:commentsBtn];
        commentsBtn.backgroundColor = RGB(251,100,35, 1);
        commentsBtn.selected = YES;
        
        [commentsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
            if (i < 4) {
                    make.top.equalTo(self.commentUserImv.mas_bottom).with.offset(10*kScale);
                    make.width.equalTo(@(65*kScale)); make.left.equalTo(self.mas_left).with.offset((15*kScale + 75*kScale * i));
                    
                    
                }else{
                    make.top.equalTo(self.commentUserImv.mas_bottom).with.offset(40*kScale);
                    make.width.equalTo(@(65*kScale)); make.left.equalTo(self.mas_left).with.offset((15*kScale + 75*kScale * (i-4)));
                    
                }
                
                
                make.height.equalTo(@(20*kScale));
                
                commentsBtn.tag = i;
                self.commentsLabBtn = commentsBtn;
            }];
        
        
    }
    
    
    
    _commentDetailsLab = [[UILabel alloc] init];
    _commentDetailsLab.font = [UIFont systemFontOfSize:12.0f*kScale];
    _commentDetailsLab.textColor = RGB(51, 51, 51, 1);
    _commentDetailsLab.numberOfLines = 0;
    [self addSubview:_commentDetailsLab];
    [self.commentDetailsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.commentUserImv);
        make.top.equalTo(self.commentsLabBtn.mas_bottom).with.offset(10*kScale);
        make.width.equalTo(@(kWidth-30*kScale));
        make.height.equalTo(@(40*kScale));
    }];
    
    __block UIView *lastView = nil;

    for (int i = 0; i < descImvArray.count; i ++) {
        UIImageView *imv = [[UIImageView alloc] init];
        imv.backgroundColor = [UIColor redColor];
        [self addSubview:imv];


        [imv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@100);
            make.width.equalTo(@100);
            make.top.equalTo(self.commentDetailsLab.mas_bottom).with.offset(15);
            if (i == 0) {
                make.left.equalTo(self.mas_left).with.offset(15);
            }else{
                make.left.equalTo(lastView.mas_right).with.offset(15);
            }
        }];

        self.commentDescImv = imv;
        lastView = imv;
    }


    _commentUserImv.backgroundColor = [UIColor redColor];
    _commentNameLab.text = @"黎明";
    _commentTimeLab.text = @"2015.02.23";
    _goodsLab.text = @"商品 :";
    _sendLab.text = @"配送 :";
    _commentDetailsLab.text = @"淑芬而热额热 而热热热 热而而而润肤乳 而呃呃呃呃,十多个热热热二个人让他忽然听到, 而扔个热热隔热管";
    
    
}







@end
