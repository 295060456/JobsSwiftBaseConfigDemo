//
//  WalletLayoutDelegate.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/5/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

protocol WalletLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView,
                        reusableHeaderHeightFor section: Int) -> CGFloat

    func collectionView(_ collectionView: UICollectionView,
                        reusableFooterHeightFor section: Int) -> CGFloat
}
