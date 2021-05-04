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
//  DGCAVerifier
//
//  Created by Yannick Spreen on 4/8/21.
//
//  https://www.raywenderlich.com/12663654-vision-framework-tutorial-for-ios-scanning-barcodes
//

import UIKit
import Vision
import AVFoundation
import SwiftCBOR

public protocol ScanVCDelegate {
  func hCertScanned(_:HCert)
}

open class ScanVC: UIViewController {
  var captureSession: AVCaptureSession?
  public var delegate: ScanVCDelegate?

  lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
    guard error == nil else {
      self.showAlert(withTitle: "Barcode error", message: error?.localizedDescription ?? "error")
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
      camView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    view.backgroundColor = .init(white: 0, alpha: 1)
    #if targetEnvironment(simulator)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.observationHandler(payloadS: "HC1:NCFOXN%TS3DHZN4HAF*PQFKKGTNA.Q/R8WRU2FCLK94QLZKC6L9..U4:OR$S:LC/GPWBILC9GGBYPLDXI25P-+R2YBV44PZB6H0CJ0%H0%P8. KOKGTM8$M8CNCBMAYL0C KPLIUM45FM4HGK3MGY8-JE6GQ2%KYZPUC5V620FLTCE 69B2A8AM0616DPO25QGMK9EXVSEEWK*R3T3+7A.N88J4R$F/MAITHP+P9R7.5CEESQ1EYBP.SS6QKU%O6QS03L0QIRR97I2HOAXL92L0B-S-*O/Y41FD7Y4L4OVIOE1MA.DI1IM.6%8WBMOT1K$7UIB81FD+.K.78/HL*DD2IHJSN37HMX3.7KO7JDKB:ZJ83BDPSCFTB.SBVTHOJ92KNNSQBJGZIGOJ6NJF0JEYI1DLNCKUCI5OI9YI:8DGCDQTU*GI%XGZFPDJRZBW84Q1ZMDKU TR%VE GMT2REKOT6PF7G8*30VVW*38OBJ3KMQJ4.FG4GMPVOQNC01Y3J$T7-HVISKO9QGOE$ZQ*UGKSJS6OA202-854")
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
        string: "Cancel",
        attributes: [
          .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
          .foregroundColor: UIColor.white,
        ]
      ), for: .normal
    )
    button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
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
        withTitle: "Cannot Find Camera",
        message: "There seems to be a problem with the camera on your device.")
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
          let _ = barcode
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
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
      withTitle: "Camera Permissions",
      message: "Please open Settings and grant permission for this app to use your camera."
    )
  }
}
