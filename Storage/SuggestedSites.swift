// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit
import Shared

open class SuggestedSite: Site {
    override open var tileURL: URL {
        return URL(string: url as String) ?? URL(string: "about:blank")!
    }

    let trackingId: Int
    init(data: SuggestedSiteData) {
        self.trackingId = data.trackingId
        super.init(url: data.url, title: data.title, bookmarked: nil)
        self.guid = "default" + data.title // A guid is required in the case the site might become a pinned site
    }
}

public let SuggestedSites = SuggestedSitesCursor()

open class SuggestedSitesCursor: ArrayCursor<SuggestedSite> {
    fileprivate init() {
        let locale = Locale.current
        let sites = DefaultSuggestedSites.sites[locale.identifier] ??
                    DefaultSuggestedSites.sites["default"]! as Array<SuggestedSiteData>
        let tiles = sites.map({ data -> SuggestedSite in
            var site = data
            if let domainMap = DefaultSuggestedSites.urlMap[data.url], let localizedURL = domainMap[locale.identifier] {
                site.url = localizedURL
            }
            return SuggestedSite(data: site)
        })
        super.init(data: tiles, status: .success, statusMessage: "Loaded")
    }
}


public let DecentrSuggestedSites = DecentrSuggestedSitesCursor()

open class DecentrSuggestedSitesCursor: ArrayCursor<SuggestedSite> {
    fileprivate init() {
        let locale = Locale.current
        let sites = [
            SuggestedSiteData(
                url: "https://decentr.net/",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_decentr",
                faviconUrl: "asset://faviconFox",
                trackingId: 0,
                title: "Decentr"
            ),
            SuggestedSiteData(
                url: "https://support.decentr.net/",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_decentr",
                faviconUrl: "asset://faviconFox",
                trackingId: 0,
                title: "Knwledge Base"
            ),
            SuggestedSiteData(
                url: "https://decentrnet.medium.com/",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_medium",
                faviconUrl: "asset://faviconFox",
                trackingId: 0,
                title: "Medium"
            ),
            SuggestedSiteData(
                url: "https://t.me/DecentrNet",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_telegram",
                faviconUrl: "asset://faviconFox",
                trackingId: 0,
                title: "Telegram"
            ),
            SuggestedSiteData(
                url: "https://twitter.com/decentrnet",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_decentr",
                faviconUrl: "asset://faviconFox",
                trackingId: 0,
                title: .DefaultSuggestedTwitter
            ),
            SuggestedSiteData(
                url: "https://github.com/Decentr-net",
                bgColor: "0x55acee",
                imageUrl: "asset://suggestedsites_github",
                faviconUrl: "asset://faviconFox",
                trackingId: 0,
                title: "Github"
            ),
            SuggestedSiteData(
                url: "https://discord.gg/VMUt7yw92B",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_discord",
                faviconUrl: "asset://faviconFox",
                trackingId: 0,
                title: "Discord"
            )
        ]
        let tiles = sites.map({ data -> SuggestedSite in
            var site = data
            if let domainMap = DefaultSuggestedSites.urlMap[data.url], let localizedURL = domainMap[locale.identifier] {
                site.url = localizedURL
            }
            return SuggestedSite(data: site)
        })
        super.init(data: tiles, status: .success, statusMessage: "Loaded")
    }
}

public struct SuggestedSiteData {
    var url: String
    var bgColor: String
    var imageUrl: String
    var faviconUrl: String
    var trackingId: Int
    var title: String
}

//{
//  "title": "decentr",
//  "url": "http://www.decentr.net/",
//  "image_url": "decentr-net.png",
//  "background_color": "#000000",
//  "domain": "decentr.net"
//},
//{
//  "title": "knwledge.base",
//  "url": "https://support.decentr.net/",
//  "image_url": "decentr-net.png",
//  "background_color": "#FFFFFF",
//  "domain": "support.decentr.net"
//},
//{
//  "title": "medium",
//  "url": "https://decentrnet.medium.com/",
//  "image_url": "medium-com.png",
//  "background_color": "#98c554",
//  "domain": "decentrnet.medium.com"
//},
//{
//  "title": "telegram",
//  "url": "https://t.me/DecentrNet",
//  "image_url": "telegram-org.png",
//  "background_color": "#98c554",
//  "domain": "t.me"
//},
//{
//  "title": "twitter",
//  "url": "https://twitter.com/decentrnet",
//  "image_url": "twitter-com.png",
//  "background_color": "#d83633",
//  "domain": "twitter.com"
//},
//{
//  "title": "github",
//  "url": "https://github.com/Decentr-net",
//  "image_url": "github-com.png",
//  "background_color": "#000",
//  "domain": "github.com"
//},
//{
//  "title": "discord",
//  "url": "https://discord.gg/VMUt7yw92B",
//  "image_url": "discord-gg.png",
//  "background_color": "#000",
//  "domain": "discord.gg"
//}
