//
//  PhotoListDataSource.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/8.
//

import UIKit

protocol PhotoListDataSource {
    var photos: [Photo] { get }
    var maximumItemPerRow: Int { get }
    func hasNextPage() -> Bool
    func itemSize(for photo: Photo) -> CGSize
    
    typealias LoadingCompletion = (Result<[IndexPath], Error>) -> Void
    func refresh(completion: @escaping LoadingCompletion)
    func loadNextPage(completion: @escaping LoadingCompletion)
}
