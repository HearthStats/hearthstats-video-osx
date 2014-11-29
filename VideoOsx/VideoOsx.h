//
//  VideoOsx.h
//  VideoOsx
//
//  Copyright (c) 2014 Charles Gutjahr. See README.md for license details.
//

#import <Foundation/Foundation.h>

// Forward declaration avoids header recursion
@class HearthstoneRecorder;

@interface VideoOsx : NSObject

@property (strong) HearthstoneRecorder *hearthstoneRecorder;

- (NSInteger)findProgramPid;

- (NSString*)getHSWindowBounds;

- (id)startVideo;

- (NSString*)stopVideo;

@end
