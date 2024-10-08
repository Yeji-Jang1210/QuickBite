//
//  CarouselLayout.swift
//  QuickBite
//
//  Created by 장예지 on 8/25/24.
//

import UIKit

final class CarouselLayout: UICollectionViewFlowLayout {
    
    var sideItemScale = 0.5
    var sideItemAlpha = 0.5
    var spacing: CGFloat = 10
    
    var isPagingEnabled = false
    var isSetup: Bool = false
    
    //prepare() 메서드는 처음 딱 한 번만 호출
    override func prepare() {
        super.prepare()
        if !isSetup {
            setupLayout()
            isSetup = true
        }
    }
    
    private func setupLayout(){
        guard let collectionView = self.collectionView else { return }
        
        let collectionViewSize = collectionView.bounds.size
        
        let xInset = (collectionViewSize.width - self.itemSize.width) / 2
        let yInset = (collectionViewSize.height - self.itemSize.height) / 2
        
        self.sectionInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
        let itemWidth = self.itemSize.width
        let scaledItemOffset = (itemWidth - itemWidth * self.sideItemScale) / 2
        self.minimumLineSpacing = spacing - scaledItemOffset
        
        self.scrollDirection = .horizontal
    }
    
    //레이아웃 업데이트가 필요한지 요청하는 메서드
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let superAttributes = super.layoutAttributesForElements(in: rect),
                let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
                else { return nil }
            
            return attributes.map({ self.transformLayoutAttributes(attributes: $0) })
        }
        
    private func transformLayoutAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else {return attributes}
        
        let collectionCenter = collectionView.frame.size.width / 2
        let contentOffset = collectionView.contentOffset.x
        let center = attributes.center.x - contentOffset
        
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - center), maxDistance)

        let ratio = (maxDistance - distance)/maxDistance

        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
        
        attributes.alpha = alpha
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let dist = attributes.frame.midX - visibleRect.midX
        var transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        transform = CATransform3DTranslate(transform, 0, 0, -abs(dist/1000))
        attributes.transform3D = transform
        
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
                   let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
                   return latestOffset
               }

               let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
               guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

               var offsetAdjustment = CGFloat.greatestFiniteMagnitude
               let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

               for layoutAttributes in rectAttributes {
                   let itemHorizontalCenter = layoutAttributes.center.x
                   if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                       offsetAdjustment = itemHorizontalCenter - horizontalCenter
                   }
               }

               return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
}
