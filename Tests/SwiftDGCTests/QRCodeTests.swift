//
//  Created by Steffen on 15.06.21.
//

import XCTest
import Foundation
@testable
import SwiftDGC
import SwiftyJSON



final class QRCodeTests: XCTestCase {
    
   func testPLCode()
   {
      HCert.publicKeyStorageDelegate = self;
    
      let hCert = "HC1:6BFOXN%TS3DH1QG9WA6H98BRPRHO DJS4F3S-%2LXKQGLAVDQ81LO2-36/X0X6BMF6.UCOMIN6R%E5UX4795:/6N9R%EPXCROGO3HOWGOKEQBKL/645YPL$R-ROM47E.K6K8I115DL-9C1QD+82D8C+ CH8CV9CA$DPN0NTICZU80LZW4Z*AK.GNNVR*G0C7PHBO33/X086BTTTCNB*UJHMJ8J3HONNQN09B5PNVNNWGJZ730DNHMJSLJ*E3G23B/S7-SN2H N37J3 QTULJ7CB3ZC6.27AL4%IY.IQH5YRT5*K51T 1DT 456L X4CZKHKB-43.E3KD3OAJ/9TL4T1C9 UP IPGTUI7FKQU2N1L8VFLU9WU.B9 UPYR181A0+P8V7/JA--J/XTQWE/PEBLEH-BY.CECH$6KJEM*PC9JAU-BZ8ERJCS0DUMQI+O1-ST*QGTA4W7.Y7G+SB.V Q5NN9TJ1TM8554.8EW E2NS6F9$J3-MQPSUB*H1EI+TUN73 39EX4165ABSXFB487V*K9J8UJC08H3N7T:DAIJC8K8T3TCF*6P.OB9Q721UJ+K.OJ4EW/S1*13PNG"
  
    let cert=HCert.init(from: hCert)
    XCTAssert( cert != nil)
    XCTAssert(cert?.validityFailures.count == 0)
   }
    
    func testBGCode(){
        
      HCert.publicKeyStorageDelegate = self;
        var hCert = "HC1:NCFOXN*TS0BI$ZDYSHIAL*ECH 8S021091JDNDC3LE84DIJ9CIE7-78WA46VGOU:ZH6I1%4JF 2K%5PK9CZLEQ56SP.E5BQ95ZM3763LED6N%ZEXE6%HULAV**M82F93I6*6 %6PK9B/0MCIMMISVDG8C5DL-9C1QDW33C8C0U09B91*KEDC6J0GJ4JXGHHBIWB.80XUTKQS7DS2*N.SSBNKA.G.P6A8IM%OVNIA KZ*U0I1-I0*OC6H0UWM2NISGH*BSPRAFTI/T1A.PECGX%EN+P.Y0/9TL4T.B9GYPNIN:EWD QZQHU*PH86DROI%KXYNYKTKK1Y R/03YVBO7L.CCP7A+5S*T08JFHAIN95+Y5 P4KDO+*OH:7SA7G6MS/5U*O3DRE6P6/QVHPOVQJT5FT5D75W9AV88G64KE809KV+EYMOL61I/JTYJJP66IL/XCBJBJ3DJGOBIG2%5AM4T/JKATN5NN7TA9QB.PY38PMKIQJ8:P-TVS L$W8LOAFXUWWLP-RO1E550%/OE5"
      let cert=HCert.init(from: hCert)
      XCTAssert( cert != nil)
      XCTAssert(cert?.validityFailures.count == 0)
    }
    
    func testNOCode(){
        
        HCert.publicKeyStorageDelegate = self;
        var hCert = "HC1:NCF780+80T9WTWGSLKC 4J9965QTH121L3LCFBB*A3*70M+9FN03DCZSJWY0JAC4+UD97TK0F90KECTHGWJC0FDVQ4AIA%G7X+AQB9746VG7W0AV+AWM96X6FCAJY8-F6846W%6V%60ZAKB7UPCBJCR1AFVC*70LVC6JD846Y96A464W5.A6+EDL8F9-98LE* CMEDM-DXC9 QE-ED8%EDZCX3E$34Z$EXVD-NC%69AECAWE.JCBECB1A-:8$966469L6OF6VX6Q$D.UDRYA 96NF6L/5SW6Y57KQEPD09WEQDD+Q6TW6FA7C466KCN9E%961A6DL6FA7D46JPCT3E5JDMA7346D463W5Z57..DX%DZJC7/DCWO3/DTVDD5D9-K3VCI3DU2DGECUGDK MLPCG/D2SDUWGR095Y8DWO0IAMPCG/DU2DRB8SE9VXI$PC5$CUZCZ$5Y$527B0DR-NGD9R696*KOX$N3E5G-ER 5ZOHMLQW4O-1M1I0OHE1SVLZNT361*ED+E7ICER5-HMV*47OO$5J+%Q8KU7+G275H7TDX9R+GZWG"
      let cert=HCert.init(from: hCert)
      XCTAssert( cert != nil)
      XCTAssert(cert?.validityFailures.count == 0)
    }
    
    func testNormalCode()
    {
        HCert.publicKeyStorageDelegate = self;
        var hCert = "HC1:NCFOXNEG2NBJ5*H:QO-.OMBN+XQ99N*6RFS5*TCVWBM*4ODMS0NSRHAL9.4I92P*AVAN9I6T5XH4PIQJAZGA2:UG%U:PI/E2$4JY/KB1TFTJ:0EPLNJ58G/1W-26ALD-I2$VFVVE.80Z0 /KY.SKZC*0K5AFP7T/MV*MNY$N.R6 7P45AHJSP$I/XK$M8TH1PZB*L8/G9HEDCHJ4OIMEDTJCJKDLEDL9CVTAUPIAK29VCN 1UTKFYJZJAPEDI.C$JC7KDF9CFVAPUB1VCSWC%PDMOLHTC$JC3EC66CTS89B9F$8H.OOLI7R3Y+95AF3J6FB5R8QMA70Z37244FKG6T$FJ7CQRB0R%5 47:W0UFJU.UOJ98J93DI+C0UEE-JEJ36VLIWQHH$QIZB%+N+Y2AW2OP6OH6XO9IE5IVU$P26J6 L6/E2US2CZU:80I7JM7JHOJKYJPGK:H3J1D1I3-*TW CXBD+$3PY2C725SS+TDM$SF*SHVT:5D79U+GC5QS+3TAQS:FLU+34IU*9VY-Q9P9SEW-AB+2Q2I56L916CO8T C609O1%NXDU-:R4TICQA.0F2HFLXLLWI8ZU53BMQ2N U:VQQ7RWY91SV2A7N3WQ9J9OAZ00RKLB2"
      let cert=HCert.init(from: hCert)
      XCTAssert( cert != nil)
      XCTAssert(cert?.validityFailures.count == 0)
    }
    
    func testLVNulls()
    {
        HCert.publicKeyStorageDelegate = self;
        var hCert = "HC1:NCF7%AW08+J2DO3K6CLQHRU3J.KTWO$I8MOFG:NS4FC7SCJK3W8*LPCL9 WI6RAPEUJO9YOI5 IL8R:UE/U0T+2YLKHGJL.K$F70SK27WG%GH 1LI8BSQ.1M%BOL%VOOM*D3T2TG+NG6DZBDMDR.YFKCLDQ1/04O%AP7DMJN6PR4:V$OBETBF$HJ:3GXBNZ6I1H6NCZ81ZZI.SME.SP0RW$S$.KV2VKEB5D3AXEB31HGJR9FWCD%6PP75MJR*3KUHOJS58U5D$CT9U%VEV3SHFPEE0/U7%SVA/VZJ45HMHGLSB1VJR$P2EZR+1POJEO/0LHRWWGPARMO8Z5CGAGPR9.KDQ5Q0:TSLGDVG18DAPNNXN289*WQ:Q7DTJOABHWDZMTCO6D14F66T25A/7S4KJEBUZP-XS-DK4QFJ 45PEOG1KRJ/00A$PWC1/D1G30XUK.WNYPK8M8PC5AZM1XK/A2UWSA5OSU7$VFQ64$.2 3T+60VD4+WRCWTI%FOUVMXQ$VN/1EL.F4:NW 3T LA28 4LEOD7-L0ZENBPO6D-DW*VLM5BE4H7CSD7O%:T0%V*RS7$TTOTUQV44VR4AV7JGPESYHF2"
      let cert=HCert.init(from: hCert)
      XCTAssert( cert != nil)
      XCTAssert(cert?.validityFailures.count == 0)
    }
    
    func testHUCode()
    {
        var hCert = "HC1:NCFTW2JY7ZVQ/20LZC9%BW561NM7 QZLAQ7Q%0KO9T6W4A91IZO W8S%RFT3Z7RVC4Y62+I0WS0.46FE5NJ4H+8WHTF QWA4+H9J12 K08E5%T50CHOHGM8E90O0%92UFLJTR+KUTRPI8XPCSQU1OU1.KSVJGBF+KQUFN4T7BTT 0P9VJN0WL1KYRNZ-C99UNPA*T9VBF+YT/RG1VRYFQ0%G$E6IO0552W2NQLJZ368JDC$HDBMQVDU21DJ4SB0$709A00/E2ALTO0IR8Y0B9Q6WWQK9E279H09YUTLQV/XKPJEI%U1CQ $CI1SF*IM9H$B5NRCBS1ZKALZ1PB0C5RORM76HS+1NBS*BRXUCUWBY84V4FUX22YAQAVR0KGDNB8WSSQOAI3*AV559UQ9:JP0TXR7*IQYNL$22N+24T0WOLYZ3C*38G6 SBR8BU.0DZ9P:J:L35FQHDU:XIOK3R32GFKV2RC.67UE9MFK-LR*Q/UP/H6ZKQ $2LENGCO5-HYCNL$K$735$C7+QDS72BMK9BULC 8R6 LDKR.OP5ENH L4QDJ-J+:3D-185DY6U55GY8VE TN16.:83-7T+AJ-5-4GK8WTUSPJ382580K1VFWFKOVKU4F%5ND*NA-VH7E:/046C353S$23ZD7L0.FD%0"
      let cert=HCert.init(from: hCert)
      XCTAssert( cert != nil)
      XCTAssert(cert?.validityFailures.count == 0)
    }
}

extension QRCodeTests: PublicKeyStorageDelegate {
  func getEncodedPublicKeys(for kid: String) -> [String] {
    if(kid == "CFUoOhVtOgo=") {
        return ["MIICnDCCAkKgAwIBAgIIJr8oA/3jYAQwCgYIKoZIzj0EAwIwUDEkMCIGA1UEAwwbUG9sYW5kIERHQyBSb290Q1NDQSAxIEFDQyBTMRswGQYDVQQKDBJNaW5pc3RyeSBvZiBIZWFsdGgxCzAJBgNVBAYTAlBMMB4XDTIxMDUyNDExMTgxNloXDTIzMDUyNDExMTgxNlowcjEtMCsGA1UEAwwkUG9sYW5kIFZhY2NpbmF0aW9uIERHQyBTZXJ2aWNlIDMgQUNDMRcwFQYDVQQLDA5lSGVhbHRoIENlbnRlcjEbMBkGA1UECgwSTWluaXN0cnkgb2YgSGVhbHRoMQswCQYDVQQGEwJQTDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABBb5V0Rbo5Qc1yAVxRyXaLt/QjmI4WG3qsXf81WoH6L2Uf4oj5iGnAuem1TSotax+FUgvn+GbcUg7BTrL+ePAQSjgeMwgeAwHwYDVR0jBBgwFoAUqc15HwkAJgfQl/0DpjHxRVJ9E28wFgYDVR0lBA8wDQYLKwYBBAGON49lAQIwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2FjYy1wMS5lemRyb3dpZS5nb3YucGwvY2NwMS9jcmwvREdDUm9vdENTQ0ExQUNDUy5jcmwwHQYDVR0OBBYEFAenLsHAhybxn8MjzWYLq+xrD8iYMCsGA1UdEAQkMCKADzIwMjEwNTI0MTExODE2WoEPMjAyMjA1MjQxMTE4MTZaMAsGA1UdDwQEAwIHgDAKBggqhkjOPQQDAgNIADBFAiEAw17oXs3K8q+VorcGq014/zCZAnxqRIQ6fCkHGCENJWQCIB3hvpk+NdLphX7aokerbhsF6xuJ7hT6DnD67SFgLI/9"]
    }
    
    if(kid == "STPDGKKF4N8=") {
        return ["MIICpDCCAkugAwIBAgIUCQqeQIDhCUErUgTaGLQWtpazE0wwCgYIKoZIzj0EAwIwbDELMAkGA1UEBhMCQkcxGzAZBgNVBAoMEk1pbmlzdHJ5IG9mIEhlYWx0aDEiMCAGA1UECwwZSGVhbHRoIEluZm9ybWF0aW9uIFN5c3RlbTEcMBoGA1UEAwwTQnVsZ2FyaWEgREdDIENTQ0EgMTAeFw0yMTA1MTExMzM1NDFaFw0yMzA1MTExMzM1NDFaMHIxCzAJBgNVBAYTAkJHMQ4wDAYDVQQHDAVTb2ZpYTEbMBkGA1UECgwSTWluaXN0cnkgb2YgSGVhbHRoMSIwIAYDVQQLDBlIZWFsdGggSW5mb3JtYXRpb24gU3lzdGVtMRIwEAYDVQQDDAlER0MgRFNDIDEwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATKS3U1ssyUkLU8/l+N4WLHBJtJv7EfhhHSCS4sIDmxC1IEvSDNeWGBNRAd0y4c2qvk3mggEWTvXl4EemFOI4LCo4HEMIHBMAwGA1UdEwEB/wQCMAAwLAYDVR0fBCUwIzAhoB+gHYYbaHR0cDovL2NybC5oaXMuYmcvY3NjYTEuY3JsMB8GA1UdIwQYMBaAFCquB6sY+uzcJ1Q7ebdy5EPK5zMLMB0GA1UdDgQWBBSZ1xpVCsU4Ccmz1cn4cK+Af0o3gTAOBgNVHQ8BAf8EBAMCB4AwMwYDVR0lBCwwKgYMKwYBBAEAjjePZQEBBgwrBgEEAQCON49lAQIGDCsGAQQBAI43j2UBAzAKBggqhkjOPQQDAgNHADBEAiAZG+XA04EByYpauBQIaGiv6Jy7Y/N7FTmYscaQ4NeKJwIga1u+9Pq8+63QeU6gsCkf+jIKppr58EQMA6UF1I11VDE="]
    }
    
    if(kid == "2c6RCwOmTGI=") {
     return ["MIICKTCCAc+gAwIBAgITewAAAB77yzK1mZYu7QAAAAAAHjAKBggqhkjOPQQDAjA/MQswCQYDVQQGEwJOTzEbMBkGA1UEChMSTm9yc2sgaGVsc2VuZXR0IFNGMRMwEQYDVQQDEwpDU0NBIE5PIHYxMB4XDTIxMDYwNzA1NTY0MloXDTIzMDYwNzA2MDY0MlowUjELMAkGA1UEBhMCTk8xLTArBgNVBAoTJE5vcndlZ2lhbiBJbnN0aXR1dGUgb2YgUHVibGljIEhlYWx0aDEUMBIGA1UEAxMLRFNDIEhOIEVVIDIwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAR0UprGbSmy5WsMAyb0GXbzemkLRvmUNswy1lBGavDjHW7CTYPd+7yG/OGaXetTnboH0jDJeL1vVQvOr12T4+teo4GWMIGTMA4GA1UdDwEB/wQEAwIHgDAzBgNVHSUELDAqBgwrBgEEAQCON49lAQEGDCsGAQQBAI43j2UBAgYMKwYBBAEAjjePZQEDMB0GA1UdDgQWBBT1z+dhLhI7/AUOAdFiK4oqzEAlrzAfBgNVHSMEGDAWgBRBY3L2ecPBcffxgRI2UhCjJQp0JzAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMCA0gAMEUCIDnEDlot8V1hen18ra7Xjv2bGL1mdz7453ItRdx4ubllAiEAkZZKE14rprcfPW6lKcS+SwQr7IWCrMYb/nZdhecUAHM="]
      }
    
    if(kid == "uxvl+dsyrBw=") {
        return ["MIIBzDCCAXGgAwIBAgIUDN8nWnn8gBmlWgL3stwhoinVD5MwCgYIKoZIzj0EAwIwIDELMAkGA1UEBhMCR1IxETAPBgNVBAMMCGdybmV0LmdyMB4XDTIxMDUxMjExMjY1OFoXDTIzMDUxMjExMjY1OFowIDELMAkGA1UEBhMCR1IxETAPBgNVBAMMCGdybmV0LmdyMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEBcc6ApRZrh9/qCuMnxIRpUujI19bKkG+agj/6rPOiX8VyzfWvhptzV0149AFRWdSoF/NVuQyFcrBoNBqL9zCAqOBiDCBhTAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFN6ZiC57J/yRqTJ/Tg2eRspLCHDhMB8GA1UdIwQYMBaAFNU5HfWNY37TbdZjvsvO+1y1LPJYMDMGA1UdJQQsMCoGDCsGAQQBAI43j2UBAQYMKwYBBAEAjjePZQECBgwrBgEEAQCON49lAQMwCgYIKoZIzj0EAwIDSQAwRgIhAN6rDdE4mtTt2ZuffpZ242/B0lmyvdd+Wy6VuX+J/b01AiEAvME52Y4zqkQDuj2kbfCfs+h3uwYFOepoBP14X+Rd/VM="]
    }
    
    if(kid == "TfwLMHDXIws=") {
        return ["MIICEjCCAbmgAwIBAgIUTExVw4anJr4PZhNn3w8UgGwoQGUwCgYIKoZIzj0EAwIwZjELMAkGA1UEBhMCTFYxLTArBgNVBAoMJE5hY2lvbsOEwoFsYWlzIFZlc2Vsw4TCq2JhcyBkaWVuZXN0czENMAsGA1UECwwEQ1NDQTEZMBcGA1UEAwwQQ1NDQSBER0MgTFYgVGVzdDAeFw0yMTA1MTMwNzM2MTZaFw0yNTA1MTIwNzM2MTZaMGYxCzAJBgNVBAYTAkxWMS0wKwYDVQQKDCROYWNpb27DhMKBbGFpcyBWZXNlbMOEwqtiYXMgZGllbmVzdHMxDTALBgNVBAsMBENTQ0ExGTAXBgNVBAMMEENTQ0EgREdDIExWIFRlc3QwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAREAeqbcI/ljWtS/UAvYhF4ubd1RQpOd/NrgLunZb3HAbBW/8h1dxPr1DSWQmxxXlGR/TitYtL1ZuxeRWfl8bGDo0UwQzASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUTP6CwP1AoJEnvrISXSiv4q+Q0U0wCgYIKoZIzj0EAwIDRwAwRAIgU3W1knii0mIcfFBTzE3c0GjL8zTg8oSaUJwrSKq0eVwCIFfT95WJ2qIQA9a7abobrHLmnYCP+K/lbtwQ2tNErpc3"]
        
    }
    
    if(kid == "b0RhLyvUxgs=") {
    return ["MIIBwzCCAWmgAwIBAgIEYMfSczAKBggqhkjOPQQDAjBAMQswCQYDVQQGEwJIVTEOMAwGA1UECgwFRUVTWlQxITAfBgNVBAMMGERHQ19DU0NBX0FDQ18yMDIxMDYwOV8wMTAeFw0yMTA2MTQyMjA0MzVaFw0yMzA2MTQyMjA0MzVaMD8xCzAJBgNVBAYTAkhVMQ4wDAYDVQQKDAVFRVNaVDEgMB4GA1UEAwwXREdDX0RTQ19BQ0NfMjAyMTA2MTRfMDIwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAS0i2qK7njiSFkjgA7cRafb8ghw0F7r/hOR3Oq0p+TbHjLUCmEdFOJXAGGB+WN9fuktauHZKeCPzwTM9TJ5dKWuo1IwUDAOBgNVHQ8BAf8EBAMCB4AwHwYDVR0jBBgwFoAU5lLohU1Z4D5vbdCuBkU4cLrFzFowHQYDVR0OBBYEFLSud34p+Usn7j4yyoiKfgSuk7a8MAoGCCqGSM49BAMCA0gAMEUCIQD4zkHgwTUQ0/U14/podTs388ZRTtwud0R4rRZTNVY5CAIgGkPo9ADV88iaqYoPd4JRXH2BhVl7FFPeDmA2o8Q+whc="]
    }
  
    return [""]
    
  }
}
