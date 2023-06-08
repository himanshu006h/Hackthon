//
//  ScannerComponent.swift
//  Hackthon
//
//  Created by Himanshu Saraswat on 08/06/23.
//

import UIKit
import AVFoundation
import Combine

public enum PlaceHolderImage: String {
    case front
    case back
    var description: String {
        switch self {
        case .front: return "placeholder"
        case .back: return "backPlaceholder"
        }
    }
}

public protocol CoreScannerProtocol: AnyObject {
    func stateChange(changeDetails: ScannerOutputModel)
}

public class ScannerComponentViewController: CoreScanner {
    // MARK: Properties
    private let photoOutput = AVCapturePhotoOutput()
    open func codeValue(value: String) { }
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var constraintImageY: NSLayoutConstraint?
    @IBOutlet private weak var constraintImageX: NSLayoutConstraint?
    @IBOutlet private weak var constraintImageH: NSLayoutConstraint?
    @IBOutlet private weak var constraintImageW: NSLayoutConstraint?
    @IBOutlet private weak var lblTitle: UILabel?
    @IBOutlet private weak var lblSubTitle: UILabel?
    @IBOutlet private weak var btnflash: UIButton?
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var btnCapture: UIButton?
    public var delegate: CoreScannerProtocol?
    private var modelUI: ScannerModel?
    private var loadingModelUI: ScannerModel?
    private var compressionIndex: CGFloat?
    private var isCaptureInitiated = false
    
    // MARK: - View LifeCycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        openCamera()
        setUserInfo(model: modelUI)
        setUpInitialView()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpInitialView() {
        indicator.stopAnimating()
        delegate?.stateChange(changeDetails: ScannerOutputModel(state: .capture, documentData: nil))
    }
    
    public init(model: ScannerModel, loadingModel: ScannerModel, compressionIndex: CGFloat? = 0.0) {
        self.modelUI = model
        self.loadingModelUI = loadingModel
        self.compressionIndex = compressionIndex
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: ScannerComponentViewController.self))
    }
    // MARK: Camera Methods
    /// openCamera(): checking camera permission and initializing camera session
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            /// the user has already authorized to access the camera.
        case .authorized:
            self.setupCaptureSession()
            /// the user has not yet asked for camera access.
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                ///if user has granted to access the camera.
                if granted {
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    self.handleDismiss()
                }
            }
        default:
            /// something has wrong due to we can't access the camera.
            self.handleDismiss()
        }
    }
    /// Adding camera layer on custom view.
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                self.captureDevice = captureDevice
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
           // self.addFocusArea(cornerColor: .white)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = self.view.frame
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
            captureSession.startRunning()
            self.captureSession = captureSession
        }
    }
    
    private func handleDismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.closeCamera()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    /// Method will be executed, when user tap on capture button
    @IBAction func tapOnCapture(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first, captureDevice?.hasTorch == true {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    /// Method will be executed, when user tap on flash button
    @IBAction func tapOnFlash(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.toggleFlashPhotoMode()
    }
    
    // MARK: Set Image preview for user
    private func setImageView(image: UIImage) {
        isCaptureInitiated = true
        imageView?.image = image
        updateState(state: .loading,
                    imageData: image.jpegData(compressionQuality: compressionIndex ?? 0.0))
        setUserInfo(model: loadingModelUI)
    }
    
    //MARK: Back action
    @IBAction func onTapBackButton(_ sender: Any) {
        handleDismiss()
    }
    // MARK: Methods for update scanner
    ///  Scanner component can be updated form outside through 'updateScanner' method.
    ///  params: ScannerModel
    ///  title : Scanner heading, should be a localized string.
    ///  subTitle : Scanner Subheading, should be a localized string.
    ///  state: Can be -  capture, loading, success or failure
    public func updateScanner(model: ScannerModel) {
        setUserInfo(model: model)
        updateState(state: model.state, step: model.step)
    }
    
    private func setUserInfo(model: ScannerModel?) {
        if let details = model {
            lblTitle?.text = details.title
            lblSubTitle?.text = details.subtitle
            btnflash?.isHidden = !details.isFlashEnable
            btnCapture?.isHidden = !details.isCaptureEnable
        }
    }
    
    // MARK: update state
    private func updateState(state: DocumentState, imageData: Data? = nil, step: Int = 1) {
        resetImageView()
        switch state {
        case .loading:
            imageView?.isHidden = false
            indicator.startAnimating()
        case .success:
            imageView?.isHidden = false
        case .capture:
            isCaptureInitiated = false
            indicator.stopAnimating()
        default:
            break
        }
        
        delegate?.stateChange(changeDetails: ScannerOutputModel(state: state, documentData: imageData, step: step))
    }
    
    private func resetImageView() {
        imageView?.isHidden = true
    }
}
// MARK: Capture/Crop image
extension ScannerComponentViewController: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let previewImage = UIImage(data: imageData) else { return }
        setImageView(image: previewImage)
    }
    
    private func cropToPreviewLayer(from originalImage: UIImage, rect: CGRect) -> UIImage? {
        guard let cgImage = originalImage.cgImage else { return nil }
        
        /// This previewLayer is the AVCaptureVideoPreviewLayer which the resizeAspectFill and videoOrientation portrait has been set.
        let outputRect = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: (outputRect.origin.x * width),
                              y: (outputRect.origin.y * height),
                              width: (outputRect.size.width * width),
                              height: (outputRect.size.height * height))
        
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: 1.0,
                           orientation: originalImage.imageOrientation)
        }
        
        return nil
    }
}
