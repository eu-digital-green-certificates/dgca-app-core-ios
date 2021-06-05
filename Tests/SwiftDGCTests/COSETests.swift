//
//  File.swift
//  
//
//  Created by Steffen on 05.06.21.
//
import XCTest
import Foundation
@testable
import SwiftDGC


extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

final class COSETests: XCTestCase {
    
  func extractParameter(hex: String,header: inout String,kid : inout [UInt8], body: inout String){
    let cosedata = Data(hexString:hex).unsafelyUnwrapped;
    
    header = CBOR.header(from: cosedata)?.toString() ?? "";
    body = CBOR.payload(from: cosedata)?.toString() ?? "";
    kid = CBOR.kid(from: cosedata) ?? [0];
  }
    
    
  func testCoseArray()
  {
    let hexCOSE = "844da201260448991c5aa728b1489da0590147a401624c55041a60df3468061a60b7a768390103a101a4617481a96263697630312f4c552f3333384e52504a5259394f314f23363062636f624c55626973724d494e4953545259204f46204845414c5448626e6d77416c6c706c657820323031392d6e436f5620617373617962736374323032312d30362d30325431303a30393a30305a627463781d546573742055746f706961204c2d32353531204c7578656d626f7572676274676938343035333930303662747269323630343135303030627474684c50363436342d3463646f626a313936372d30332d3031636e616da462666e745370c3a963696d656e2d4d75737465726d616e6e62676e724a65616e2d506965727265204d617263656c63666e747353504543494d454e3c4d55535445524d414e4e63676e74724a45414e3c5049455252453c4d415243454c6376657265312e302e3058403e501d34503043be09f23efb0446dbbffe924c6024df7f6f6c3685198f9dab709fabebeb8f7afe3b5584bdee2c6862dda39bd6053302180ad76ce132fc9fe853";
    
    var header = "";
    var kid = [UInt8(0)];
    var body = "";
    
    extractParameter(hex: hexCOSE, header: &header, kid: &kid, body: &body)
    
    var jsonHeader=header.asJSONDict;
 
    if(jsonHeader["1"] == nil){ XCTAssert(false)}
    else {XCTAssert(jsonHeader["1"] as! Int8 == -7);};
    if(jsonHeader["4"] == nil){ XCTAssert(false)}
    else {XCTAssert(Data(bytes:(jsonHeader["4"] as! [UInt8])).hexString == Data(bytes:kid).hexString);}
    XCTAssert( Data(bytes:kid).base64EncodedString() == "mRxapyixSJ0=");
    
    if (jsonHeader["4"] == nil){ XCTAssert(false)}
    else
    {XCTAssert( Data(bytes:(jsonHeader["4"] as! [UInt8])).base64EncodedString() == "mRxapyixSJ0=")}
    
    let jsonPayload = body.asJSONDict;
    XCTAssert(jsonPayload["-260"] != nil);
    let hCertMap = jsonPayload["-260"] as! Dictionary<String,AnyObject?>;
    let hCert = hCertMap["1"] as! Dictionary<String,AnyObject?>;
    XCTAssert(hCert["dob"] != nil);
    XCTAssert(hCert["nam"] != nil);
    XCTAssert(hCert["t"] != nil);
  }
    
 func testCoseCWT()
 {
    let hexCOSE = "d83dd2844da2012604485f74910195c5cecba0590104a401625345041a611cfc5f061a60a6555f390103a101a4617681aa626369782755524e3a555643493a30313a53453a45484d2f313030303030303234474935484d475a4b534d5362636f62534562646e026264746a323032312d30332d3138626973765377656469736820654865616c7468204167656e6379626d616d4f52472d313030303330323135626d706c45552f312f32312f313532396273640262746769383430353339303036627670674a30374258303363646f626a313935382d31312d3131636e616da462666e6a4cc3b676737472c3b66d62676e654f7363617263666e746a4c4f45565354524f454d63676e74654f534341526376657265312e302e30584016c55b3d4beb8d83742060530f0e7a43611879b635dcc8c8e87a05af98749f65f034e049e786af0cd649623e213833d79c6ac92ef6e983ca170917c007768363"
    
    var header = "";
    var kid = [UInt8(0)];
    var body = "";
    
    extractParameter(hex: hexCOSE, header: &header, kid: &kid, body: &body)
    var jsonHeader=header.asJSONDict;
  
    XCTAssert(jsonHeader["1"] as! Int8 == -7);
    XCTAssert(Data(bytes:(jsonHeader["4"] as! [UInt8])).hexString == Data(bytes:kid).hexString);
    XCTAssert( Data(bytes:kid).base64EncodedString() == "X3SRAZXFzss=");
    XCTAssert( Data(bytes:(jsonHeader["4"] as! [UInt8])).base64EncodedString() == "X3SRAZXFzss=")
    
    let jsonPayload = body.asJSONDict;
    
    XCTAssert(jsonPayload["-260"] != nil);
    let hCertMap = jsonPayload["-260"] as! Dictionary<String,AnyObject?>;
    let hCert = hCertMap["1"] as! Dictionary<String,AnyObject?>;
    XCTAssert(hCert["dob"] != nil);
    XCTAssert(hCert["nam"] != nil);
    XCTAssert(hCert["v"] != nil);
 }

 func testCoseSign1()
 {
    let hexCOSE="d2844da20448d919375fc1e7b6b20126a0590124a4041a61817ca0061a60942ea001624154390103a101a4617681aa62646e01626d616d4f52472d3130303033303231356276706a313131393330353030356264746a323032312d30322d313862636f624154626369783075726e3a757663693a30313a41543a313038303738343346393441454530454535303933464243323534424438313350626d706c45552f312f32302f313532386269736e424d5347504b20417573747269616273640262746769383430353339303036636e616da463666e74754d5553544552465241553c474f455353494e47455262666e754d7573746572667261752d47c3b6c39f696e67657263676e74684741425249454c4562676e684761627269656c656376657265312e302e3063646f626a313939382d30322d3236584081da84d4e91916d68aa0708035827435e57b75bb1902633801759865c448fb417b0f7a4db7f0c8edf8f500b38662ff576807a251478d948703df05a8d2033a70";
    
    var header = "";
    var kid = [UInt8(0)];
    var body = "";
    
    extractParameter(hex: hexCOSE, header: &header, kid: &kid, body: &body)
    var jsonHeader=header.asJSONDict;
    XCTAssert(jsonHeader["1"] as! Int8 == -7);
    XCTAssert(Data(bytes:(jsonHeader["4"] as! [UInt8])).hexString == Data(bytes:kid).hexString);
    XCTAssert( Data(bytes:kid).base64EncodedString() == "2Rk3X8HntrI=");
    XCTAssert( Data(bytes:(jsonHeader["4"] as! [UInt8])).base64EncodedString() == "2Rk3X8HntrI=")
 
    let jsonPayload = body.asJSONDict;
    
    XCTAssert(jsonPayload["4"] as! ULONG == 1635876000);
    XCTAssert(jsonPayload["-260"] != nil);
    
    let hCertMap = jsonPayload["-260"] as! Dictionary<String,AnyObject?>;
    let hCert = hCertMap["1"] as! Dictionary<String,AnyObject?>;
    XCTAssert(hCert["dob"] != nil);
    XCTAssert(hCert["nam"] != nil);
    XCTAssert(hCert["v"] != nil);
 }
    
    func testCoseWithKidInUnProtectedHeader()
    {
        let hexCOSE="d28443a10126a104480c4b15512be9140159012ca401624445061a60b29429041a61f39fa9390103a101a4617481a9626369782f55524e3a555643493a303144452f495a3132333435412f3543574c553132524e4f4239525853454f5036464738235762636f62444562697374526f62657274204b6f63682d496e737469747574627467693834303533393030366274746a4c503231373139382d3362736374323032312d30352d33305431303a31323a32325a62647274323032312d30352d33305431303a33303a31355a6274726932363034313530303062746375546573747a656e7472756d204bc3b66c6e2048626663646f626a313936342d30382d3132636e616da462666e6a4d75737465726d616e6e62676e654572696b6163666e746a4d55535445524d414e4e63676e74654552494b416376657265312e302e30584060c38db6dc700820649ee9e511a0dad56143f69ced3986f7393f77d29ee01f086099a49743aabda650c3c73a74e81ebd4afbb1dd67511b7372d9e0d36bc1259e";
        
        var header = "";
        var kid = [UInt8(0)];
        var body = "";
        
        extractParameter(hex: hexCOSE, header: &header, kid: &kid, body: &body)
        var jsonHeader=header.asJSONDict;
        XCTAssert(jsonHeader["1"] as! Int8 == -7);
        XCTAssert(jsonHeader.count==1);
        XCTAssert( Data(bytes:kid).base64EncodedString() == "DEsVUSvpFAE=");
        XCTAssert(jsonHeader.index(forKey: "4") == nil)
        
        let jsonPayload = body.asJSONDict;
        
        XCTAssert(jsonPayload["-260"] != nil);
        
        let hCertMap = jsonPayload["-260"] as! Dictionary<String,AnyObject?>;
        let hCert = hCertMap["1"] as! Dictionary<String,AnyObject?>;
        XCTAssert(hCert["dob"] != nil);
        XCTAssert(hCert["nam"] != nil);
        XCTAssert(hCert["t"] != nil);
    }
}
