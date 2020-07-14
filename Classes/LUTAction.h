//
//  LUTAction.h
//  Lattice
//
//  Created by Greg Cotten on 6/19/14.
//  Copyright (c) 2014 Wil Gieseler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLUT.h"
#import "LUTColorSpace.h"
#import <M13OrderedDictionary/M13OrderedDictionary.h>

@interface LUTAction : NSObject <NSCopying>

@property (copy) LUT* (^actionBlock)(LUT*);
@property (strong) NSString *actionName;
@property (strong) M13OrderedDictionary *actionMetadata;


+(instancetype)actionWithBlock:(LUT *(^)(LUT *lut))actionBlock
                    actionName:(NSString *)actionName
                actionMetadata:(M13OrderedDictionary *)metadata;

+(instancetype)actionWithBypassBlockWithName:(NSString *)actionName;

-(LUT *)LUTByUsingActionBlockOnLUT:(LUT *)lut;

-(NSString *)actionDetails;

+(instancetype)actionWithLUTByConvertingToLUT1D;
+(instancetype)actionWithLUTByConvertingToLUT3D;

+(instancetype)actionWithLUTByChangingInputLowerBound:(double)inputLowerBound
                                      inputUpperBound:(double)inputUpperBound;

+(instancetype)actionWithLUTByClampingLowerBound:(double)lowerBound
                                      upperBound:(double)upperBound;

+(instancetype)actionWithLUTBySwizzlingWithMethod:(LUT1DSwizzleChannelsMethod)method;

+(instancetype)actionWithLUTByResizingToSize:(NSUInteger)size;

@end
