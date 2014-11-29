//
//  VideoOsx.m
//  VideoOsx
//
//  Copyright (c) 2014 Charles Gutjahr. See LICENSE file for license details.
//

#import "VideoOsx.h"
#import "VideoOsx-Swift.h"

@implementation VideoOsx

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hearthstoneRecorder = [HearthstoneRecorder new];
    }
    return self;
}

- (NSInteger)findProgramPid {
    return self.hearthstoneRecorder.findPid;
}

- (NSString*)getHSWindowBounds {
    return self.hearthstoneRecorder.getHSWindowBounds;
}

- (id)startVideo {
    self.hearthstoneRecorder = [[HearthstoneRecorder alloc] init];
    [self.hearthstoneRecorder findPid];
    [self.hearthstoneRecorder getHSWindowBounds];
    [self.hearthstoneRecorder startRecording];
    return self;
}

- (NSString*)stopVideo {
    return [self.hearthstoneRecorder stopRecording];
}

@end
