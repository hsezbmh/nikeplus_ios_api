//
//  ViewController.m
//  AroundTheEarth
//
//  Created by christbao on 16/5/19.
//  Copyright © 2016年 christbao. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *Distance;
@property (weak, nonatomic) IBOutlet UITextField *DaysLeft;
@property (weak, nonatomic) IBOutlet UITextField *DailyDistance;
@property (weak, nonatomic) IBOutlet UIImageView *HeadImage;
@property (weak, nonatomic) IBOutlet UITextField *Progress;
@property (weak, nonatomic) IBOutlet UITextField *Finished;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.HeadImage setContentMode:UIViewContentModeScaleToFill];
    self.HeadImage.frame = CGRectMake(0,0,100,100);
    //afnetworking test
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    //session.responseSerializer = [AFJSONRequestSerializer serializer];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = @"";
    params[@"password"] = @"";
    
    NSLog(@"开始请求");
    [session POST:@"https://developer.nike.com/services/login" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:\n%@",responseObject);
        NSDictionary* resp = responseObject;
        NSString* access_token = [resp objectForKey:@"access_token"];
        int expires_in = [[resp objectForKey:@"expires_in"] intValue];
//替换一个大图，目前只发现200x200的
        NSString* image_url = [resp objectForKey:@"profile_img_url"];
        image_url = [image_url substringToIndex:[image_url length] - 7];
        image_url = [NSString stringWithFormat:@"%@200.jpg",image_url];
        NSLog(@"new_url:%@",image_url);
        NSURL* head_url = [[NSURL alloc] initWithString:image_url];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
        self.HeadImage.image = [UIImage imageWithData:imageData];
        NSString* getDistanceUrl = [NSString stringWithFormat:@"https://api.nike.com/v1/me/sport?access_token=%@",access_token];
        //开始拉取数据
        {
            AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
            //session.responseSerializer = [AFJSONRequestSerializer serializer];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [session GET:getDistanceUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSMutableDictionary* jsonObj = responseObject;
                NSMutableArray* summaries = [jsonObj objectForKey:@"summaries"];
                for(unsigned int i = 0 ; i < [summaries count] ; i++)
                {
                    NSMutableDictionary* detail = [summaries objectAtIndex:i];
                    if (![[detail objectForKey:@"experienceType"] isEqualToString: @"RUNNING"]) {
                        continue;
                    }
                    NSMutableArray* runningdetail = [detail objectForKey:@"records"];
                    for(unsigned int j = 0 ; j < [runningdetail count] ; j++)
                    {
                        if ([[[runningdetail objectAtIndex:j] objectForKey:@"recordType"] isEqualToString:@"LIFETIMEDISTANCE"])
                        {
                            self.Finished.text = [NSString stringWithFormat:@"已完成%0.2f公里",[[[runningdetail objectAtIndex:j] objectForKey:@"recordValue"] floatValue]];
                            float distanceLeft = 40000 - [[[runningdetail objectAtIndex:j] objectForKey:@"recordValue"] floatValue];
                            self.Distance.text = [NSString stringWithFormat:@"剩余%0.2f公里",distanceLeft];
                            NSLog(@"distance:%@",self.Distance.text);
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            NSTimeZone *timeZone = [NSTimeZone localTimeZone];
                            [formatter setTimeZone:timeZone];
                            [formatter setDateFormat : @"M/d/yyyy"];
                            NSString *stringTime = @"12/31/2035";
                            NSDate *end = [formatter dateFromString:stringTime];
                            NSDate *now = [NSDate date];
                            NSLog(@"%@|%@",now,end);
                            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
                            unsigned int unitFlag = NSCalendarUnitDay;
                            NSDateComponents *components = [calendar components:unitFlag fromDate:now toDate:end options:0];
                            int days = (int)([components day] + 2);
                            self.DaysLeft.text = [NSString stringWithFormat:@"剩余%d天",days];
                            float dailyDistance = (float) distanceLeft / days;
                            self.DailyDistance.text = [NSString stringWithFormat:@"平均每天跑%0.2f公里",dailyDistance];
                            float percentage = (40000 - distanceLeft) / 40000 * 100 ;
                            self.Progress.text = [NSString stringWithFormat:@"进度：%0.2f%@",percentage,@"%"];
                        }
                    }
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"请求失败");
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
