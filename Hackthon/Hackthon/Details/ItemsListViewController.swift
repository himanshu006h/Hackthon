//
//  ItemsListViewController.swift
//  Hackthon
//
//  Created by Himanshu Saraswat on 08/06/23.
//

import UIKit
import FloatingPanel
import Segmentio
import SafariServices

class ItemsListViewModel {
    var itemCategories = [SegmentioItem]()
    var products = [SegmentioItem : [productDetails]]()
    init(itemCategories: [SegmentioItem] = [] ) {
        self.itemCategories = itemCategories
    }
}

class ItemsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentView: Segmentio!

    var viewModel = ItemsListViewModel()
    
    var fpc: FloatingPanelController!

    func reloadData() {
        self.segmentView.reloadSegmentio()
        setupTabBar()
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentView.selectedSegmentioIndex = -1
        viewModel.itemCategories = []
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        setupTabBar()
    }
    func addMenu(newItems : [SegmentioItem]) {
        self.viewModel.itemCategories = newItems
        self.tableView.reloadData()
    }
    
    private func setupTabBar() {
        
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            ),
            selectedState: SegmentioState(
                backgroundColor: .orange,
                titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .white
            ),
            highlightedState: SegmentioState(
                backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                titleFont: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            )
        )
        let horiz_separator = SegmentioHorizontalSeparatorOptions(
                    type: SegmentioHorizontalSeparatorType.topAndBottom, // Top, Bottom, TopAndBottom
                    height: 1,
                    color: .gray
        )
        
        let options = SegmentioOptions(
            backgroundColor: .white,
            segmentPosition: SegmentioPosition.dynamic,
            scrollEnabled: true,
            indicatorOptions: SegmentioIndicatorOptions(type: .top),
            horizontalSeparatorOptions: horiz_separator,
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(ratio: 0.6, color: .gray),
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: states
        )
        
        segmentView.setup(
            content: viewModel.itemCategories,
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        
        segmentView.valueDidChange = { segmentio, segmentIndex in
            print("Selected item: ", segmentIndex)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ItemsListViewController: UITableViewDataSource ,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (viewModel.itemCategories.count>0) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = self.viewModel.itemCategories[segmentView.selectedSegmentioIndex]
        return self.viewModel.products[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let category = self.viewModel.itemCategories[segmentView.selectedSegmentioIndex]
        if let product = self.viewModel.products[category]?[indexPath.row] {
            cell.configure(model: product)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = self.viewModel.itemCategories[segmentView.selectedSegmentioIndex]
        if let product = self.viewModel.products[category]?[indexPath.row], let urlStr = product.product_page_url, let url = URL(string: urlStr){
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
}
