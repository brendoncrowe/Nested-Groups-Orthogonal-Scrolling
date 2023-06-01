//
//  ViewController.swift
//  Nested-Groups-Orthogonal-Scrolling
//
//  Created by Brendon Crowe on 6/1/23.
//

import UIKit

enum Section: Int, CaseIterable {
    case first
    case second
    case third
    
    var itemCount: Int {
        switch self {
        case .first:
            return 2
        default:
            return 1
        }
    }
    var itemHeight: NSCollectionLayoutDimension {
        switch self {
        case .first:
            return .fractionalHeight(0.5)
        default:
            return .fractionalHeight(1.0)
        }
    }
    var nestedGroupHeight: NSCollectionLayoutDimension {
        switch self {
        case .first:
            return .fractionalWidth(0.9)
        default:
            return .fractionalWidth(0.45)
        }
    }
    var sectionTitle: String {
        switch self {
        case .first:
            return "First Section"
        case .second:
            return "Section Section"
        case .third:
            return "Third Section"
        }
    }
}

class ViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
                fatalError("could not dequeue a Label Cell")
            }
            cell.textLabel.text = "\(item)"
            cell.backgroundColor = .systemRed.withAlphaComponent(0.8)
            cell.layer.cornerRadius = 12
            return cell
        })
        
        // dequeue the header
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
          
          guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView,
            let sectionKind = Section(rawValue: indexPath.section) else {
            fatalError("could not dequeue a HeaderView")
          }
          // configure the headerView
          headerView.textLabel.text = sectionKind.sectionTitle
          headerView.textLabel.textAlignment = .left
          headerView.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
          return headerView
        }
        
        
        // create initial snapshot
         var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
         
         snapshot.appendSections([.first, .second, .third])
         
         // populate the sections (3)
         snapshot.appendItems(Array(1...20), toSection: .first)
         snapshot.appendItems(Array(21...40), toSection: .second)
         snapshot.appendItems(Array(41...60), toSection: .third)
         
         dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // item -> group -> section -> layout
        
        // two ways to create a layout
        // 1. use a given section
        // 2. use a section provide which takes a closure
        // - the section provider closure gets called for each section
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            // sections 0,1,2 come from the enum Section
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { fatalError("could not create an instance of Section")
            }
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: sectionKind.itemHeight)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            
            // inner group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, repeatingSubitem: item, count: sectionKind.itemCount)
            
            // nested group
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: sectionKind.nestedGroupHeight)
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])
            
            // section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            
            // section header
            // create the header size; Header must be registered
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        return layout
    }
}
