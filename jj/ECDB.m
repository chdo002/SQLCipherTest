//
//  ECDB.m
//  jj
//
//  Created by chdo on 2018/5/29.
//  Copyright © 2018年 aat. All rights reserved.
//

#import "ECDB.h"
#import "FMDatabase.h"
#import <SQLCipher/sqlite3.h>

@interface ECDB()
{
    void*               _db;
    BOOL                _isExecutingStatement;
    NSTimeInterval      _startBusyRetryTime;
    
    NSMutableSet        *_openResultSets;
    NSMutableSet        *_openFunctions;
    
    NSDateFormatter     *_dateFormat;
}
@end
@implementation ECDB
    
-(BOOL)open{
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open([self sqlitePath], (sqlite3**)&_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    }
    [self setKey:@""];
    if (self.maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:self.maxBusyRetryTimeInterval];
    }
    
    
    return YES;
}
    
- (BOOL)openWithFlags:(int)flags vfs:(NSString *)vfsName {
#if SQLITE_VERSION_NUMBER >= 3005000
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open_v2([self sqlitePath], (sqlite3**)&_db, flags, [vfsName UTF8String]);
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    }
    
    if (self.maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:self.maxBusyRetryTimeInterval];
    }
    
    return YES;
#else
    NSLog(@"openWithFlags requires SQLite 3.5");
    return NO;
#endif
}
    
- (const char*)sqlitePath {
    
    if (!self.databasePath) {
        return ":memory:";
    }
    
    if ([self.databasePath length] == 0) {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    
    return [self.databasePath fileSystemRepresentation];
    
}
@end
