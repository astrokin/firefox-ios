// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Storage
import DecentrAPI

private enum DC_SearchEngine: String, CaseIterable {
    case Aol = "aol"
    case Archive = "archive"
    case Ask = "ask"
    case Baidu = "baidu"
    case Bing = "bing"
    case DuckDuckGo = "duckduckgo"
    case Ecosia = "ecosia"
    case Google = "google"
    case Yahoo = "yahoo"
    case Yandex = "yandex"
    
    var queryParam: String {
        switch self {
        case .Yandex: return "text"
        case .Yahoo: return "p"
        case .Baidu: return "wd"
        case .Archive: return "query"
        default:
            return "q"
        }
    }
}

protocol DC_PDV {
    func trackVisit(_ visit: SiteVisit)
    
    func getPendingPDV() -> String
    
    func purge() //need for logout
}

final class DC_PDV_Monitor: DC_PDV {
    
    static let shared: DC_PDV = DC_PDV_Monitor()
    
    private static var userDefaultDataKey: String {
        let accountId = DC_Shared_Info.shared.getAccount().baseAccount?.account?.account_number ?? UserDefaults.standard.string(forKey: "Decentr.Last.Login.account_number") ?? "account_number"
        return "decentr.\(accountId).json"
    }
    
    private lazy var dateFormatter: Foundation.DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = PDVItem.dateFormat
        return dateFormatter
    }()
    
    private let pdvBatchSize: Int = 70
    
    @UserDefaultData(key: userDefaultDataKey, defaultValue: [])
    var pdvStorage: [PDVItem]
    
    func trackVisit(_ visit: SiteVisit) {
        print("[DC] type: \(visit.type.rawValue) visit \(visit.site.url)")
        
        DispatchQueue.global(qos: .utility).async {
            
            if let url = URL(string: visit.site.url),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let domain = components.host?.split(separator: ".").suffix(2).joined(separator: "."),
               let engine = domain.split(separator: ".").first?.lowercased() {
                
                if let searchEngine = DC_SearchEngine.allCases.first(where: { $0.rawValue == engine }),
                   let query = components.queryItems?.first(where: { $0.name.lowercased() == searchEngine.queryParam })?.value?.removingPercentEncoding {
                    
                    let pdv = PDVItem(domain: domain,
                                      engine: engine,
                                      query: query,
                                      timestamp: self.dateFormatter.string(from: Date()))
                    self.save(pdv: pdv)
                }
            }
        }
    }
    
    func purge() {
        pdvStorage = []
    }
    
    func getPendingPDV() -> String {
        let pdv = Float(pdvStorage.count) * Float(0.000001)
        let value = String(format: "%.6f", pdv)
        return value
    }
    
    private func save(pdv: PDVItem) {
        pdvStorage.append(pdv)
        
        print("[DC] storage count \(pdvStorage.count)")
        
        if pdvStorage.count > pdvBatchSize {
            sendPDV(Array(pdvStorage.prefix(pdvBatchSize)))
        }
    }
    
    private func sendPDV(_ pdvlist: [PDVItem]) {
        let body = PDVDataRequest(version: "v1", pdv: pdvlist)
        let reqBuilder = CerberusAPI.PDVAPI.saveDataWithRequestBuilder(body: body)
        reqBuilder.executeSignRequest { _ in
            print("[DC] send success")
            self.pdvStorage.removeFirst(self.pdvBatchSize)
        } failed: { error in
            print("[DC] send error: \(error)")
        }
    }
}
