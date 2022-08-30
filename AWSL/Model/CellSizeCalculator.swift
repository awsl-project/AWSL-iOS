//
//  CellSizeUtil.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/29.
//

import UIKit

class CellSizeCalculator {
    
    let totalWidth: CGFloat
    let interval: CGFloat
    
    init(totalWidth: CGFloat, interval: CGFloat) {
        self.totalWidth = totalWidth
        self.interval = interval
    }
    
    func calculateCellSize(singleImage info: Photo.Info) -> CGSize {
        let width = totalWidth / 2
        let height = width / CGFloat(info.width) * CGFloat(info.height)
        return CGSize(width: width, height: height)
    }
    
    /* two images
     left.width * leftScale + right.width * rightScale = totalWidth
     left.height * leftScale = right.height * rightScale
     */
    func calculateCellSize(leftInfo: Photo.Info, rightInfo: Photo.Info) -> (CGSize, CGSize) {
        let totalWidth = self.totalWidth - interval
        let leftScale = totalWidth / (CGFloat(leftInfo.width) + CGFloat(rightInfo.width * leftInfo.height) / CGFloat(rightInfo.height))
        let leftWidth = round(CGFloat(leftInfo.width) * leftScale)
        let rightWidth = totalWidth - leftWidth
        let height = round(CGFloat(leftInfo.height) * leftScale)
        let leftSize = CGSize(width: leftWidth, height: height)
        let rightSize = CGSize(width: rightWidth, height: height)
        return (leftSize, rightSize)
    }
    
    /* three images
     left.width * leftScale + middle.width * middleScale + right.width * rightScale = totalWidth
     left.height * leftScale = middle.height * middleScale = right.height * rightHeight
     */
    func calculateCellSize(leftInfo: Photo.Info, middleInfo: Photo.Info, rightInfo: Photo.Info) -> (CGSize, CGSize, CGSize) {
        let totalWidth = self.totalWidth - interval * 2
        let leftScale = totalWidth / (CGFloat(leftInfo.width) + CGFloat(middleInfo.width * leftInfo.height) / CGFloat(middleInfo.height) + CGFloat(rightInfo.width * leftInfo.height) / CGFloat(rightInfo.height))
        let rightScale = CGFloat(leftInfo.height) * leftScale / CGFloat(rightInfo.height)
        let leftWidth = round(CGFloat(leftInfo.width) * leftScale)
        let rightWidth = round(CGFloat(rightInfo.width) * rightScale)
        let middleWidth = totalWidth - leftWidth - rightWidth
        let height = round(CGFloat(leftInfo.height) * leftScale)
        let leftSize = CGSize(width: leftWidth, height: height)
        let middleSize = CGSize(width: middleWidth, height: height)
        let rightSize = CGSize(width: rightWidth, height: height)
        return (leftSize, middleSize, rightSize)
    }
}
