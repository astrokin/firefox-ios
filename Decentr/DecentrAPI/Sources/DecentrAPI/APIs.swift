// APIs.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public class APIs { ///super class for app APIs data
    public static var credential: URLCredential?
    public static var customHeaders: [String:String] {
        let info = Bundle.main.infoDictionary
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?["CFBundleVersion"] as? String ?? "Unknown"

        return [
            "Content-Type": "application/json",
            "app-version" : appVersion,
            "app-version-code": appBuild,
            "platform": "ios",
            "locale": "\(Locale.current.languageCode ?? "")"
        ]
    }
}

extension CerberusAPI {
    open class Data {
        public static var basePath = "https://cerberus.mainnet.decentr.xyz"
        public static var requestBuilderFactory: RequestBuilderFactory = AlamofireRequestBuilderFactory()
    }
}

extension VulcanAPI {
    open class Data {
        public static var basePath = "https://vulcan.mainnet.decentr.xyz"
        public static var requestBuilderFactory: RequestBuilderFactory = AlamofireRequestBuilderFactory()
    }
}

extension DcntrAPI {
    open class Data {
        public static var basePath = "https://rest.mainnet.decentr.xyz"
        public static var requestBuilderFactory: RequestBuilderFactory = AlamofireRequestBuilderFactory()
    }
}

open class RequestBuilder<T> {
    public private(set) var credential: URLCredential?
    public private(set) var headers: [String:String]
    public var parameters: [String:Any]?
    public let  isBody: Bool
    public let  method: String
    public let  URLString: String
    public let  path: String

    /// Optional block to obtain a reference to the request's progress instance when available.
    public var onProgressReady: ((Progress) -> ())?

    required public init(method: String, path: String, URLString: String, parameters: [String:Any]?, isBody: Bool, headers: [String:String] = [:]) {
        self.method = method
        self.path = path
        self.URLString = URLString
        self.parameters = parameters
        self.isBody = isBody
        self.headers = headers

        addHeaders(APIs.customHeaders)
    }

    open func addHeaders(_ aHeaders:[String:String]) {
        for (header, value) in aHeaders {
            headers[header] = value
        }
    }

    open func execute(_ completion: @escaping (_ response: Response<T>?, _ error: Error?) -> Void) { }

    @discardableResult
    public func addHeader(name: String, value: String) -> Self {
        if !value.isEmpty {
            headers[name] = value
        }
        return self
    }

    @discardableResult
    open func addCredential() -> Self {
        self.credential = APIs.credential
        return self
    }
}

public protocol RequestBuilderFactory {
    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type
    func getBuilder<T:Decodable>() -> RequestBuilder<T>.Type
}
