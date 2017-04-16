//
//  SAFlowLayout.m
//  CollectionViewDemo
//
//  Created by gaoqiang xu on 14/04/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "SAFlowLayout.h"

static CGFloat const ITEM_WIDTH = 320.f;
static CGFloat const ITEM_HEIGHT = 160.f;

static CGFloat const ITEM_DISTANCE_Z = 400.0f;

@implementation SAFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/**
 * 用来做布局的初始化操作（不建议在init方法中进行布局的初始化操作）
 */
- (void)prepareLayout
{
    [super prepareLayout];
    
    self.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
    // 设置内边距
    CGFloat inset = (self.collectionView.frame.size.width - self.itemSize.width) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
    self.minimumLineSpacing = -40.f;
//    self.minimumInteritemSpacing = 1.f;
}

/**
 UICollectionViewLayoutAttributes *attrs;
 1.一个cell对应一个UICollectionViewLayoutAttributes对象
 2.UICollectionViewLayoutAttributes对象决定了cell的frame
 */
/**
 * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
 * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect] ;
    // 计算collectionView最中心点的x值
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 在原有布局属性的基础上，进行微调
    for (UICollectionViewLayoutAttributes *attrs in array) {
        // cell的中心点x 和 collectionView最中心点的x值 的间距
        CGFloat delta = attrs.center.x - centerX;
        
        CGFloat scale = delta / self.collectionView.frame.size.width;
        
        // 设置缩放比例
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0f / ITEM_DISTANCE_Z;
    
//        transform = CATransform3DTranslate(transform, 0, 0, offsetZ);

        scale = MAX(-1, scale);
        scale = MIN(1, scale);
        
        CGFloat radian = (scale)*M_PI_2*0.9;
        
        CGFloat diffZ = sin(ABS(radian))*ITEM_WIDTH/2 + pow(ABS(scale), 2) * ITEM_DISTANCE_Z/2;
        
        transform = CATransform3DTranslate(transform, 0, 0, -diffZ);
        
        CGFloat temp = ITEM_WIDTH*cos(ABS(radian))/2;
        CGFloat temp1 = ITEM_WIDTH*sin(ABS(radian))/2;
        
        CGFloat distance = ITEM_DISTANCE_Z+diffZ;
        
        CGFloat seenWidth = temp*distance/(distance-temp1);
        CGFloat diff = seenWidth-ITEM_WIDTH/2;
        
        CGFloat offsetX = diff*(distance-temp1)/distance;
        
        NSLog(@"idx: %zd, offsetX: %f", attrs.indexPath.item, offsetX);
        
        transform = CATransform3DTranslate(transform, delta<0?(-offsetX):(offsetX), 0, 0);
        
        transform = CATransform3DRotate(transform, radian, 0, 1, 0);

        attrs.transform3D = transform;
        
    }
    return array;
}

/**
 * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
 
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    NSLog(@"targetContentOffsetForProposedContentOffset: %@ withScrollingVelocity: %@", NSStringFromCGPoint(proposedContentOffset), NSStringFromCGPoint(velocity));
    
    // 计算出最终显示的矩形框
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 存放最小的间距值
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX;
        }
    }
    
    // 修改原有的偏移量
    proposedContentOffset.x += minDelta;
    return proposedContentOffset;
}

@end
