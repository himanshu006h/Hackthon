//
//  ScannedImageViewControlller.swift
//  Hackthon
//
//  Created by Hitender Kumar on 08/06/23.
//

import UIKit
import FloatingPanel

class ScannedImageViewControlller: UIViewController, FloatingPanelControllerDelegate {

    var fpc: FloatingPanelController!

    override func viewDidLoad() {
        super.viewDidLoad()
         setupFCP()
    }
    
    func setupFCP() {
        // Initialize a `FloatingPanelController` object.
        fpc = FloatingPanelController()

        // Assign self as the delegate of the controller.
        fpc.delegate = self // Optional

        // Set a content view controller.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let contentVC = storyboard.instantiateViewController(withIdentifier: "ItemsListViewController") as? ItemsListViewController {
            fpc.set(contentViewController: contentVC)

            // Track a scroll view(or the siblings) in the content view controller.
            fpc.track(scrollView: contentVC.tableView)

            // Add and show the views managed by the `FloatingPanelController` object to self.view.
            fpc.addPanel(toParent: self)
        }
    }
    
    func floatingPanel(_ fpc: FloatingPanelController, contentOffsetForPinning trackingScrollView: UIScrollView) -> CGPoint {
        return CGPoint(x: 0, y: 300)
    }
    
    
}
