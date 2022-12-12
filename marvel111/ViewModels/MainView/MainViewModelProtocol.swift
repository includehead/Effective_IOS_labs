import Foundation

protocol MainViewModelProtocol {
    var collectionViewItems: [CollectionCellItem] { get }
    func loadMoreCharacters()
    func refresh()
}
