//
// ConfigsAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


public extension CerberusAPI.ConfigsAPI {
    /**
     Get blacklist

     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getBlacklistConfig(completion: @escaping ((_ data: Blacklist?,_ error: Error?) -> Void)) {
        getBlacklistConfigWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get blacklist
     - GET /configs/blacklist

     - examples: [{contentType=application/json, example={
  "cookieSource" : [ "cookieSource", "cookieSource" ]
}}]

     - returns: RequestBuilder<Blacklist> 
     */
    class func getBlacklistConfigWithRequestBuilder() -> RequestBuilder<Blacklist> {
        let path = "/v1/configs/blacklist"
        let URLString = CerberusAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<Blacklist>.Type = CerberusAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    /**
     Get rewards config

     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getRewardsConfig(completion: @escaping ((_ data: ObjectTypes?,_ error: Error?) -> Void)) {
        getRewardsConfigWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get rewards config
     - GET /configs/rewards

     - examples: [{contentType=application/json, example={
  "cookie" : 6,
  "profile" : 5,
  "location" : 1,
  "searchHistory" : 5,
  "advertiserId" : 0
}}]

     - returns: RequestBuilder<ObjectTypes> 
     */
    class func getRewardsConfigWithRequestBuilder() -> RequestBuilder<ObjectTypes> {
        let path = "/v1/configs/rewards"
        let URLString = CerberusAPI.Data.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<ObjectTypes>.Type = CerberusAPI.Data.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", path: path, URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
}
