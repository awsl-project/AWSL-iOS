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
    
    func calculateCellSize(photos: [Photo]) -> [CGSize] {
        guard !photos.isEmpty else { return [] }
        let totalWidth = self.totalWidth - interval * CGFloat(photos.count - 1)
        if photos.count == 1 {
            let info = photos[0].info.large
            let width = totalWidth / 2
            let height = width / CGFloat(info.width) * CGFloat(info.height)
            return [CGSize(width: width, height: height)]
        } else {
            let firstInfo = photos[0].info.large
            var dividerNum: CGFloat = CGFloat(firstInfo.width)
            for index in 1 ..< photos.count {
                let info = photos[index].info.large
                dividerNum += CGFloat(info.width * firstInfo.height) / CGFloat(info.height)
            }
            let firstScale = totalWidth / dividerNum
            var scales: [CGFloat] = [firstScale]
            for index in 1 ..< photos.count {
                let info = photos[index].info.large
                let scale = CGFloat(firstInfo.height) * firstScale / CGFloat(info.height)
                scales.append(scale)
            }
            let height = round(CGFloat(firstInfo.height) * firstScale)
            var sizes: [CGSize] = []
            for (index, scale) in scales.enumerated() {
                let info = photos[index].info.large
                if index == scales.count - 1 {
                    let width = sizes.reduce(totalWidth) { partialResult, size in
                        return partialResult - size.width
                    }
                    sizes.append(CGSize(width: width, height: height))
                } else {
                    let width = round(CGFloat(info.width) * scale)
                    sizes.append(CGSize(width: width, height: height))
                }
            }
            return sizes
        }
    }
}
