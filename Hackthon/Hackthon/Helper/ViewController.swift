//
//  ViewController.swift
//  Hackthon
//
//  Created by Manikandan Bangaru on 08/06/23.
//
import TensorFlowLiteTaskVision
import UIKit
import FloatingPanel
import Segmentio
import Foundation
import OrderedCollections

extension SegmentioItem : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
    }
    
    public static func == (lhs: SegmentioItem, rhs: SegmentioItem) -> Bool {
        lhs.title == rhs.title
    }
}
class ViewController: UIViewController {
    
    // MARK: Storyboards Connections
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    
    var fpc: FloatingPanelController!
    
    // MARK: Constants
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let edgeOffset: CGFloat = 2.0
    private let labelOffset: CGFloat = 10.0
    private let animationDuration = 0.5
    private let collapseTransitionThreshold: CGFloat = -30.0
    private let expandTransitionThreshold: CGFloat = 30.0
    private let colors = [
        UIColor.red,
        UIColor(displayP3Red: 90.0 / 255.0, green: 200.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0),
        UIColor.green,
        UIColor.orange,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.brown,
    ]
    
    // MARK: Model config variables
    private var threadCount: Int = 1
    private var detectionModel: ModelType = ConstantsDefault.modelType
    private var scoreThreshold: Float = ConstantsDefault.scoreThreshold
    private var maxResults: Int = ConstantsDefault.maxResults
    
    // MARK: Instance Variables
    private var initialBottomSpace: CGFloat = 0.0
    
    // Holds the results at any time
    private var result: Result?
    private let inferenceQueue = DispatchQueue(label: "org.tensorflow.lite.inferencequeue")
    private var isInferenceQueueBusy = false
    
    // MARK: Controllers that manage functionality
    private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView)
    private var objectDetectionHelper: ObjectDetectionHelper? = ObjectDetectionHelper(
        modelFileInfo: ConstantsDefault.modelType.modelFileInfo,
        threadCount: ConstantsDefault.threadCount,
        scoreThreshold: ConstantsDefault.scoreThreshold,
        maxResults: ConstantsDefault.maxResults
    )
    //  private var inferenceViewController: InferenceViewController?
    
    func getProducts(item : SegmentioItem) {
        guard let title = item.title else {
            return
        }
        let networkManager = NetworkManager()
        networkManager.getProducts(query: title) { result,error in
            if error != nil {
                //Error
            }
            else if result != nil {
                self.productionSuggestionVC.viewModel.products[item] = result?.organic_results
                DispatchQueue.main.async {
                    self.fpc.show()
                    self.productionSuggestionVC.reloadData()
                }
            }
        }
    }
    // MARK: View Handling Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        guard objectDetectionHelper != nil else {
            fatalError("Failed to create the ObjectDetectionHelper. See the console for the error.")
        }
        cameraFeedManager.delegate = self
        overlayView.clearsContextBeforeDrawing = true
        //    addPanGesture()
        setupFCP()
    }
    lazy var productionSuggestionVC : ItemsListViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var contentVC: ItemsListViewController = storyboard.instantiateViewController(withIdentifier: "ItemsListViewController") as! ItemsListViewController
        return contentVC
    }()
    
    var productionItems = OrderedSet([SegmentioItem]())

    func addItem(item : SegmentioItem) {
        
        if !productionItems.contains(item) {
            //New Product
            productionItems.insert(item, at: 0)
            self.productionSuggestionVC.viewModel.itemCategories = Array(productionItems)
            self.productionSuggestionVC.segmentView.selectedSegmentioIndex = 0
            getProducts(item: item)
        }
    }
    func setupFCP() {
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.set(contentViewController: self.productionSuggestionVC)
        fpc.track(scrollView: self.productionSuggestionVC.tableView)
        fpc.addPanel(toParent: self)
        fpc.hide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //    changeBottomViewState()
        cameraFeedManager.checkCameraConfigurationAndStartSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraFeedManager.stopSession()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Button Actions
    @IBAction func onClickResumeButton(_ sender: Any) {
        cameraFeedManager.resumeInterruptedSession { (complete) in
            
            if complete {
                self.resumeButton.isHidden = true
                self.cameraUnavailableLabel.isHidden = true
            } else {
                self.presentUnableToResumeSessionAlert()
            }
        }
    }
    
    func presentUnableToResumeSessionAlert() {
        let alert = UIAlertController(
            title: "Unable to Resume Session",
            message: "There was an error while attempting to resume session.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}
extension ViewController : FloatingPanelControllerDelegate {
    func floatingPanel(_ fpc: FloatingPanelController, contentOffsetForPinning trackingScrollView: UIScrollView) -> CGPoint {
        if productionItems.count > 0 {
            return CGPoint(x: 0, y: 300)
        } else {
            return CGPoint(x: 0, y: 0)
        }
    }
}

// MARK: CameraFeedManagerDelegate Methods
extension ViewController: CameraFeedManagerDelegate {
    
    func didOutput(pixelBuffer: CVPixelBuffer) {
        // Drop current frame if the previous frame is still being processed.
        guard !self.isInferenceQueueBusy else { return }
        
        inferenceQueue.async {
            self.isInferenceQueueBusy = true
            self.detect(pixelBuffer: pixelBuffer)
            self.isInferenceQueueBusy = false
        }
    }
    
    // MARK: Session Handling Alerts
    func sessionRunTimeErrorOccurred() {
        // Handles session run time error by updating the UI and providing a button if session can be manually resumed.
        self.resumeButton.isHidden = false
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        // Updates the UI when session is interrupted.
        if resumeManually {
            self.resumeButton.isHidden = false
        } else {
            self.cameraUnavailableLabel.isHidden = false
        }
    }
    
    func sessionInterruptionEnded() {
        // Updates UI once session interruption has ended.
        if !self.cameraUnavailableLabel.isHidden {
            self.cameraUnavailableLabel.isHidden = true
        }
        
        if !self.resumeButton.isHidden {
            self.resumeButton.isHidden = true
        }
    }
    
    func presentVideoConfigurationErrorAlert() {
        let alertController = UIAlertController(
            title: "Configuration Failed", message: "Configuration of camera has failed.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentCameraPermissionsDeniedAlert() {
        let alertController = UIAlertController(
            title: "Camera Permissions Denied",
            message:
                "Camera permissions have been denied for this app. You can change this by going to Settings",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            
            UIApplication.shared.open(
                URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    func detect(pixelBuffer: CVPixelBuffer) {
        result = self.objectDetectionHelper?.detect(frame: pixelBuffer)
        
        guard let displayResult = result else {
            return
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        DispatchQueue.main.async {
            // Draws the bounding boxes and displays class names and confidence scores.
            self.drawAfterPerformingCalculations(
                onDetections: displayResult.detections,
                withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
        }
    }
    
    /**
     This method takes the results, translates the bounding box rects to the current view, draws the bounding boxes, classNames and confidence scores of inferences.
     */
    func drawAfterPerformingCalculations(
        onDetections detections: [Detection], withImageSize imageSize: CGSize
    ) {
        
        self.overlayView.objectOverlays = []
        self.overlayView.setNeedsDisplay()
        
        guard !detections.isEmpty else {
            return
        }
        
        var objectOverlays: [ObjectOverlay] = []
        
        for detection in detections {
            
            guard let category = detection.categories.first else { continue }
            
            // Translates bounding box rect to current view.
            var convertedRect = detection.boundingBox.applying(
                CGAffineTransform(
                    scaleX: self.overlayView.bounds.size.width / imageSize.width,
                    y: self.overlayView.bounds.size.height / imageSize.height))
            
            if convertedRect.origin.x < 0 {
                convertedRect.origin.x = self.edgeOffset
            }
            
            if convertedRect.origin.y < 0 {
                convertedRect.origin.y = self.edgeOffset
            }
            
            if convertedRect.maxY > self.overlayView.bounds.maxY {
                convertedRect.size.height =
                self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
            }
            
            if convertedRect.maxX > self.overlayView.bounds.maxX {
                convertedRect.size.width =
                self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
            }
            
            let objectDescription = String(
                format: "\(category.label ?? "Unknown")")
            
            let displayColor = colors[category.index % colors.count]
            
            let size = objectDescription.size(withAttributes: [.font: self.displayFont])
            
            let objectOverlay = ObjectOverlay(
                name: objectDescription, borderRect: convertedRect, nameStringSize: size,
                color: displayColor,
                font: self.displayFont)
            
            addItem(item: SegmentioItem(title: objectDescription, image: nil))
            objectOverlays.append(objectOverlay)
        }
        
        // Hands off drawing to the OverlayView
        self.draw(objectOverlays: objectOverlays)
        
    }
    
    /** Calls methods to update overlay view with detected bounding boxes and class names.
     */
    func draw(objectOverlays: [ObjectOverlay]) {
        
        self.overlayView.objectOverlays = objectOverlays
        self.overlayView.setNeedsDisplay()
    }
    
}

// MARK: - Display handler function
//
/// TFLite model types
enum ModelType: CaseIterable {
    case efficientDetLite0
    case efficientDetLite1
    case efficientDetLite2
    case ssdMobileNetV1
    
    var modelFileInfo: FileInfo {
        switch self {
        case .ssdMobileNetV1:
            return FileInfo("ssd_mobilenet_v1", "tflite")
        case .efficientDetLite0:
            return FileInfo("efficientdet_lite0", "tflite")
        case .efficientDetLite1:
            return FileInfo("efficientdet_lite1", "tflite")
        case .efficientDetLite2:
            return FileInfo("efficientdet_lite2", "tflite")
        }
    }
    
    var title: String {
        switch self {
        case .ssdMobileNetV1:
            return "SSD-MobileNetV1"
        case .efficientDetLite0:
            return "EfficientDet-Lite0"
        case .efficientDetLite1:
            return "EfficientDet-Lite1"
        case .efficientDetLite2:
            return "EfficientDet-Lite2"
        }
    }
}

/// Default configuration
struct ConstantsDefault {
    static let modelType: ModelType = .efficientDetLite2
    static let threadCount = 1
    static let scoreThreshold: Float = 0.5
    static let maxResults: Int = 3
    static let theadCountLimit = 10
}
