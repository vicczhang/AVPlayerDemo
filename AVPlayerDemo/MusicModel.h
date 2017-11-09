//
//  MusicModel.h
//  AVPlayerDemo
//
//  Created by vicczhang on 2017/11/9.
//  Copyright © 2017年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicModel : NSObject
@property (nonatomic, strong)NSString* musicURL;

@property (nonatomic, strong)NSString* cover;
@property (nonatomic, strong)NSString* author;
@property (nonatomic, strong)NSString* musicName;

@end
