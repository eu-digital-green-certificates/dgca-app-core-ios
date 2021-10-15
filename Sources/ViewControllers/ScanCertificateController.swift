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

public protocol ScanCertificateDelegate: AnyObject {
  func scanController(_ controller: ScanCertificateController, didScanCertificate certificate: HCert)
  func disableBackgroundDetection()
  func enableBackgroundDetection()
}

open class ScanCertificateController: UIViewController {
    
  private enum Constants {
    static let userDefaultsCountryKey = "UDCountryKey"
  }

  var captureSession: AVCaptureSession?
  public weak var delegate: ScanCertificateDelegate?
  public let applicationType: AppType = .verifier
  
  lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
    guard error == nil else {
      self.showAlert(withTitle: l10n("err.barcode"), message: error?.localizedDescription ?? l10n("err.misc"))
      return
    }
    self.processClassification(request)
  }

  var camView: UIView!
  private let countryCodeView = UIPickerView()
  private let countryCodeLabel = UILabel()
  private var countryItems: [CountryModel] = []
  
  //Selected country code
  private var selectedCounty: CountryModel? {
    set {
      let userDefaults = UserDefaults.standard
      do {
        try userDefaults.setObject(newValue, forKey: Constants.userDefaultsCountryKey)
      } catch {
        print(error.localizedDescription)
      }
    }
    get {
      let userDefaults = UserDefaults.standard
      do {
        let selected = try userDefaults.getObject(forKey: Constants.userDefaultsCountryKey, castTo: CountryModel.self)
        return selected
      } catch {
        print(error.localizedDescription)
        return nil
      }
    }
  }

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
    
    countryCodeView.translatesAutoresizingMaskIntoConstraints = false
    countryCodeView.backgroundColor = .white.withAlphaComponent(0.8)
    countryCodeView.dataSource = self
    countryCodeView.delegate = self
    countryCodeView.isHidden = true
    view.addSubview(countryCodeView)

    NSLayoutConstraint.activate([
      countryCodeView.leftAnchor.constraint(equalTo: view.leftAnchor),
      countryCodeView.rightAnchor.constraint(equalTo: view.rightAnchor),
      countryCodeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      countryCodeView.heightAnchor.constraint(equalToConstant: 150)
    ])

    
    countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false
    countryCodeLabel.backgroundColor = .clear
    countryCodeLabel.text = l10n("scanner.select.country")
    countryCodeLabel.textAlignment = .center
    countryCodeView.addSubview(countryCodeLabel)

    NSLayoutConstraint.activate([
      countryCodeLabel.leftAnchor.constraint(equalTo: countryCodeView.leftAnchor),
      countryCodeLabel.rightAnchor.constraint(equalTo: countryCodeView.rightAnchor),
      countryCodeLabel.topAnchor.constraint(equalTo: countryCodeView.topAnchor),
      countryCodeLabel.heightAnchor.constraint(equalToConstant: 30)
    ])
    
    view.backgroundColor = .init(white: 0, alpha: 1)
    #if targetEnvironment(simulator)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // swiftlint:disable:next line_length
      self.observationHandler(payloadS: "HC1:6BFA70$90T9WTWGSLKC 4X7923S%CA.48Y+6/AB3XK5F3 026003F3RD6Z*B1JC X8Y50.FK8ZKO/EZKEZ967L6C56..DX%DZJC2/D:+9 QE5$CLPCG/D0.CHY8ITAUIAI3DG8DXFF 8DXEDU3EI3DAWE1Z9CN9IB85T9JPCT3E5JDOA73467463W5-A67:EDOL9WEQDD+Q6TW6FA7C466KCK9E2H9G:6V6BEM6Q$D.UDRYA 96NF6L/5QW6307B$D% D3IA4W5646946%96X47XJC$+D3KC.SCXJCCWENF6OF63W5CA7746WJCT3E0ZA%JCIQEAZAWJC0FD6A5AIA%G7X+AQB9F+ALG7$X85+8+*81IA3H87+8/R8/A8+M986APH9$59/Y9WA627B873 3K9UD5M3JFG.BOO3L-GE828UE0T46/*JSTLE4MEJRX797NEXF5I$2+.LGOJXF24D2WR9 W8WQT:HHJ$7:TKP2RT+J:G4V5GT7E")
//        HC1:NCF/Y43088D0000MIU%LJJKDO51FY0TZGD7FU5WG72 73*ZKHJPMH2FTF-6FOZ31:911K-441526+6UNAB1J48K%7TORRP018O3K32IF8H7R7ZV4MS FR2SPQ-DI7P%B7E6U$/76OATWJ%QAJ5LE.IF240213*JC/EP6C98IJ9HZ QX-53IGJ8KQR3 THF%B5 5JB7/HVIZ5XZ7JXABM1ZP1JM0BJQXZUG2EI782X9GU6OKNQS8GQCNRCQA4WGAL35TCL5R41C57W46+E J4KJDU4R 00XZPPNP0QMAVG0.TYQGBKOF1G%TKFB62.O/Y807UI%A4/EHS8K%O9SS017J47V5WKXQKEJEWTU8SLMIDU7RR19XK54RV$9ELJQTAFP1858EC65QH5EQB:N8ARAQA23EG7T% NI-TVZH:$5/GH+PC0-DKIT2F6.2OK:U%9T$UKMCLU4DGYT3TNBZMN1WLORN:UOQBI05 9ME8PQBORKDM4
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

  public func createCancelButton() {
    let button = UIButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .clear
    button.setAttributedTitle(NSAttributedString(string: l10n("btn.cancel"),
        attributes: [
        .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: UIColor.white
      ]), for: .normal)
    button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0)
    ])
  }

  @IBAction func cancel() {
      self.dismiss(animated: true, completion: nil)
  }
}

extension ScanCertificateController {
  private func checkPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      delegate?.disableBackgroundDetection()
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        self?.delegate?.enableBackgroundDetection()
        if !granted {
          self?.showPermissionsAlert()
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
          var potentialQRCode: VNBarcodeObservation
          if #available(iOS 15, *) {
            guard
              let potentialCode = barcode as? VNBarcodeObservation,
              [.Aztec, .QR, .DataMatrix].contains(potentialCode.symbology),
              potentialCode.confidence > 0.9
            else { return }
            potentialQRCode = potentialCode
          } else {
            guard
              let potentialCode = barcode as? VNBarcodeObservation,
              [.aztec, .qr, .dataMatrix].contains(potentialCode.symbology),
              potentialCode.confidence > 0.9
            else { return }
            potentialQRCode = potentialCode
          }

          print(potentialQRCode.symbology)
          observationHandler(payloadS: potentialQRCode.payloadStringValue)
        }
      }
    }
  }

  func observationHandler(payloadS: String?) {
    if var hCert = HCert(from: payloadS ?? "", applicationType: applicationType) {
      hCert.ruleCountryCode = getSelectedCountryCode()
      delegate?.scanController(self, didScanCertificate: hCert)
    }
  }
}

extension ScanCertificateController: AVCaptureVideoDataOutputSampleBufferDelegate {
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection) {
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

extension ScanCertificateController {
  private func configurePreviewLayer() {
    guard let captureSession = captureSession else { return }
    
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

extension ScanCertificateController: UIPickerViewDataSource, UIPickerViewDelegate {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if countryItems.count == 0 { return 1 }
    return countryItems.count
  }
  
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if countryItems.count == 0 { return l10n("scaner.no.countrys") }
    return countryItems[row].name
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.selectedCounty = countryItems[row]
  }
}

extension ScanCertificateController {
  public func setListOfRuleCounties(list: [CountryModel]) {
    self.countryItems = list
    self.countryCodeView.reloadAllComponents()
    guard self.countryItems.count > 0 else { return }
    
    if let selected = self.selectedCounty,
      let indexOfCountry = self.countryItems.firstIndex(where: {$0.code == selected.code}) {
        countryCodeView.selectRow(indexOfCountry, inComponent: 0, animated: false)
    } else {
      self.selectedCounty = self.countryItems.first
      countryCodeView.selectRow(0, inComponent: 0, animated: false)
    }
  }
  
  public func setVisibleCountrySelection(visible: Bool) {
    self.countryCodeView.isHidden = !visible
  }
  
  public func getSelectedCountryCode() -> String? {
    return self.selectedCounty?.code
  }
}
#endif
