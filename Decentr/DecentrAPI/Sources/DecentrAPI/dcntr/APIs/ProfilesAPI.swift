//
// ProfilesAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


public extension DcntrAPI.ProfilesAPI {
    /**
     Returns decentr stats.

     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getDecentrStats(completion: @escaping ((_ data: DecentrStats?,_ error: Error?) -> Void)) {
        getDecentrStatsWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Returns decentr stats.
     - GET /profiles/stats
     - 

     - examples: [{contentType=application/json, example={
  "adv" : 0.8008281904610115,
  "ddv" : 6.027456183070403
}}]

     - returns: RequestBuilder<DecentrStats> 
     */
    class func getDecentrStatsWithRequestBuilder() -> RequestBuilder<DecentrStats> {
        let path = "/profiles/stats"
        let URLString = DcntrAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<DecentrStats>.Type = DcntrAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    /**
     Get pdv stats by address.

     - parameter address: (path)  
     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getProfileStats(address: String, completion: @escaping ((_ data: ProfileStats?,_ error: Error?) -> Void)) {
        getProfileStatsWithRequestBuilder(address: address).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get pdv stats by address.
     - GET /profiles/{address}/stats
     - 

     - examples: [{contentType=application/json, example={
  "postsCount" : 7,
  "stats" : [ {
    "date" : "date",
    "value" : 9.301444243932576
  }, {
    "date" : "date",
    "value" : 9.301444243932576
  } ]
}}]
     - parameter address: (path)  

     - returns: RequestBuilder<ProfileStats> 
     */
    class func getProfileStatsWithRequestBuilder(address: String) -> RequestBuilder<ProfileStats> {
        var path = "/profiles/{address}/stats"
        let addressPreEscape = "\(address)"
        let addressPostEscape = addressPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{address}", with: addressPostEscape, options: .literal, range: nil)
        let URLString = DcntrAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<ProfileStats>.Type = DcntrAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    class func getCheckAddressWithRequestBuilder(address: String) -> RequestBuilder<BaseAccount> {
        var path = "/cosmos/auth/v1beta1/accounts/{address}"
        let addressPreEscape = "\(address)"
        let addressPostEscape = addressPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{address}", with: addressPostEscape, options: .literal, range: nil)
        let URLString = DcntrAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<BaseAccount>.Type = DcntrAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    class func getCheckAddress(address: String, completion: @escaping ((_ data: BaseAccount?,_ error: Error?) -> Void)) {
        getCheckAddressWithRequestBuilder(address: address).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    class func getCheckDECBalanceWithRequestBuilder(address: String) -> RequestBuilder<BalanceDEC> {
        var path = "/decentr/token/balance/{address}"
        let addressPreEscape = "\(address)"
        let addressPostEscape = addressPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{address}", with: addressPostEscape, options: .literal, range: nil)
        let URLString = DcntrAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<BalanceDEC>.Type = DcntrAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    class func getCheckBalanceDEC(address: String, completion: @escaping ((_ data: BalanceDEC?,_ error: Error?) -> Void)) {
        getCheckDECBalanceWithRequestBuilder(address: address).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    class func getCheckPDVBalanceWithRequestBuilder(address: String) -> RequestBuilder<BalancePDV> {
        var path = "/cosmos/bank/v1beta1/balances/{address}"
        let addressPreEscape = "\(address)"
        let addressPostEscape = addressPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{address}", with: addressPostEscape, options: .literal, range: nil)
        let URLString = DcntrAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<BalancePDV>.Type = DcntrAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    class func getCheckBalancePDV(address: String, completion: @escaping ((_ data: BalancePDV?,_ error: Error?) -> Void)) {
        getCheckPDVBalanceWithRequestBuilder(address: address).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
}
