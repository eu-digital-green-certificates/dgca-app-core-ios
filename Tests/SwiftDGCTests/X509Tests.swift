//
//  File.swift
//  
//
//  Created by Steffen on 25.06.21.
//

import XCTest
import Foundation
@testable
import SwiftDGC

final class X509Test:XCTestCase {
  
  
  func testvalidOIDforAll() {
    let certificate = "MIICVjCCAf2gAwIBAgIUIQnCGTQIo0uY8OzwmWXmbMOH9xMwCgYIKoZIzj0EAwIwdDELMAkGA1UEBhMCREUxDDAKBgNVBAgMA05SVzENMAsGA1UEBwwEQm9ubjEXMBUGA1UECgwOTWluaXN0cnlPZlRlc3QxFjAUBgNVBAsMDURHQ09wZXJhdGlvbnMxFzAVBgNVBAMMDkNTQ0FfREdDX0RFXzAxMB4XDTIxMDYyNTA3MjI1OFoXDTIzMDYyNTA3MjI1OFowWzELMAkGA1UEBhMCREUxCjAIBgNVBAgMAVMxCjAIBgNVBAcMAVMxCjAIBgNVBAoMAVMxCjAIBgNVBAsMAVMxCjAIBgNVBAMMAVMxEDAOBgkqhkiG9w0BCQEWAVMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQhvvldp/tNO9RrhB3ukPeXBKQA37J5jBXzAHKr0iMjwbac8yvDjKnFHhxrLiikPO7JAhgtE0OMXRepSG5SaSEbo4GFMIGCMA4GA1UdDwEB/wQEAwIHgDAdBgNVHQ4EFgQUsFRcQzzUInJx3+oAXCFYTYFxN7swHwYDVR0jBBgwFoAUA2kSfgIT6MYHBHuGL2ZosSYVv34wMAYDVR0lBCkwJwYLKwYBBAGON49lAQEGCysGAQQBjjePZQECBgsrBgEEAY43j2UBAzAKBggqhkjOPQQDAgNHADBEAiBUSH71j0R/qUX0HtEodvfsx/qUy72imderLoKALRHt7gIgVa0Yxvi1cBPq9Y1A/tDmOBMblFY1TOmhxLu/veFsbbA="
    
    let data = Data(base64Encoded:  certificate)!
    
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.recovery))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.test))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.vaccine))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.unknown))
  }
  
  func testvalidOIDforTestandVac() {
    let certificate = "MIICSDCCAe6gAwIBAgIUIQnCGTQIo0uY8OzwmWXmbMOH9xQwCgYIKoZIzj0EAwIwdDELMAkGA1UEBhMCREUxDDAKBgNVBAgMA05SVzENMAsGA1UEBwwEQm9ubjEXMBUGA1UECgwOTWluaXN0cnlPZlRlc3QxFjAUBgNVBAsMDURHQ09wZXJhdGlvbnMxFzAVBgNVBAMMDkNTQ0FfREdDX0RFXzAxMB4XDTIxMDYyNTA3MjUwMloXDTIzMDYyNTA3MjUwMlowWzELMAkGA1UEBhMCREUxCjAIBgNVBAgMAVMxCjAIBgNVBAcMAVMxCjAIBgNVBAoMAVMxCjAIBgNVBAsMAVMxCjAIBgNVBAMMAVMxEDAOBgkqhkiG9w0BCQEWAVMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQhvvldp/tNO9RrhB3ukPeXBKQA37J5jBXzAHKr0iMjwbac8yvDjKnFHhxrLiikPO7JAhgtE0OMXRepSG5SaSEbo3cwdTAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFLBUXEM81CJycd/qAFwhWE2BcTe7MB8GA1UdIwQYMBaAFANpEn4CE+jGBwR7hi9maLEmFb9+MCMGA1UdJQQcMBoGCysGAQQBjjePZQEBBgsrBgEEAY43j2UBAjAKBggqhkjOPQQDAgNIADBFAiEAqpQws1zQWU4h0bDF0cj4NM8sctBqQerLOoxO2jYWQ70CIBu2ZgSJ5z7J05fQ5+8hTSauVKrz7LwnE1ZUETwUCVe6"
    
    let data = Data(base64Encoded:  certificate)!
    
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.recovery))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.test))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.vaccine))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.unknown))
  }
  
  func testvalidOIDforRecovery() {
    let certificate = "MIICOzCCAeGgAwIBAgIUIQnCGTQIo0uY8OzwmWXmbMOH9xUwCgYIKoZIzj0EAwIwdDELMAkGA1UEBhMCREUxDDAKBgNVBAgMA05SVzENMAsGA1UEBwwEQm9ubjEXMBUGA1UECgwOTWluaXN0cnlPZlRlc3QxFjAUBgNVBAsMDURHQ09wZXJhdGlvbnMxFzAVBgNVBAMMDkNTQ0FfREdDX0RFXzAxMB4XDTIxMDYyNTA3MjUwOVoXDTIzMDYyNTA3MjUwOVowWzELMAkGA1UEBhMCREUxCjAIBgNVBAgMAVMxCjAIBgNVBAcMAVMxCjAIBgNVBAoMAVMxCjAIBgNVBAsMAVMxCjAIBgNVBAMMAVMxEDAOBgkqhkiG9w0BCQEWAVMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQhvvldp/tNO9RrhB3ukPeXBKQA37J5jBXzAHKr0iMjwbac8yvDjKnFHhxrLiikPO7JAhgtE0OMXRepSG5SaSEbo2owaDAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFLBUXEM81CJycd/qAFwhWE2BcTe7MB8GA1UdIwQYMBaAFANpEn4CE+jGBwR7hi9maLEmFb9+MBYGA1UdJQQPMA0GCysGAQQBjjePZQEDMAoGCCqGSM49BAMCA0gAMEUCIG5czRCTmf6vFKKkJ6TtFC5HZBM81yJBGMI3QmkxoeFHAiEAgRlM0rdgJ6gVLeJ5jyA3wM9Ca7F9bUCfWus/3xuy+Sk="
    
    let data = Data(base64Encoded:  certificate)!
    
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.recovery))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.test))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.vaccine))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.unknown))
  }
  
  func testvalidOIDforVaccine() {
    let certificate = "MIICOzCCAeGgAwIBAgIUIQnCGTQIo0uY8OzwmWXmbMOH9xYwCgYIKoZIzj0EAwIwdDELMAkGA1UEBhMCREUxDDAKBgNVBAgMA05SVzENMAsGA1UEBwwEQm9ubjEXMBUGA1UECgwOTWluaXN0cnlPZlRlc3QxFjAUBgNVBAsMDURHQ09wZXJhdGlvbnMxFzAVBgNVBAMMDkNTQ0FfREdDX0RFXzAxMB4XDTIxMDYyNTA3MjYzN1oXDTIzMDYyNTA3MjYzN1owWzELMAkGA1UEBhMCREUxCjAIBgNVBAgMAVMxCjAIBgNVBAcMAVMxCjAIBgNVBAoMAVMxCjAIBgNVBAsMAVMxCjAIBgNVBAMMAVMxEDAOBgkqhkiG9w0BCQEWAVMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQhvvldp/tNO9RrhB3ukPeXBKQA37J5jBXzAHKr0iMjwbac8yvDjKnFHhxrLiikPO7JAhgtE0OMXRepSG5SaSEbo2owaDAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFLBUXEM81CJycd/qAFwhWE2BcTe7MB8GA1UdIwQYMBaAFANpEn4CE+jGBwR7hi9maLEmFb9+MBYGA1UdJQQPMA0GCysGAQQBjjePZQECMAoGCCqGSM49BAMCA0gAMEUCIQDI9eFa+BCRx9r8ubybDG48twTIZ56WQRIHEIOl2EF0SQIgIeBuEcpYierv4OrNxAI/eF+rzqzdDBWKmKUaqn/+o9c="
    
    let data = Data(base64Encoded:  certificate)!
    
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.recovery))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.test))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.vaccine))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.unknown))
  }
  
  func testvalidOIDforTest() {
    let certificate = "MIICOjCCAeGgAwIBAgIUIQnCGTQIo0uY8OzwmWXmbMOH9xcwCgYIKoZIzj0EAwIwdDELMAkGA1UEBhMCREUxDDAKBgNVBAgMA05SVzENMAsGA1UEBwwEQm9ubjEXMBUGA1UECgwOTWluaXN0cnlPZlRlc3QxFjAUBgNVBAsMDURHQ09wZXJhdGlvbnMxFzAVBgNVBAMMDkNTQ0FfREdDX0RFXzAxMB4XDTIxMDYyNTA3MjcxMVoXDTIzMDYyNTA3MjcxMVowWzELMAkGA1UEBhMCREUxCjAIBgNVBAgMAVMxCjAIBgNVBAcMAVMxCjAIBgNVBAoMAVMxCjAIBgNVBAsMAVMxCjAIBgNVBAMMAVMxEDAOBgkqhkiG9w0BCQEWAVMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQhvvldp/tNO9RrhB3ukPeXBKQA37J5jBXzAHKr0iMjwbac8yvDjKnFHhxrLiikPO7JAhgtE0OMXRepSG5SaSEbo2owaDAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFLBUXEM81CJycd/qAFwhWE2BcTe7MB8GA1UdIwQYMBaAFANpEn4CE+jGBwR7hi9maLEmFb9+MBYGA1UdJQQPMA0GCysGAQQBjjePZQEBMAoGCCqGSM49BAMCA0cAMEQCICtQgyRMKamLZSGaL0iozsoR3vJhuS0gt3gRN9sR9b8QAiA2gLClhuXmOkmU2I+f/XinE/Fz2MjaIqKtRZOz3KHHSg=="
    
    let data = Data(base64Encoded:  certificate)!
    
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.recovery))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.test))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.vaccine))
    XCTAssertFalse(X509.isSuitable(cert: data, for: HCertType.unknown))
  }
  
  func testValidButNoOIDs() {
    let certificate = "MIIByjCCAXACFCEJwhk0CKNLmPDs8Jll5mzDh/cYMAoGCCqGSM49BAMCMHQxCzAJBgNVBAYTAkRFMQwwCgYDVQQIDANOUlcxDTALBgNVBAcMBEJvbm4xFzAVBgNVBAoMDk1pbmlzdHJ5T2ZUZXN0MRYwFAYDVQQLDA1ER0NPcGVyYXRpb25zMRcwFQYDVQQDDA5DU0NBX0RHQ19ERV8wMTAeFw0yMTA2MjUwODA2MjlaFw0yMzA2MjUwODA2MjlaMFsxCzAJBgNVBAYTAkRFMQowCAYDVQQIDAFTMQowCAYDVQQHDAFTMQowCAYDVQQKDAFTMQowCAYDVQQLDAFTMQowCAYDVQQDDAFTMRAwDgYJKoZIhvcNAQkBFgFTMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIb75Xaf7TTvUa4Qd7pD3lwSkAN+yeYwV8wByq9IjI8G2nPMrw4ypxR4cay4opDzuyQIYLRNDjF0XqUhuUmkhGzAKBggqhkjOPQQDAgNIADBFAiAyLXiR9b5bDmIuCaQz2KZ5yMcfXPHBtaJ3+z3efiyBNAIhAOBUyr9fQeVjsN+nfjzJqvGoSPlRgJaLUVck1MuB5Mm3"
    
    let data = Data(base64Encoded:  certificate)!
    
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.recovery))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.test))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.vaccine))
    XCTAssertTrue(X509.isSuitable(cert: data, for: HCertType.unknown))
  }
}

