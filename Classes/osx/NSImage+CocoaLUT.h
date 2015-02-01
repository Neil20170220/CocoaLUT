//
//  NSImage+CocoaLUT.h
//  Pods
//
//  Created by Greg Cotten on 1/30/15.
//
//

#import <Cocoa/Cocoa.h>

@interface NSImage (CocoaLUT)

-(instancetype)cocoaLUT_imageWithDeviceRGBColorspace;

-(CGColorSpaceRef)cocoaLUT_cgColorSpaceRef;

- (NSImage *)cocoalut_imageByPreservingEmbeddedColorSpace:(BOOL)preserveEmbeddedColorSpace;

@end
