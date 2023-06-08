//
//  ItemCell.swift
//  Hackthon
//
//  Created by Hitender Kumar on 08/06/23.
//

import UIKit

protocol ItemCellModelProtocol {
    var name: String? { get }
    var image: String? { get }
}

struct ItemCellModel: ItemCellModelProtocol {
    let name: String?
    let image: String?
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(model: ItemCellModelProtocol) {
        lbl.text = model.name
        if let image = model.image {
            imgView.image = UIImage(named: image)
        } else {
            imgView.image = UIImage(named: "dummyImage")
        }
    }
}
