/*
 MIT License
 
 Copyright (c) 2016 Prince Ugwuh
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

extension DataSource: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !self.staticItems.isEmpty {
            return self.staticItems.count
        } else if let numberOfItems = self.numberOfItems {
            return numberOfItems
        } else if !self.items.isEmpty {
            return self.loadingMoreCellIdentifier != nil ? self.items.count + 1 : self.items.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier: String
        var item: Any?
        
        if let loadingMoreCellIdentifier = self.loadingMoreCellIdentifier,
           self.items.count == indexPath.row {
            identifier = loadingMoreCellIdentifier
        } else if !self.staticItems.isEmpty {
            let staticItem = self.staticItems[indexPath.row]
            identifier = staticItem.identifier
            item = staticItem.item
        } else {
            item = self.items[indexPath.row]
            identifier = self.cellIdentifier
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if cell is DataSourceConfigurable {
            let sourceCell = cell as! DataSourceConfigurable
            sourceCell.configure(item)
            delegate?.didConfigure(sourceCell, at: indexPath)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var  identifier: String = ""
        var item: Any?

        if let headerItem = self.headerItem,
            kind == UICollectionView.elementKindSectionHeader {
            
            identifier = headerItem.identifier
            item = headerItem.item
        } else if let footerItem = self.footerItem,
            kind == UICollectionView.elementKindSectionFooter {
            
            identifier = footerItem.identifier
            item = footerItem.item
        }

        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)

        if let cell = cell as? DataSourceConfigurable {
            cell.configure(item)
            self.delegate?.didConfigure(cell, at: indexPath)
        }

        return cell
    }
}


extension GroupedDataSource: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataSources.isEmpty ? 1 : self.dataSources.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSources[section].collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.dataSources[indexPath.section].collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return self.dataSources[indexPath.section].collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
}
