//
//  ItemsListViewController.swift
//  Hackthon
//
//  Created by Himanshu Saraswat on 08/06/23.
//

import UIKit
import FloatingPanel
import Segmentio

class ItemsListViewModel {
    var itemCategories = [SegmentioItem]()
    
    init(itemCategories: [SegmentioItem] = []) {
        self.itemCategories = itemCategories
    }
}

class ItemsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentView: Segmentio!

    let viewModel = ItemsListViewModel()
    
    var fpc: FloatingPanelController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.itemCategories = [SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil), SegmentioItem(title: "Shirt", image: nil)]
        
        setup()
    }
    
    private func setup() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        
        let options = SegmentioOptions(
            backgroundColor: .white,
            segmentPosition: SegmentioPosition.dynamic,
            scrollEnabled: true,
            indicatorOptions: SegmentioIndicatorOptions(type: .top),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions.init(type: .topAndBottom),
            imageContentMode: .center,
            labelTextAlignment: .center)
        
        segmentView.setup(
            content: viewModel.itemCategories,
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        
        segmentView.valueDidChange = { segmentio, segmentIndex in
            print("Selected item: ", segmentIndex)
        }
    }
}

extension ItemsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.configure(model: ItemCellModel(name: "T-Shirt", image: nil))
        return cell
    }
}
