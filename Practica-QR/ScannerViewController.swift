import AVFoundation
import UIKit


protocol ScannerDelegate {
    func receivingBarcode(code:String)
}

class ScannerViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    private var focusImage: UIImage?
    
    var delegate: ScannerDelegate?
    
    lazy private var qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = focusImage ?? UIImage(named: "scan_onboarding")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy private var previewViewCamera: UIView = {
       let view = UIView()
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "GrayPrimary")
        view.addSubview(previewViewCamera)
        view.addSubview(qrCodeImageView)
        configurationAVSession()
        setupConstraints()
    }
    
    private func configurationAVSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.pdf417]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewViewCamera.layer.addSublayer(previewLayer)
        captureSession.startRunning()
       
        DispatchQueue.main.async {
            self.previewLayer.frame = self.previewViewCamera.layer.bounds
        }
    }
    
    private func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.topItem?.backButtonTitle = "Escaneá el código de tu DNI"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = UIColor(named: "Gray900")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func found(code: String) {
        delegate?.receivingBarcode(code:code)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            previewViewCamera.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0 ),
            previewViewCamera.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            previewViewCamera.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            previewViewCamera.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            previewViewCamera.heightAnchor.constraint(equalToConstant: 196),
            
            qrCodeImageView.centerXAnchor.constraint(equalTo: previewViewCamera.centerXAnchor),
            qrCodeImageView.centerYAnchor.constraint(equalTo: previewViewCamera.centerYAnchor),
        ])
    }
}


extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if metadataObjects.count == 0 {
            print("No QR code is detected")
            return
        }

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                print("no lee QR")
                return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if  metadataObject.type == .pdf417 {
                found(code: stringValue)
            }
        }
        
        dismiss(animated: true)
    }
}
