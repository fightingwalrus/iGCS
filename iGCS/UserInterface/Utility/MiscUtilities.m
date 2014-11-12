//
//  MiscUtilities.m
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import "MiscUtilities.h"

@implementation MiscUtilities

// Determine size of text
//  - can't safely use [label sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_LARGE]] in background threads
+ (float) getTextWidth:(NSString*)label withContext:(CGContextRef)ctx {
    CGContextSetTextDrawingMode(ctx, kCGTextInvisible);
    CGContextSetTextPosition(ctx, 0, 0);
    CGContextShowText(ctx, [label cStringUsingEncoding:NSASCIIStringEncoding], [label length]);
    CGPoint newPos = CGContextGetTextPosition(ctx);
    return newPos.x;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize rotation:(double)ang {
    UIGraphicsBeginImageContext( newSize );
    //[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, newSize.width/2, newSize.height/2);
    transform = CGAffineTransformRotate(transform, ang);
    CGContextConcatCTM(context, transform);
    
    [image drawInRect:CGRectMake(-newSize.width/2,-newSize.width/2,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// ref: http://coffeeshopped.com/2010/09/iphone-how-to-dynamically-color-a-uiimage
+ (UIImage *)image:(UIImage*)img withColor:(UIColor*)color {
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // Set a mask that matches the shape of the image, then draw as black
    [[UIColor blackColor] setFill];
    CGContextSetBlendMode(context, kCGBlendModeDarken);
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // Now replace with the desired color
    [color setFill];
    CGContextSetBlendMode(context, kCGBlendModeLighten);
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}


// ref: http://stackoverflow.com/questions/990976/how-to-create-a-colored-1x1-uiimage-on-the-iphone-dynamically
+ (UIImage*) imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString*) prettyPrintCoordAxis:(float)val as:(GCSGeoCoord)eLatLong {
    char letter = (val > 0) ? 'E' : 'W';
    if (eLatLong == GCSLatitude) {
        letter = (val > 0) ? 'N' : 'S';
    }
    
    val = fabs(val);
    
    NSInteger deg = (NSInteger)val;
    val = (val - deg) * 60;
    
    NSInteger min = (NSInteger)val;
    float sec = (val - min) * 60;
    
    return [NSString stringWithFormat:@"%02d° %02d' %02.2f%c", deg, min, sec, letter];
}

// works on iOS 2.0+, could replace with NSUUID if we ever drop iOS 5.x support
+ (NSString *)UUIDUsingDefaultAllocator {
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuidstring = CFUUIDCreateString(kCFAllocatorDefault, cfuuid);
    CFRelease(cfuuid);
    return (__bridge_transfer NSString *)cfuuidstring;
}

@end
