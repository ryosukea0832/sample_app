import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // カメラの許可を確認する
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // カメラの使用が許可された
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                }
            }
        case .authorized:
            // カメラの使用が許可された
            setupCaptureSession()
        case .denied, .restricted:
            // カメラの使用が拒否された
            let alert = UIAlertController(title: "カメラの使用が拒否されました", message: "設定アプリでカメラの使用を許可してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        @unknown default:
            fatalError("AVCaptureDevice authorizationStatus is not defined.")
        }
    }

    func setupCaptureSession() {
        // カメラデバイスを取得する
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("カメラデバイスが取得できませんでした")
        }
        
        // キャプチャーセッションを作成する
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
        
        // 入力を設定する
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(videoInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // 出力を設定する
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        // プレビューレイヤーを作成する
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        // キャプチャーセッションを開始する
        captureSession.startRunning()
    }
    
    // QRコードを読み取ったときに呼ばれる
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue,
              metadataObject.type == .qr else {
            return
        }
        
        // キャプチャーセッションを停止する
        captureSession
    }
}