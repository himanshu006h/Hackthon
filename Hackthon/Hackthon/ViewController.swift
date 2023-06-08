//
//  ViewController.swift
//  Hackthon
//
//  Created by Himanshu Saraswat on 08/06/23.
//

import UIKit

class ViewController: UIViewController {
    
    var coreScanner: ScannerComponentViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadScanner()
        // Do any additional setup after loading the view.
    }
    
    private func loadScanner() {
        let model = ScannerModel(title: "",
                            subtitle: "",
                            state: .success,
                            isFlashEnable: true,
                            isCaptureEnable: true)
        
        let modelLoading = ScannerModel(title: "",
                            subtitle: "",
                            state: .success,
                            isFlashEnable: true,
                            isCaptureEnable: true)
        
        coreScanner = ScannerComponentViewController(model: model, loadingModel: modelLoading, compressionIndex: 0.3)
        
        coreScanner?.delegate = self
        guard let scanner = coreScanner else { return }
        self.navigationController?.pushViewController(scanner, animated: false)
    }

}

extension ViewController: CoreScannerProtocol {
    func stateChange(changeDetails: ScannerOutputModel) {
        if changeDetails.documentData != nil {
            // Push details controller from here
        }
    }
}

