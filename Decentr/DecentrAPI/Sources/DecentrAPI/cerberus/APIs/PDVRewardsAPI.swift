//
// PDVRewardsAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


public extension CerberusAPI.PDVRewardsAPI {
    /**
     Get PDV reward delta of the given account

     - parameter owner: (path) account address 
     - parameter completion: completion handler to receive the data and the error objects
     */
    class func pDVRewardDelta(owner: String, completion: @escaping ((_ data: PDVRewardDelta?,_ error: Error?) -> Void)) {
        pDVRewardDeltaWithRequestBuilder(owner: owner).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get PDV reward delta of the given account
     - GET /accounts/{owner}/pdv-delta

     - examples: [{contentType=application/json, example={
  "delta" : { },
  "pool" : {
    "next_distribution_date" : "2000-01-23T04:56:07.000+00:00"
  }
}}]
     - parameter owner: (path) account address 

     - returns: RequestBuilder<PDVRewardDelta> 
     */
    class func pDVRewardDeltaWithRequestBuilder(owner: String) -> RequestBuilder<PDVRewardDelta> {
        var path = "/v1/accounts/{owner}/pdv-delta"
        let ownerPreEscape = "\(owner)"
        let ownerPostEscape = ownerPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{owner}", with: ownerPostEscape, options: .literal, range: nil)
        let URLString = CerberusAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<PDVRewardDelta>.Type = CerberusAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    /**
     Get PDV rewards pool

     - parameter completion: completion handler to receive the data and the error objects
     */
    class func pDVRewardsPool(completion: @escaping ((_ data: PDVRewardsPool?,_ error: Error?) -> Void)) {
        pDVRewardsPoolWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get PDV rewards pool
     - GET /pdv-rewards/pool

     - examples: [{contentType=application/json, example={
  "next_distribution_date" : "2000-01-23T04:56:07.000+00:00"
}}]

     - returns: RequestBuilder<PDVRewardsPool> 
     */
    class func pDVRewardsPoolWithRequestBuilder() -> RequestBuilder<PDVRewardsPool> {
        let path = "/v1/pdv-rewards/pool"
        let URLString = CerberusAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<PDVRewardsPool>.Type = CerberusAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
}
