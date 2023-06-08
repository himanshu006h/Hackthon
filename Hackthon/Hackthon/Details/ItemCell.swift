//
//  ItemCell.swift
//  Hackthon
//
//  Created by Hitender Kumar on 08/06/23.
//

import UIKit

//protocol ItemCellModelProtocol {
//    var name: String? { get }
//    var image: String? { get }
//}
//
//struct ItemCellModel: ItemCellModelProtocol {
//    let name: String?
//    let image: String?
//}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(model: productDetails) {
        lbl.text = model.title
        if let urlStr = model.thumbnail, let url = URL(string: urlStr) {
            imgView.downloaded(from: url)
        } else {
            imgView.image = UIImage(named: "defaultProduct")
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
