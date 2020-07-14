//
//  LUTColorSpace.m
//  Pods
//
//  Created by Greg Cotten on 4/2/14.
//
//

#import "LUTColorSpace.h"
#import "LUTColorTransferFunction.h"


@interface LUTColorSpace ()



@end


@implementation LUTColorSpace

+ (instancetype)LUTColorSpaceWithDefaultWhitePoint:(LUTColorSpaceWhitePoint *)whitePoint
                                  redChromaticityX:(double)redChromaticityX
                                  redChromaticityY:(double)redChromaticityY
                                greenChromaticityX:(double)greenChromaticityX
                                greenChromaticityY:(double)greenChromaticityY
                                 blueChromaticityX:(double)blueChromaticityX
                                 blueChromaticityY:(double)blueChromaticityY
                                              name:(NSString *)name{
    return [[self alloc] initWithDefaultWhitePoint:whitePoint
                                  redChromaticityX:redChromaticityX
                                  redChromaticityY:redChromaticityY
                                greenChromaticityX:greenChromaticityX
                                greenChromaticityY:greenChromaticityY
                                 blueChromaticityX:blueChromaticityX
                                 blueChromaticityY:blueChromaticityY
                    forwardFootlambertCompensation:1.0
                                              name:name];
}

+ (instancetype)LUTColorSpaceWithDefaultWhitePoint:(LUTColorSpaceWhitePoint *)whitePoint
                                  redChromaticityX:(double)redChromaticityX
                                  redChromaticityY:(double)redChromaticityY
                                greenChromaticityX:(double)greenChromaticityX
                                greenChromaticityY:(double)greenChromaticityY
                                 blueChromaticityX:(double)blueChromaticityX
                                 blueChromaticityY:(double)blueChromaticityY
                    forwardFootlambertCompensation:(double)flCompensation
                                              name:(NSString *)name{
    return [[self alloc] initWithDefaultWhitePoint:whitePoint
                                  redChromaticityX:redChromaticityX
                                  redChromaticityY:redChromaticityY
                                greenChromaticityX:greenChromaticityX
                                greenChromaticityY:greenChromaticityY
                                 blueChromaticityX:blueChromaticityX
                                 blueChromaticityY:blueChromaticityY
                    forwardFootlambertCompensation:flCompensation
                                              name:name];
}

- (instancetype)initWithDefaultWhitePoint:(LUTColorSpaceWhitePoint *)whitePoint
                         redChromaticityX:(double)redChromaticityX
                         redChromaticityY:(double)redChromaticityY
                       greenChromaticityX:(double)greenChromaticityX
                       greenChromaticityY:(double)greenChromaticityY
                        blueChromaticityX:(double)blueChromaticityX
                        blueChromaticityY:(double)blueChromaticityY
           forwardFootlambertCompensation:(double)flCompensation
                                     name:(NSString *)name{
    if (self = [super init]) {
        self.redChromaticityX = redChromaticityX;
        self.redChromaticityY = redChromaticityY;
        self.greenChromaticityX = greenChromaticityX;
        self.greenChromaticityY = greenChromaticityY;
        self.blueChromaticityX = blueChromaticityX;
        self.blueChromaticityY = blueChromaticityY;
        self.forcesNPM = NO;
        self.forwardFootlambertCompensation = flCompensation;
        self.name = name;
    }
    return self;
}

+ (NSArray *)knownColorSpaces{
    NSArray *allKnownColorSpaces = @[[self rec709ColorSpace],
                                     [self dciP3ColorSpace],
                                     [self rec2020ColorSpace],
                                     [self alexaWideGamutColorSpace],
                                     [self sGamut3CineColorSpace],
                                     [self sGamutColorSpace],
                                     [self bmccColorSpace],
                                     [self redColorColorSpace],
                                     [self redColor2ColorSpace],
                                     [self redColor3ColorSpace],
                                     [self redColor4ColorSpace],
                                     [self dragonColorColorSpace],
                                     [self dragonColor2ColorSpace],
                                     [self canonCinemaGamutColorSpace],
                                     [self canonDCIP3PlusColorSpace],
                                     [self vGamutColorSpace],
                                     [self acesGamutColorSpace],
                                     [self xyzColorSpace],
                                     [self adobeRGBColorSpace],
                                     [self proPhotoRGBColorSpace]];

    return allKnownColorSpaces;
}


+ (instancetype)rec709ColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.64
                                   redChromaticityY:0.33
                                 greenChromaticityX:0.30
                                 greenChromaticityY:0.60
                                  blueChromaticityX:0.15
                                  blueChromaticityY:0.06
                                               name:@"Rec. 709"];
}

+ (instancetype)canonDCIP3PlusColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint dciWhitePoint]
                                   redChromaticityX:0.7400
                                   redChromaticityY:0.2700
                                 greenChromaticityX:0.2200
                                 greenChromaticityY:0.7800
                                  blueChromaticityX:0.0900
                                  blueChromaticityY:-0.0900
                                               name:@"Canon DCI-P3+"];
}

+ (instancetype)canonCinemaGamutColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.7400
                                   redChromaticityY:0.2700
                                 greenChromaticityX:0.1700
                                 greenChromaticityY:1.1400
                                  blueChromaticityX:0.0800
                                  blueChromaticityY:-0.1000
                                               name:@"Canon Cinema Gamut"];
}

+ (instancetype)bmccColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.901885370853
                                   redChromaticityY:0.249059467640
                                 greenChromaticityX:0.280038809783
                                 greenChromaticityY:1.535129255560
                                  blueChromaticityX:0.078873341398
                                  blueChromaticityY:-0.082629719848
                                               name:@"BMCC"];
}

+ (instancetype)redColorColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.682235759294
                                   redChromaticityY:0.320973856307
                                 greenChromaticityX:0.295705729612
                                 greenChromaticityY:0.613311106957
                                  blueChromaticityX:0.134524597085
                                  blueChromaticityY:0.034410956920
                                               name:@"REDcolor"];
}

// REDcolor2-4 and DRAGONcolor1-2 are provided with calculations by Tashi Trieu and Thomas Mansencal
// http://colour-science.org/blog_red_colourspaces_derivation.php

+ (instancetype)redColor2ColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.878682510476
                                   redChromaticityY:0.32496400741
                                 greenChromaticityX:0.300888714367
                                 greenChromaticityY:0.679054755791
                                  blueChromaticityX:0.0953986946056
                                  blueChromaticityY:-0.0293793268343
                                               name:@"REDcolor2"];
}

+ (instancetype)redColor3ColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.701181035906
                                   redChromaticityY:0.329014155583
                                 greenChromaticityX:0.300600304652
                                 greenChromaticityY:0.683788834269
                                  blueChromaticityX:0.108154455624
                                  blueChromaticityY:-0.00868817578666
                                               name:@"REDcolor3"];
}

+ (instancetype)redColor4ColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.701180591892
                                   redChromaticityY:0.329013699116
                                 greenChromaticityX:0.300600395529
                                 greenChromaticityY:0.683788824257
                                  blueChromaticityX:0.145331946229
                                  blueChromaticityY:0.0516168036226
                                               name:@"REDcolor4"];
}

+ (instancetype)dragonColorColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.753044222785
                                   redChromaticityY:0.327830576682
                                 greenChromaticityX:0.299570228481
                                 greenChromaticityY:0.700699321956
                                  blueChromaticityX:0.079642066735
                                  blueChromaticityY:-0.0549379510888
                                               name:@"DRAGONcolor"];
}

+ (instancetype)dragonColor2ColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.753044491143
                                   redChromaticityY:0.327831029513
                                 greenChromaticityX:0.299570490451
                                 greenChromaticityY:0.700699415614
                                  blueChromaticityX:0.145011584278
                                  blueChromaticityY:0.0510971250879
                                               name:@"DRAGONcolor2"];
}

+ (instancetype)proPhotoRGBColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.7347
                                   redChromaticityY:0.2653
                                 greenChromaticityX:0.1596
                                 greenChromaticityY:0.8404
                                  blueChromaticityX:0.0366
                                  blueChromaticityY:0.0001
                                               name:@"ProPhoto RGB"];
}

+ (instancetype)adobeRGBColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                   redChromaticityX:0.64
                                   redChromaticityY:0.33
                                 greenChromaticityX:0.21
                                 greenChromaticityY:0.71
                                  blueChromaticityX:0.15
                                  blueChromaticityY:0.06
                                               name:@"Adobe RGB"];
}

+ (instancetype)dciP3ColorSpace{
    return [self LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint dciWhitePoint]
                                   redChromaticityX:0.680
                                   redChromaticityY:0.320
                                 greenChromaticityX:0.265
                                 greenChromaticityY:0.69
                                  blueChromaticityX:0.15
                                  blueChromaticityY:0.06
                                               name:@"DCI-P3"];
}

+ (instancetype)rec2020ColorSpace{
    return [LUTColorSpace LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                             redChromaticityX:0.708
                                             redChromaticityY:0.292
                                           greenChromaticityX:0.170
                                           greenChromaticityY:0.797
                                            blueChromaticityX:0.131
                                            blueChromaticityY:0.046
                                                         name:@"Rec. 2020"];

}

+ (instancetype)alexaWideGamutColorSpace{
    return [LUTColorSpace LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                            redChromaticityX:0.6840
                                            redChromaticityY:0.3130
                                          greenChromaticityX:0.2210
                                          greenChromaticityY:0.8480
                                           blueChromaticityX:0.0861
                                           blueChromaticityY:-0.1020
                                                        name:@"Alexa Wide Gamut"];
}

+ (instancetype)sGamut3CineColorSpace{
    return [LUTColorSpace LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                            redChromaticityX:0.76600
                                            redChromaticityY:0.27500
                                          greenChromaticityX:0.22500
                                          greenChromaticityY:0.80000
                                           blueChromaticityX:0.08900
                                           blueChromaticityY:-0.08700
                                                        name:@"S-Gamut3.Cine"];
}

+ (instancetype)sGamutColorSpace{
    return [LUTColorSpace LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                            redChromaticityX:0.73000
                                            redChromaticityY:0.28000
                                          greenChromaticityX:0.14000
                                          greenChromaticityY:0.85500
                                           blueChromaticityX:0.10000
                                           blueChromaticityY:-0.05000
                                                        name:@"S-Gamut/S-Gamut3"];
}

+ (instancetype)vGamutColorSpace{
    return [LUTColorSpace LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d65WhitePoint]
                                            redChromaticityX:0.730
                                            redChromaticityY:0.280
                                          greenChromaticityX:0.165
                                          greenChromaticityY:0.840
                                           blueChromaticityX:0.100
                                           blueChromaticityY:-0.030
                                                        name:@"V-Gamut"];
}

+ (instancetype)acesGamutColorSpace{
    return [LUTColorSpace LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint d60WhitePoint]
                                            redChromaticityX:0.73470
                                            redChromaticityY:0.26530
                                          greenChromaticityX:0.00000
                                          greenChromaticityY:1.00000
                                           blueChromaticityX:0.00010
                                           blueChromaticityY:-0.07700
                                                        name:@"ACES Gamut"];
}

+ (instancetype)xyzColorSpace{
    return [LUTColorSpace LUTColorSpaceWithDefaultWhitePoint:[LUTColorSpaceWhitePoint xyzWhitePoint]
                                            redChromaticityX:1
                                            redChromaticityY:0
                                          greenChromaticityX:0
                                          greenChromaticityY:1
                                           blueChromaticityX:0
                                           blueChromaticityY:0
                              forwardFootlambertCompensation:0.916555
                                                        name:@"CIE-XYZ"];
}

@end
