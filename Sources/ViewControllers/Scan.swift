/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-app-core-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//
//  ViewController.swift
//
//
//  Created by Yannick Spreen on 4/8/21.
//
//  https://www.raywenderlich.com/12663654-vision-framework-tutorial-for-ios-scanning-barcodes
//

#if os(iOS)
import UIKit
import Vision
import AVFoundation
import SwiftCBOR

public protocol ScanVCDelegate: AnyObject {
  func hCertScanned(_:HCert)
}

open class ScanVC: UIViewController {
  var captureSession: AVCaptureSession?
  public weak var delegate: ScanVCDelegate?

  lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
    guard error == nil else {
      self.showAlert(withTitle: l10n("err.barcode"), message: error?.localizedDescription ?? l10n("err.misc"))
      return
    }
    self.processClassification(request)
  }

  var camView: UIView!

  open override func viewDidLoad() {
    super.viewDidLoad()

    camView = UIView(frame: .zero)
    camView.translatesAutoresizingMaskIntoConstraints = false
    camView.isUserInteractionEnabled = false
    view.addSubview(camView)
    NSLayoutConstraint.activate([
      camView.topAnchor.constraint(equalTo: view.topAnchor),
      camView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      camView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      camView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    view.backgroundColor = .init(white: 0, alpha: 1)
    #if targetEnvironment(simulator)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // swiftlint:disable:next line_length
      self.observationHandler(payloadS: "HC1:6BF870*90T9WTWGSLKC 4159/X621AD%1Q7J-AB3XK4F3C0FY5B2F3:2JT5B1JC X8Y50.FK8ZKO/EZKEZ96446C56..DX%DZJC:.D9Z9*9FW.C5WEMY9 7BI3DXJD7%E7WE/KECEC:.DI3DCWE.Y92OAGY8MY9L+9JPCT3E5JDOA73467463W5RG67:EDOL9WEQDD+Q6TW6FA7C466KCN9E%961A69L6QW6B46.JCP9EJY8L/5M/5546.96VF6.JCBECB1A-:8$96646746L%6KB7FVC*70KQE*70LVC6JD846Y96B463W5307UPC1JCWY8+ED:DCWJC0FD4:473DSDDF+ALG7$X87Y9U09F:6D57EA6*H9:L6HNAE1AF57Y6BWM8YG86:627B0BVMC0ZISGE1RQKM20CPSE/6%JHPE99KN/D7.%29L9AAA%ROUFB6/D3/BZOQ.LJE.IF/9 Y751Q0+MM4ATR1MAJGMA--RSV3R78QHE")
    }
    #else
    captureSession = AVCaptureSession()
    checkPermissions()
    setupCameraLiveView()
    #endif
    SquareViewFinder.create(from: self)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    captureSession?.stopRunning()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    captureSession?.startRunning()
  }

  public func createBackButton() {
    let button = UIButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .clear
    button.setAttributedTitle(
      NSAttributedString(
        string: l10n("btn.cancel"),
        attributes: [
          .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
          .foregroundColor: UIColor.white
        ]
      ), for: .normal
    )
    button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0)
    ])
  }

  @IBAction
  func cancel() {
    navigationController?.popViewController(animated: true)
  }
}

extension ScanVC {
  private func checkPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [self] granted in
        if !granted {
          self.showPermissionsAlert()
        }
      }
    case .denied, .restricted:
      showPermissionsAlert()
    default:
      return
    }
  }

  private func setupCameraLiveView() {
    captureSession?.sessionPreset = .hd1280x720

    let videoDevice = AVCaptureDevice
      .default(.builtInWideAngleCamera, for: .video, position: .back)

    guard
      let device = videoDevice,
      let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
      captureSession?.canAddInput(videoDeviceInput) == true
    else {
      showAlert(
        withTitle: l10n("err.cam"),
        message: l10n("err.cam.desc"))
      return
    }

    captureSession?.addInput(videoDeviceInput)

    let captureOutput = AVCaptureVideoDataOutput()
    captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
    captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
    captureSession?.addOutput(captureOutput)

    configurePreviewLayer()
  }

  func processClassification(_ request: VNRequest) {
    guard let barcodes = request.results else { return }
    DispatchQueue.main.async { [self] in
      if captureSession?.isRunning == true {
        camView.layer.sublayers?.removeSubrange(1...)

        for barcode in barcodes {
          guard
            let potentialQRCode = barcode as? VNBarcodeObservation,
            [.Aztec, .QR, .DataMatrix].contains(potentialQRCode.symbology),
            potentialQRCode.confidence > 0.9
          else { return }

          print(potentialQRCode.symbology)
          observationHandler(payloadS: potentialQRCode.payloadStringValue)
        }
      }
    }
  }

  func observationHandler(payloadS: String?) {
    if let hCert = HCert(from: payloadS ?? "") {
      delegate?.hCertScanned(hCert)
    }
  }

}

extension ScanVC: AVCaptureVideoDataOutputSampleBufferDelegate {
  public func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

    let imageRequestHandler = VNImageRequestHandler(
      cvPixelBuffer: pixelBuffer,
      orientation: .right
    )

    do {
      try imageRequestHandler.perform([detectBarcodeRequest])
    } catch {
      print(error)
    }
  }
}

extension ScanVC {
  private func configurePreviewLayer() {
    guard let captureSession = captureSession else {
      return
    }
    let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    cameraPreviewLayer.videoGravity = .resizeAspectFill
    cameraPreviewLayer.connection?.videoOrientation = .portrait
    cameraPreviewLayer.frame = view.frame
    camView.layer.insertSublayer(cameraPreviewLayer, at: 0)
  }

  private func showAlert(withTitle title: String, message: String) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alertController, animated: true)
    }
  }

  private func showPermissionsAlert() {
    showAlert(
      withTitle: l10n("err.cam.perm"),
      message: l10n("err.cam.perm.desc")
    )
  }
}
#endif
