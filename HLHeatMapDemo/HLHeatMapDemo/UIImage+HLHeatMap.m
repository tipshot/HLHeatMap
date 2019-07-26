//
//  UIImage+HLHeatMap.m
//  HLHeatMapDemo
//
//  Created by huaxingyunrui on 2019/7/26.
//  Copyright © 2019 hanlin. All rights reserved.
//

#import "UIImage+HLHeatMap.h"

@implementation UIImage (HLHeatMap)
// This number should be between 0 and 1
static const CGFloat kSBAlphaPivotX = 0.333;
// This number should be between 0 and MAX_ALPHA
static const CGFloat kSBAlphaPivotY = 0.5;
// This number should be between 0 and 1
static const CGFloat kSBMaxAlpha = 0.85;

static inline void colorForValue(double value, double *red, double *green, double *blue, double *alpha) {
    static int maxVal = 255;
    if (value > 1) {
        value = 1;
    }
    
    if (value < kSBAlphaPivotY) {
        *alpha = value * kSBAlphaPivotY / kSBAlphaPivotX;
    } else {
        *alpha = kSBAlphaPivotY +
        ((kSBMaxAlpha - kSBAlphaPivotY) / (1 - kSBAlphaPivotX)) *
        (value - kSBAlphaPivotX);
    }
    
    // formula converts a number from 0 to 1.0 to an rgb color.---公式将数字从0到1.0转换为rgb颜色。
    // uses MATLAB/Octave colorbar code---使用MATLAB/八进制彩色条码
    if (value <= 0) {
        *red = *green = *blue = *alpha = 0;
    } else if (value < 0.2) {
        *red = *green = 0;
        *blue = 4 * (value + 0.05);
    } else if (value < 0.45) {
        *red = 0;
        *green = 4 * (value - 0.20);
        *blue = 1;
    } else if (value < 0.70) {
        *red = 4 * (value - 0.45);
        *green = 1;
        *blue = 1 - 4 * (value - 0.45);
    } else if (value < 0.95) {
        *red = 1;
        *green = 1 - 4 * (value - 0.70);
        *blue = 0;
    } else {
        *red = MAX(1 - 4 * (value - 0.95), 0.5);
        *green = *blue = 0;
    }
    
    *alpha *= maxVal;
    *blue *= *alpha;
    *green *= *alpha;
    *red *= *alpha;
}

inline static int isqrt(int x) {
    static const int sqrttable[] = {
        0,   16,  22,  27,  32,  35,  39,  42,  45,  48,  50,  53,  55,  57,  59,
        61,  64,  65,  67,  69,  71,  73,  75,  76,  78,  80,  81,  83,  84,  86,
        87,  89,  90,  91,  93,  94,  96,  97,  98,  99,  101, 102, 103, 104, 106,
        107, 108, 109, 110, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
        123, 124, 125, 126, 128, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137,
        138, 139, 140, 141, 142, 143, 144, 144, 145, 146, 147, 148, 149, 150, 150,
        151, 152, 153, 154, 155, 155, 156, 157, 158, 159, 160, 160, 161, 162, 163,
        163, 164, 165, 166, 167, 167, 168, 169, 170, 170, 171, 172, 173, 173, 174,
        175, 176, 176, 177, 178, 178, 179, 180, 181, 181, 182, 183, 183, 184, 185,
        185, 186, 187, 187, 188, 189, 189, 190, 191, 192, 192, 193, 193, 194, 195,
        195, 196, 197, 197, 198, 199, 199, 200, 201, 201, 202, 203, 203, 204, 204,
        205, 206, 206, 207, 208, 208, 209, 209, 210, 211, 211, 212, 212, 213, 214,
        214, 215, 215, 216, 217, 217, 218, 218, 219, 219, 220, 221, 221, 222, 222,
        223, 224, 224, 225, 225, 226, 226, 227, 227, 228, 229, 229, 230, 230, 231,
        231, 232, 232, 233, 234, 234, 235, 235, 236, 236, 237, 237, 238, 238, 239,
        240, 240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246, 246, 247,
        247, 248, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254,
        255};
    
    int xn;
    
    if (x >= 0x10000) {
        if (x >= 0x1000000) {
            if (x >= 0x10000000) {
                if (x >= 0x40000000) {
                    xn = sqrttable[x >> 24] << 8;
                } else {
                    xn = sqrttable[x >> 22] << 7;
                }
            } else {
                if (x >= 0x4000000) {
                    xn = sqrttable[x >> 20] << 6;
                } else {
                    xn = sqrttable[x >> 18] << 5;
                }
            }
            
            xn = (xn + 1 + (x / xn)) >> 1;
            xn = (xn + 1 + (x / xn)) >> 1;
            
            return ((xn * xn) > x) ? --xn : xn;
        } else {
            if (x >= 0x100000) {
                if (x >= 0x400000) {
                    xn = sqrttable[x >> 16] << 4;
                } else {
                    xn = sqrttable[x >> 14] << 3;
                }
            } else {
                if (x >= 0x40000) {
                    xn = sqrttable[x >> 12] << 2;
                } else {
                    xn = sqrttable[x >> 10] << 1;
                }
            }
            
            xn = (xn + 1 + (x / xn)) >> 1;
            
            return ((xn * xn) > x) ? --xn : xn;
        }
    } else {
        if (x >= 0x100) {
            if (x >= 0x1000) {
                if (x >= 0x4000) {
                    xn = (sqrttable[x >> 8]) + 1;
                } else {
                    xn = (sqrttable[x >> 6] >> 1) + 1;
                }
            } else {
                if (x >= 0x400) {
                    xn = (sqrttable[x >> 4] >> 2) + 1;
                } else {
                    xn = (sqrttable[x >> 2] >> 3) + 1;
                }
            }
            
            return ((xn * xn) > x) ? --xn : xn;
        } else {
            if (x >= 0) {
                return sqrttable[x] >> 4;
            } else {
                return -1; // negative argument...---消极论据...
            }
        }
    }
}

+ (UIImage *)heatMapWithRect:(CGRect)rect
                       boost:(float)boost
                      points:(NSArray *)points
                     weights:(NSArray *)weights
    weightsAdjustmentEnabled:(BOOL)weightsAdjustmentEnabled
             groupingEnabled:(BOOL)groupingEnabled {
    
    // Adjustment variables for weights adjustment---权重调整变量
    float weightSensitivity = 1; // Percents from maximum weight---重量上限的百分比
    float weightBoostTo = 50;    // Percents to boost least sensible weight to---将最不合理的重量增加到
    
    // Adjustment variables for grouping---分组调整变量
    int groupingThreshold = 10; // Increasing this will improve performance with---增加它将提高性能
    // less accuracy. Negative will disable grouping---更少的准确性。负数将禁用分组
    int peaksRemovalThreshold = 20; // Should be greater than groupingThreshold---否应该大于groupingThreshold
    float peaksRemovalFactor = 0.4; // Should be from 0 (no peaks removal) to 1---应该从0(无峰移除)到1
    // (peaks are completely lowered to zero)---(峰值完全降至零)
    // Validate arguments---验证参数
    if (points == nil || rect.size.width <= 0 || rect.size.height <= 0 ||
        (weights != nil && [points count] != [weights count])) {
        NSLog(@"LFHeatMap: heatMapWithRect: incorrect arguments");
        return nil;
    }
    UIImage *image = nil;
    int width = rect.size.width;
    int height = rect.size.height;
    int i, j;
    // According to heatmap API, boost is heat radius multiplier---根据heatmap API, boost是热半径倍增器
    int radius = 50 * boost;
    // RGBA array is initialized with 0s---RGBA数组初始化为0
    unsigned char *rgba =
    (unsigned char *)calloc(width * height * 4, sizeof(unsigned char));
    int *density = (int *)calloc(width * height, sizeof(int));
    memset(density, 0, sizeof(int) * width * height);
    
    // Step 1
    // Copy points into plain array (plain array iteration is faster than
    // accessing NSArray objects)---将点复制到普通数组中(普通数组迭代比访问NSArray对象更快)
    int points_num = (int)[points count];
    int *point_x = malloc(sizeof(int) * points_num);
    int *point_y = malloc(sizeof(int) * points_num);
    int *point_weight_percent = malloc(sizeof(int) * points_num);
    float *point_weight = 0;
    float max_weight = 0;
    if (weights != nil) {
        point_weight = malloc(sizeof(float) * points_num);
        max_weight = 0.0;
    }
    
    i = 0;
    j = 0;
    for (NSValue *pointValue in points) {
        point_x[i] = [pointValue CGPointValue].x - rect.origin.x;
        point_y[i] = [pointValue CGPointValue].y - rect.origin.y;
        
        // Filter out of range points---过滤掉距离点
        if (point_x[i] < 0 - radius || point_y[i] < 0 - radius ||
            point_x[i] >= rect.size.width + radius ||
            point_y[i] >= rect.size.height + radius) {
            points_num--;
            j++;
            // Do not increment i, to replace this point in next iteration (or drop if
            // it is last one)---不要增加i，以在下一个迭代中替换这个点(如果是最后一个，则删除)
            // but increment j to leave consistency when accessing weights---但是当访问权重时，增加j以保持一致性
            continue;
        }
        
        // Fill weights if available---填充权重(如果可以)
        if (weights != nil) {
            NSNumber *weightValue = [weights objectAtIndex:j];
            
            point_weight[i] = [weightValue floatValue];
            if (max_weight < point_weight[i])
                max_weight = point_weight[i];
        }
        
        i++;
        j++;
    }
    
    // Step 1.5
    // Normalize weights to be 0 .. 100 (like percents)---将权值标准化为0 ..100(9)
    // Weights array should be integer for not slowing down calculation by
    // int-float conversion and float multiplication---权重数组应该是整数，这样就不会因为int-float转换和float乘法而减慢计算速度
    if (weights != nil) {
        float absWeightSensitivity = (max_weight / 100.0) * weightSensitivity;
        float absWeightBoostTo = (max_weight / 100.0) * weightBoostTo;
        for (i = 0; i < points_num; i++) {
            if (weightsAdjustmentEnabled) {
                if (point_weight[i] <= absWeightSensitivity)
                    point_weight[i] *= absWeightBoostTo / absWeightSensitivity;
                
                else
                    point_weight[i] = absWeightBoostTo +
                    (point_weight[i] - absWeightSensitivity) *
                    ((max_weight - absWeightBoostTo) /
                     (max_weight - absWeightSensitivity));
            }
            point_weight_percent[i] = 100.0 * (point_weight[i] / max_weight);
        }
        free(point_weight);
    } else {
        // Fill with 1 in case if no weights provided--如果没有提供权重，则填充1
        for (i = 0; i < points_num; i++) {
            point_weight_percent[i] = 1;
        }
    }
    
    // Step 1.75 (optional) ---可选
    // Grouping and filtering bunches of points in same location---对同一位置的点进行分组和滤波
    int currentDistance;
    int currentDensity;
    if (groupingEnabled) {
        for (i = 0; i < points_num; i++) {
            if (point_weight_percent[i] > 0) {
                for (j = i + 1; j < points_num; j++) {
                    if (point_weight_percent[j] > 0) {
                        currentDistance =
                        isqrt((point_x[i] - point_x[j]) * (point_x[i] - point_x[j]) +
                              (point_y[i] - point_y[j]) * (point_y[i] - point_y[j]));
                        
                        if (currentDistance > peaksRemovalThreshold)
                            currentDistance = peaksRemovalThreshold;
                        
                        float K1 = 1 - peaksRemovalFactor;
                        float K2 = peaksRemovalFactor;
                        
                        // Lowering peaks---降低峰值
                        point_weight_percent[i] = K1 * point_weight_percent[i] +
                        K2 * point_weight_percent[i] *
                        (float)((float)(currentDistance) /
                                (float)peaksRemovalThreshold);
                        
                        // Performing grouping if two points are closer than
                        // groupingThreshold ---如果两个点比groupingThreshold更接近，则执行分组
                        if (currentDistance <= groupingThreshold) {
                            // Merge i and j points. Store result in [i], remove [j] ---合并i和j点。存储结果为[i]，删除[j]
                            point_x[i] = (point_x[i] + point_x[j]) / 2;
                            point_y[i] = (point_y[i] + point_y[j]) / 2;
                            point_weight_percent[i] =
                            point_weight_percent[i] + point_weight_percent[j];
                            
                            // point_weight_percent[j] is set negative to be avoided---point_weight_percent[j]被设置为负数以避免
                            point_weight_percent[j] = -10;
                            
                            // Repeat again for new point---对于新的点，再重复一遍
                            i--;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // Step 2
    // Fill density info. Density is calculated around each point---填充密度信息。密度是围绕每个点计算的
    int from_x, from_y, to_x, to_y;
    for (i = 0; i < points_num; i++) {
        if (point_weight_percent[i] > 0) {
            from_x = point_x[i] - radius;
            from_y = point_y[i] - radius;
            to_x = point_x[i] + radius;
            to_y = point_y[i] + radius;
            
            if (from_x < 0)
                from_x = 0;
            if (from_y < 0)
                from_y = 0;
            if (to_x > width)
                to_x = width;
            if (to_y > height)
                to_y = height;
            
            for (int y = from_y; y < to_y; y++) {
                for (int x = from_x; x < to_x; x++) {
                    currentDistance = (x - point_x[i]) * (x - point_x[i]) +
                    (y - point_y[i]) * (y - point_y[i]);
                    
                    currentDensity = radius - isqrt(currentDistance);
                    if (currentDensity < 0)
                        currentDensity = 0;
                    
                    density[y * width + x] += currentDensity * point_weight_percent[i];
                }
            }
        }
    }
    free(point_x);
    free(point_y);
    free(point_weight_percent);
    
    // Step 2.5
    // Find max density (doing this in step 2 will have less performance)---找到最大密度(在步骤2中这样做会降低性能)
    int maxDensity = density[0];
    for (i = 1; i < width * height; i++) {
        if (maxDensity < density[i])
            maxDensity = density[i];
    }
    
    // Step 3
    // Render density info into raw RGBA pixels---渲染密度信息到原始RGBA像素
    i = 0;
    float floatDensity;
    uint indexOrigin;
    CGFloat red, green, blue, alpha;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++, i++) {
            if (density[i] > 0) {
                indexOrigin = 4 * i;
                // Normalize density to 0..1---将密度归一化到0..1
                floatDensity = (float)density[i] / (float)maxDensity;
                colorForValue(floatDensity, &red, &green, &blue, &alpha);
                rgba[indexOrigin] = red;
                rgba[indexOrigin + 1] = green;
                rgba[indexOrigin + 2] = blue;
                rgba[indexOrigin + 3] = alpha;
            }
        }
    }
    free(density);
    
    // Step 4
    // Create image from rendered raw data---从渲染的原始数据创建图像
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(
                                                       rgba, width, height,
                                                       8,         // bitsPerComponent
                                                       4 * width, // bytesPerRow
                                                       colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    
    CFRelease(colorSpace);
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    image = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    CFRelease(bitmapContext);
    
    free(rgba);
    return image;
}
@end
