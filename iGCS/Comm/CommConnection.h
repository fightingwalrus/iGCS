//
//  CommConnection.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

@class CommInterface;

@interface CommConnection : NSObject

@property (strong) CommInterface *source;
@property (strong) CommInterface *destination;

+(CommConnection*)createForSource:(CommInterface*)source destination:(CommInterface*)destination;

@end
