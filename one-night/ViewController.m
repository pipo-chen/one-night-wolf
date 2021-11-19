//
//  ViewController.m
//  one-night
//
//  Created by zihan on 2021/11/16.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>

#define PERSON_HEIGHT 64
#define PERSON_OFFSET 20
#define PLAYER 6
#define TOTAL_CARD 9

@interface ViewController ()<UITextFieldDelegate>

@property(nonatomic, strong) UIImageView *bgImg;

@property(nonatomic, strong) UIButton *retryBtn;

@property(nonatomic, strong) UITextField *answer;

@property(nonatomic, strong) UIButton *person;

@property(nonatomic, strong) NSArray *identities;

@property(nonatomic, strong) NSMutableArray *beforeI;

@property(nonatomic, strong) NSMutableArray *afterI;

@property(nonatomic, strong) NSMutableArray *readyI;

@property(nonatomic, strong) NSMutableArray *pool;

@property(nonatomic, strong) NSMutableArray *sentence;

@property(nonatomic, strong) NSArray *restI;

@property(nonatomic, strong) UIButton *p1;

@property(nonatomic, strong) UIButton *p2;

@property(nonatomic, strong) UIButton *p3;

@property(nonatomic, strong) UIButton *p4;

@property(nonatomic, strong) UIButton *p5;

@property(nonatomic, strong) NSMutableString *logInfo;

//捣蛋鬼会说自己干了啥 强盗是不会说出自己换成狼牌的

@property(nonatomic, assign) NSInteger wolf_change_flag;

@property(nonatomic, assign) NSInteger teeth_change_flag;

@end

@implementation ViewController

#pragma mark - LiftCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self gameStart];
}

#pragma mark - Action

- (void)gameStart {
    self.wolf_change_flag = -1;
    self.teeth_change_flag = -1;
    self.beforeI = [[NSMutableArray alloc] init];
    self.afterI = [[NSMutableArray alloc] init];
    self.readyI = [[NSMutableArray alloc] init];
    self.pool = [[NSMutableArray alloc] init];
    [self configView];
    self.identities = [NSArray arrayWithObjects:@"狼",@"爪牙",@"守夜人",@"守夜人",@"捣蛋鬼",@"酒鬼",@"强盗",@"预言家",@"失眠者",nil];
    
    NSMutableArray *res = [self shuffle];
    [self printCardInfoWithCardOrder:res];
    [self startOperation];
    [self updateView];
}

- (void)selectWolf:(NSString *)number {
    NSInteger num = [number integerValue];
    num -= 1;
    UILabel *result = [[UILabel alloc] init];
    result.font = [UIFont systemFontOfSize:15.];
    result.textColor = [UIColor redColor];
    result.textAlignment = NSTextAlignmentCenter;
    result.numberOfLines = 0;
    [self.view addSubview:result];
    
    UILabel *truth = [[UILabel alloc] init];
    truth.font = [UIFont systemFontOfSize:13.];
    truth.textColor = [UIColor whiteColor];
    truth.numberOfLines = 0;
    truth.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:truth];
    
    [result mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(60);
        make.left.equalTo(self.view.mas_left).offset(PERSON_OFFSET);
        make.right.equalTo(self.view.mas_right).offset(-PERSON_OFFSET);
        make.height.equalTo(@20);
    }];
    
    [truth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(result.mas_bottom);
        make.height.equalTo(@80);
        make.left.right.equalTo(result);
    }];

    BOOL check_result = [self checkWithIndex:num];
    if (check_result) {
        result.text = @"恭喜你，回答正确！";
    } else {
        result.text = @"失败！";
    }
    
    //揭晓答案 在下面放 label
    NSString *person = [self.afterI componentsJoinedByString:@";"];
    NSString *pool_card = [self.pool componentsJoinedByString:@";"];
    NSString *origin = [self.beforeI componentsJoinedByString:@";"];
    truth.text = [NSString stringWithFormat:@"桌面牌：%@ 公共牌：%@ 原始牌: %@",person, pool_card, origin];
    
}

- (BOOL)checkWithIndex: (NSInteger)index {
    
    BOOL inpool = false;
    BOOL flag = false;
    for (int i = 0; i < self.pool.count; i++) {
        if ([self.pool[i] isEqual:@"狼"]) {
            inpool = true;
            break;
        }
    }
    if (index < 0 || index >= PLAYER) {
        if (inpool)
            flag = true;
    } else if (([self.afterI[index] isEqual:@"爪牙"] && inpool) || [self.afterI[index] isEqual:@"狼"]) {
        flag = true;
    }
    return flag;
}

- (void)gameAgain {
    self.answer.text = @"";
    [self gameStart];
}

- (void)startOperation {
    int order[TOTAL_CARD];
    for (int i = 0; i < TOTAL_CARD; i++) {
        order[i] = -1;
    }
    bool flag = false;
    for (int i = 0; i < PLAYER; i++) {
        if ([self.beforeI[i] isEqual:@"预言家"]) {
            order[0] = i;
        }
        if ([self.beforeI[i] isEqual:@"守夜人"]) {
           
            //可能有两个
            if (!flag) {
                order[1] = i;
            } else {
                order[2] = i;
            }
            flag = true;
        }
        if ([self.beforeI[i] isEqual:@"强盗"]) {
            order[3] = i;
        }
        if ([self.beforeI[i] isEqual:@"捣蛋鬼"]) {
            order[4] = i;
        }
        if ([self.beforeI[i] isEqual:@"酒鬼"]) {
            order[5] = i;
        }
        if ([self.beforeI[i] isEqual:@"失眠者"]) {
            order[6] = i;
        }
    }
    //开始根据 order 的顺序 只要前面不是 -1 都可以开始操作
    for (int j = 0; j < TOTAL_CARD; j++) {
        if (order[j] != -1) {
            NSString *sen = [self operationCardWithIndex:order[j]];
            [self.sentence replaceObjectAtIndex:order[j] withObject:sen];
        }
    }
    //狼和爪牙后装
    for (int j = 0; j < PLAYER; j++) {
        if ([self.beforeI[j] isEqual:@"狼"] || [self.beforeI[j] isEqual:@"爪牙"] ) {
            NSString *sen = [self operationCardWithIndex:j];
            [self.sentence replaceObjectAtIndex:j withObject:sen];
        }
    }
    
    for (int i = 0; i < self.sentence.count; i++) {
        //点击触发说话还是直接展示？
        NSLog(self.sentence[i]);
    }
}

//开始进行操作
- (NSString *)operationCardWithIndex:(int)index {

    NSString *identity = self.beforeI[index];
    BOOL fake = false;
    if ([identity isEqual:@"狼"]) {
        fake = true;
        if (self.wolf_change_flag != -1) {
            return [NSString stringWithFormat:@"%d号：入夜之前我是狼，捣蛋鬼说把我跟 %ld号的牌换了，那%ld号现在一定是狼！",index + 1, (long)self.wolf_change_flag + 1,(long)self.wolf_change_flag + 1];
        }
        int num = arc4random() % self.pool.count;
        //狼是从池子里选衣服 不可能遇到同一件衣服的吧
        while ([self.pool[num] isEqual:@"守夜人"]) {
            num = arc4random() % self.pool.count;
        }
        identity = self.pool[num];
        
        [self.logInfo stringByAppendingFormat:@"%d号狼，伪装成%@\n",index + 1,identity];
    }
    
    if ([identity isEqual:@"爪牙"]) {
        //爪牙看自己的牌有无调换
        if (self.wolf_change_flag != -1) {
            return [NSString stringWithFormat:@"%d号：入夜之前我是爪牙，捣蛋鬼说把我跟 %ld号的牌换了，那%ld号现在一定是爪牙！",index + 1, (long)self.teeth_change_flag + 1,(long)self.teeth_change_flag + 1];
        }
        //爪牙跳守夜人 那就选一个 狼当它的同伴
        
        fake = true;
        int num = arc4random() % self.readyI.count;

        while ([self.readyI[num] isEqual:@"守夜人"]) {
            num = arc4random() % self.readyI.count;
        }
        identity = self.readyI[num];
        [self.logInfo stringByAppendingFormat:@"%d号爪牙，伪装成%@\n",index + 1,identity];
    }
    
    NSMutableString *op_res = [NSMutableString stringWithFormat:@" %d号：我是%@,",index + 1,identity];
    [self.readyI addObject:identity];
    
    if ([identity isEqual:@"守夜人"]) {
        //告知他有没有看到对方 寻找数组
        for (int i = 0; i < PLAYER; i++) {
            NSString *find = self.beforeI[i];
            if (i != index && [find isEqual:@"守夜人"]) {
                return [op_res stringByAppendingString:[NSString stringWithFormat:@"我昨晚醒来看到我的同伴是 %d号",i + 1]] ;
            }
        }
        return [op_res stringByAppendingString:@"我昨晚没有看到我的同伴"];
    }
    
    if ([identity isEqual:@"预言家"]) {
        if (fake) {
            //就从ready里面随机一个
            if (self.readyI.count > 0) {
                int check = arc4random() % self.readyI.count;
                //从 ready 里面挑出了一个身份
                for (int i = 0; i < PLAYER; i++) {
                    if ([self.beforeI[i] isEqual:self.readyI[check]]) {
                        check = i;
                    }
                }
                if ([self.beforeI[check] isEqual:@"预言家"]) {
                    //随机生成一个非预言家
                    return [op_res stringByAppendingString:[NSString stringWithFormat:@"我昨晚验的是 %d号，他的身份是%@",check + 1, self.beforeI[index]]];
                }
                return [op_res stringByAppendingString:[NSString stringWithFormat:@"我昨晚验的是 %d号，他的身份是%@",check + 1, self.beforeI[check]]];
            }
        } else {
            //随机生成一个数
            int check = index;
            while (check == index) {
                check = arc4random() % PLAYER;
            }
            NSString *check_identity = self.afterI[check];
            return [op_res stringByAppendingString:[NSString stringWithFormat:@"我昨晚验的是 %d号，他的身份是%@",check + 1, check_identity]];
        }
    }
    
    if ([identity isEqual:@"捣蛋鬼"]) {
       
        //选择出自己之外的两张牌进行交换
        int num1 = index, num2 = index;
        while (num1 == index) {
            num1 = arc4random() % PLAYER;
        }
        while (num2 == index || num2 == num1) {
            num2 = arc4random() % PLAYER;
        }
        if (fake) {
            return [op_res stringByAppendingString: [NSString stringWithFormat:@"我昨天把 %d号和 %d号两张牌交换了",num1 + 1, num2 + 1]];
        }
        //开始交换这两张牌
        [self.afterI exchangeObjectAtIndex:num1 withObjectAtIndex:num2];
        //判断这两个里面有无狼
        if ([self.beforeI[num1] isEqual:@"狼"]) {
            self.wolf_change_flag = num2;
        } else if ([self.beforeI[num2] isEqual:@"狼"]) {
            self.wolf_change_flag = num1;
        }
        //是否有爪牙
        if ([self.beforeI[num1] isEqual:@"爪牙"]) {
            self.teeth_change_flag = num2;
        } else if ([self.beforeI[num2] isEqual:@"爪牙"]) {
            self.teeth_change_flag = num1;
        }
        
        return [op_res stringByAppendingString: [NSString stringWithFormat:@"我昨天把 %d号和 %d号两张牌交换了",num1 + 1, num2 + 1]];
    }
    
    //如果是交换的狼牌，则从已知的身份中去挖掘
    if ([identity isEqual:@"强盗"]) {
        NSString *op = @"";
        
        if (fake) {
            
            int num = arc4random() % self.readyI.count;
            // ready里面一定不会有狼的 所以放心用 强盗 和 失眠者 都不要动
            if ([self.readyI[num] isEqual:@"强盗"] || [self.readyI[num] isEqual:@"失眠者"]) {
                //把自己的身份给别人
                op = [NSString stringWithFormat:@"交换的是：%d号的牌，身份为：%@", num + 1, self.beforeI[index]];
            } else {
                for (int i = 0; i < PLAYER; i++) {
                    if ([self.readyI[num] isEqual:self.beforeI[i]]) {
                        num = i;
                    }
                }
                op = [NSString stringWithFormat:@"交换的是：%d号的牌，身份为：%@", num + 1, self.beforeI[num]];
            }
            
        } else {
            int num = index;
            while (num == index) {
                num = arc4random() % PLAYER;
            }
            //交换自己和对方的牌
            NSString *temp = self.afterI[num];
            [self.afterI exchangeObjectAtIndex:num withObjectAtIndex:index];
            
            op = [NSString stringWithFormat:@"交换的是：%d号的牌，身份为：%@", num + 1, temp];
            
            if ([temp isEqual: @"狼"] || [temp isEqual:@"爪牙"]) {
                //隐藏自己的身份 得从已经得知的信息中获取
                int change = index;
                NSString *change_iden;
                //反之 就只能瞎猜？或者装一个身份？
                if(self.readyI.count > 0) {
                    while (change == index) {
                        //如果ready里面信息为空
                        change = arc4random() % (self.readyI.count);
                    }
                    change_iden = self.readyI[change];
                }
                op = [NSString stringWithFormat:@"交换的是：%d号的牌，身份为：%@",change + 1, change_iden];
                [self.logInfo stringByAppendingString:[NSString stringWithFormat:@"%d 号强盗交换了 %d号的牌发现对方是%@，于是称%@",index + 1, num + 1,temp,op]];
            }
        }
        return [op_res stringByAppendingString:op];
    }
    
    //在池子里面换 同时不知道自己换上来的是啥牌
    if ([identity isEqual:@"酒鬼"]) {
        if (fake) {
            return [op_res stringByAppendingString:@"我自己也不知道自己现在是什么身份"];
        }
        //随机从池子里挑一个
        int change = arc4random() % self.pool.count;
        
        self.afterI[index] = self.pool[change];
        self.pool[change] = identity;
        
        [self.logInfo stringByAppendingString:[NSString stringWithFormat:@"%d 号从池子里捞出一张%@牌换上\n",index + 1, self.afterI[index]]];
        return [op_res stringByAppendingString:@"我自己也不知道自己现在是什么身份"];
    }
    
    if ([identity isEqual:@"失眠者"]) {
        NSString *weak = self.afterI[index];
        
        //如果看到自己是狼或者爪牙,就随便说自己的身份变或没变
        if ([weak isEqual:@"狼"] || [weak isEqual:@"爪牙"]) {
            //变成随机的一张牌
            int num = arc4random() % self.readyI.count;
            while ([self.readyI[num] isEqual:@"捣蛋鬼"]) {
                num = arc4random() % self.readyI.count;
            }
            weak = self.readyI[num];
            //随机的一个身份 但是绝对不可能是捣蛋鬼
        }
        
        [self.logInfo stringByAppendingString:[NSString stringWithFormat:@"%d 号失眠者醒来牌变成了%@\n",index + 1, weak]];
        
        NSString *op = @"";
        if ([weak isEqual:@"失眠者"]) {
            op = @"醒来看过我的牌没变\n";
        } else {
            op = [NSString stringWithFormat:@"醒来看过我的牌是：%@",weak];
        }
        
        return [op_res stringByAppendingString:op];
    }
    
    return @"";
}

- (void)printCardInfoWithCardOrder:(NSMutableArray *)order {
    
    self.logInfo = [NSMutableString stringWithFormat:@"发牌时各玩家卡片信息："];
    
    for (int i = 0; i < PLAYER; i++) {
        int index = [order[i] intValue];
        NSString *identity = [self.identities objectAtIndex: index];
        NSString *s = [NSString stringWithFormat: @"%d号玩家抽取:%@",i+1, identity];
        [self.beforeI addObject:identity];
        [self.logInfo appendString:s];
    }
    self.afterI = [NSMutableArray arrayWithArray:self.beforeI];
}

- (NSMutableArray *)shuffle {
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:PLAYER];
    
    int bucket[TOTAL_CARD];
    for(int i = 0; i < TOTAL_CARD; i++) {
        bucket[i] = 1;
    }
    
    int i = 0;
    while (i < PLAYER) {
        //生成一个数并判断是否已经生成过
        int index = arc4random() % TOTAL_CARD;
        if (bucket[index] != 0) {
            [res addObject:@(index)];
            bucket[index] = 0;
            i++;
        }
    }
    //剩余这里面为 1 的卡片放池子里
    for (int j = 0; j < TOTAL_CARD; j++) {
        if (bucket[j] != 0) {
            //找到 j 位置对应的角色
            [self.pool addObject:self.identities[j]];
        }
    }
    return res;
}

#pragma mark - ConfigView

- (void)configView {
    [self.view addSubview:self.bgImg];
    [self.view addSubview:self.answer];
    [self.view addSubview:self.retryBtn];
    
    [self.bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.right.equalTo(self.view);
    }];
    [self.answer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-100);
        make.left.equalTo(self.view.mas_left).offset(PERSON_OFFSET);
        make.height.equalTo(@40);
    }];
    
    [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-PERSON_OFFSET);
        make.top.equalTo(self.answer);
        make.bottom.equalTo(self.answer);
        make.width.equalTo(self.answer);
    }];
}

- (void)updateView {
    
    int y = 30;
    
    for (int i = 0; i < PLAYER; i++) {
        int margin_x = PERSON_OFFSET;
        int margin_y = y * (i + 1) + i * PERSON_HEIGHT + 140;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(margin_x, margin_y, PERSON_HEIGHT, PERSON_HEIGHT)];
        btn.layer.cornerRadius = btn.frame.size.width/2;
        btn.clipsToBounds = YES;
        NSString *name = [NSString stringWithFormat:@"p%d",i + 1];
        [btn setBackgroundImage:[UIImage imageNamed:name] forState: UIControlStateNormal];
        
        UIImageView *chatView = [[UIImageView alloc] initWithFrame:CGRectMake(margin_x + PERSON_HEIGHT, margin_y, self.view.frame.size.width - margin_x * 2 - PERSON_HEIGHT, PERSON_HEIGHT)];
        
        [chatView setImage:[UIImage imageNamed:@"chat"]];
        [self.view addSubview:chatView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - margin_x * 2 - PERSON_HEIGHT - 20, PERSON_HEIGHT)];
        label.font = [UIFont systemFontOfSize:15.];
        label.text = self.sentence[i];
        label.textColor = [UIColor whiteColor];
        
        label.numberOfLines = 0;
        
        [chatView addSubview:label];
        
        btn.backgroundColor = [UIColor redColor];
        [self.view addSubview:btn];
    }
    
}

#pragma mark - Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   
    return YES;
}

- (void)returnClick {
    [self.view endEditing:YES];
    //这里是答案
    NSString *answer = self.answer.text;
    [self selectWolf: answer];
}

#pragma mark - Accessor

- (NSMutableArray *)readyI {
    if (!_readyI) {
        _readyI = [NSMutableArray arrayWithCapacity:PLAYER];
    }
    return _readyI;
}

- (NSMutableArray *)beforeI {
    if (!_beforeI) {
        _beforeI = [NSMutableArray arrayWithCapacity:PLAYER];
    }
    return _beforeI;
}

- (NSMutableArray *)afterI {
    if (!_afterI) {
        _afterI = [NSMutableArray arrayWithCapacity:PLAYER];
    }
    return _afterI;
}

- (NSMutableArray *)sentence {
    if (!_sentence) {
        _sentence = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"", nil];
    }
    return _sentence;
}

- (NSMutableArray *)pool {
    if (!_pool) {
        _pool = [NSMutableArray arrayWithCapacity:TOTAL_CARD - PLAYER];
    }
    return _pool;
}

- (UIImageView *)bgImg {
    if (!_bgImg) {
        _bgImg = [[UIImageView alloc] init];
        [_bgImg setImage:[UIImage imageNamed:@"bg"]];
        _bgImg.contentMode = UIViewContentModeScaleAspectFill;
        _bgImg.userInteractionEnabled = true;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnClick)];
        [_bgImg addGestureRecognizer:tap];
        
    }
    return _bgImg;
}

- (UITextField *)answer {
    if (!_answer) {
        _answer = [[UITextField alloc] init];
        _answer.borderStyle = UITextBorderStyleRoundedRect;
        _answer.placeholder = @"ENTER WOLF";
        _answer.delegate = self;
        _answer.keyboardType = UIKeyboardTypeNumberPad;
        _answer.returnKeyType = UIReturnKeyDone;
    }
    return _answer;
}

- (UIButton *)retryBtn {
    if (!_retryBtn) {
        _retryBtn = [[UIButton alloc] init];
        [_retryBtn setTitle:@"AGAIN" forState:UIControlStateNormal];
        _retryBtn.layer.cornerRadius = 5;
        _retryBtn.backgroundColor = [UIColor redColor];
        [_retryBtn addTarget:self action:@selector(gameAgain) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryBtn;
}
@end
