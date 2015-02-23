//
//  GCSDataManager.m
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import "GCSDataManager.h"
#import "GCSCraftModelGenerator.h"
#import "GCSSettings.h"
#import "FileUtils.h"



@implementation GCSDataManager

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _craft = [GCSCraftModelGenerator createInitialModel];
        _lastViewedMapCamera = nil;
       [self loadArchives];
    }
    return self;
}

- (void)loadArchives {
    NSData *decodedData = [NSData dataWithContentsOfFile:[GCSDataManager filePath]];
    GCSSettings *progData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    if (progData) {
        _gcsSettings = progData;
    } else {
        _gcsSettings = [[GCSSettings alloc] init];
    }
}


+ (void) save {
    NSData* encodeData = [NSKeyedArchiver archivedDataWithRootObject:[GCSDataManager sharedInstance].gcsSettings];
    [encodeData writeToFile:[GCSDataManager filePath] atomically:YES];
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[FileUtils URLToFileInDocumentsDirWithFileName:@"GCSSettings"] path];
    }
    return filePath;
}

@end
