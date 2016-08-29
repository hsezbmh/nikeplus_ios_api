//
//  Auth.m
//  AroundTheEarth
//
//  Created by christbao on 16/5/19.
//  Copyright © 2016年 christbao. All rights reserved.
//

#import "Auth.h"

@implementation Auth

-(void)requestFinished:(QALHttpRequest *)request
{
    
}

-(void)requestFailed:(int)errCode andErrMsg:(NSString *)errMsg
{
    NSLog(@"Auth Fail,errCode:%i,errMsg:%@",errCode,errMsg);
}

@end
