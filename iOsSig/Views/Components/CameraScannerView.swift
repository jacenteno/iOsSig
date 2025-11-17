import AVFoundation
import SwiftUI

protocol CameraScannerViewDelegate {
  func didScanBarcode(code: String)
}

struct CameraScannerView: UIViewControllerRepresentable {
  var delegate: CameraScannerViewDelegate

  func makeUIViewController(context: Context) -> ScannerViewController {
    let scannerViewController = ScannerViewController()
    scannerViewController.delegate = context.coordinator
    return scannerViewController
  }

  func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var parent: CameraScannerView
    var didFindCode = false

    init(_ parent: CameraScannerView) {
      self.parent = parent
    }

    func metadataOutput(
      _ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
      from connection: AVCaptureConnection
    ) {
      if !didFindCode, let metadataObject = metadataObjects.first {
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
          return
        }
        guard var stringValue = readableObject.stringValue else { return }

        // Handle UPC-A codes scanned as EAN-13
        // A 12-digit UPC-A code is often read as a 13-digit EAN-13 code with a leading '0'.
        // If the database expects the 12-digit code, we trim the leading zero.
        if readableObject.type == .ean13 && stringValue.count == 13 && stringValue.hasPrefix("0") {
          stringValue = String(stringValue.dropFirst())
        }

        didFindCode = true  // Set flag to true to prevent further scans

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        parent.delegate.didScanBarcode(code: stringValue)
      }
    }
  }
}

class ScannerViewController: UIViewController {
  var captureSession: AVCaptureSession!
  var previewLayer: AVCaptureVideoPreviewLayer!
  var delegate: AVCaptureMetadataOutputObjectsDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.black
    captureSession = AVCaptureSession()

    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    let videoInput: AVCaptureDeviceInput

    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      return
    }

    if captureSession.canAddInput(videoInput) {
      captureSession.addInput(videoInput)
    } else {
      failed()
      return
    }

    let metadataOutput = AVCaptureMetadataOutput()

    if captureSession.canAddOutput(metadataOutput) {
      captureSession.addOutput(metadataOutput)

      metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .upce]
    } else {
      failed()
      return
    }

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.layer.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)

    // Add Cancel Button
    let cancelButton = UIButton(type: .system)
    cancelButton.setTitle("Cancelar", for: .normal)
    cancelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    cancelButton.setTitleColor(.white, for: .normal)
    cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    cancelButton.layer.cornerRadius = 10
    cancelButton.addTarget(self, action: #selector(dismissScanner), for: .touchUpInside)

    view.addSubview(cancelButton)
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      cancelButton.trailingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      cancelButton.widthAnchor.constraint(equalToConstant: 100),
      cancelButton.heightAnchor.constraint(equalToConstant: 40),
    ])

    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
    }
  }

  @objc func dismissScanner() {
    self.dismiss(animated: true, completion: nil)
  }

  func failed() {
    let ac = UIAlertController(
      title: "Scanning not supported",
      message:
        "Your device does not support scanning a code from an item. Please use a device with a camera.",
      preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    captureSession = nil
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if captureSession?.isRunning == false {
      DispatchQueue.global(qos: .background).async {
        self.captureSession.startRunning()
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if captureSession?.isRunning == true {
      captureSession.stopRunning()
    }
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
}
