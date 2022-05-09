// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

//mute any telemetry

class TelemetryWrapper {
    
    let profile: Profile
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    static func recordEvent(category: EventCategory, method: EventMethod, object: EventObject, value: EventValue? = nil, extras: [String: Any]? = nil) {
        
    }
    
    static func gleanRecordEvent(category: EventCategory, method: EventMethod, object: EventObject, value: EventValue? = nil, extras: [String: Any]? = nil) {
    }
}

// Enums for Event telemetry.
extension TelemetryWrapper {
    enum EventCategory: String {
        case action = "action"
        case appExtensionAction = "app-extension-action"
        case prompt = "prompt"
        case enrollment = "enrollment"
        case firefoxAccount = "firefox_account"
        case decentrAccount = "decentr_account"
    }
    
    enum EventMethod: String {
        case add = "add"
        case background = "background"
        case cancel = "cancel"
        case change = "change"
        case close = "close"
        case closeAll = "close-all"
        case delete = "delete"
        case deleteAll = "deleteAll"
        case drag = "drag"
        case drop = "drop"
        case foreground = "foreground"
        case swipe = "swipe"
        case navigate = "navigate"
        case open = "open"
        case press = "press"
        case pull = "pull"
        case scan = "scan"
        case share = "share"
        case tap = "tap"
        case translate = "translate"
        case view = "view"
        case applicationOpenUrl = "application-open-url"
        case emailLogin = "email"
        case qrPairing = "pairing"
        case settings = "settings"
    }
    
    enum EventObject: String {
        case app = "app"
        case bookmark = "bookmark"
        case bookmarksPanel = "bookmarks-panel"
        case download = "download"
        case downloadLinkButton = "download-link-button"
        case downloadNowButton = "download-now-button"
        case downloadsPanel = "downloads-panel"
        case keyCommand = "key-command"
        case locationBar = "location-bar"
        case qrCodeText = "qr-code-text"
        case qrCodeURL = "qr-code-url"
        case readerModeCloseButton = "reader-mode-close-button"
        case readerModeOpenButton = "reader-mode-open-button"
        case readingListItem = "reading-list-item"
        case setting = "setting"
        case tab = "tab"
        case tabTray = "tab-tray"
        case groupedTab = "grouped-tab"
        case groupedTabPerformSearch = "grouped-tab-perform-search"
        case trackingProtectionStatistics = "tracking-protection-statistics"
        case trackingProtectionSafelist = "tracking-protection-safelist"
        case trackingProtectionMenu = "tracking-protection-menu"
        case url = "url"
        case searchText = "searchText"
        case whatsNew = "whats-new"
        case dismissUpdateCoverSheetAndStartBrowsing = "dismissed-update-cover_sheet_and_start_browsing"
        case dismissedUpdateCoverSheet = "dismissed-update-cover-sheet"
        case dismissedETPCoverSheet = "dismissed-etp-sheet"
        case dismissETPCoverSheetAndStartBrowsing = "dismissed-etp-cover-sheet-and-start-browsing"
        case dismissETPCoverSheetAndGoToSettings = "dismissed-update-cover-sheet-and-go-to-settings"
        case privateBrowsingButton = "private-browsing-button"
        case startSearchButton = "start-search-button"
        case addNewTabButton = "add-new-tab-button"
        case removeUnVerifiedAccountButton = "remove-unverified-account-button"
        case tabSearch = "tab-search"
        case tabToolbar = "tab-toolbar"
        case chinaServerSwitch = "china-server-switch"
        case accountConnected = "connected"
        case accountDisconnected = "disconnected"
        case appMenu = "app_menu"
        case settings = "settings"
        case settingsMenuSetAsDefaultBrowser = "set-as-default-browser-menu-go-to-settings"
        case onboarding = "onboarding"
        case welcomeScreenView = "welcome-screen-view"
        case welcomeScreenClose = "welcome-screen-close"
        case welcomeScreenSignIn = "welcome-screen-sign-in"
        case welcomeScreenSignUp = "welcome-screen-sign-up"
        case welcomeScreenNext = "welcome-screen-next"
        case syncScreenView = "sync-screen-view"
        case syncScreenSignUp = "sync-screen-sign-up"
        case syncScreenStartBrowse = "sync-screen-start-browse"
        case dismissedOnboarding = "dismissed-onboarding"
        case dismissedOnboardingSignUp = "dismissed-onboarding-sign-up"
        case dismissedOnboardingEmailLogin = "dismissed-onboarding-email-login"
        case dismissDefaultBrowserCard = "default-browser-card"
        case goToSettingsDefaultBrowserCard = "default-browser-card-go-to-settings"
        case dismissDefaultBrowserOnboarding = "default-browser-onboarding"
        case goToSettingsDefaultBrowserOnboarding = "default-browser-onboarding-go-to-settings"
        case asDefaultBrowser = "as-default-browser"
        case mediumTabsOpenUrl = "medium-tabs-widget-url"
        case largeTabsOpenUrl = "large-tabs-widget-url"
        case smallQuickActionSearch = "small-quick-action-search"
        case mediumQuickActionSearch = "medium-quick-action-search"
        case mediumQuickActionPrivateSearch = "medium-quick-action-private-search"
        case mediumQuickActionCopiedLink = "medium-quick-action-copied-link"
        case mediumQuickActionClosePrivate = "medium-quick-action-close-private"
        case mediumTopSitesWidget = "medium-top-sites-widget"
        case topSiteTile = "top-site-tile"
        case pocketStory = "pocket-story"
        case pocketSectionImpression = "pocket-section-impression"
        case library = "library"
        case home = "home-page"
        case blockImagesEnabled = "block-images-enabled"
        case blockImagesDisabled = "block-images-disabled"
        case navigateTabHistoryBack = "navigate-tab-history-back"
        case navigateTabHistoryBackSwipe = "navigate-tab-history-back-swipe"
        case navigateTabHistoryForward = "navigate-tab-history-forward"
        case nightModeEnabled = "night-mode-enabled"
        case nightModeDisabled = "night-mode-disabled"
        case logins = "logins-and-passwords"
        case signIntoSync = "sign-into-sync"
        case syncTab = "sync-tab"
        case syncSignIn = "sync-sign-in"
        case syncCreateAccount = "sync-create-account"
        case libraryPanel = "library-panel"
        case sharePageWith = "share-page-with"
        case sendToDevice = "send-to-device"
        case copyAddress = "copy-address"
        case reportSiteIssue = "report-site-issue"
        case findInPage = "find-in-page"
        case requestDesktopSite = "request-desktop-site"
        case requestMobileSite = "request-mobile-site"
        case pinToTopSites = "pin-to-top-sites"
        case removePinnedSite = "remove-pinned-site"
        case firefoxHomepage = "decentr-homepage"
        case wallpaperSettings = "wallpaper-settings"
        case jumpBackInImpressions = "jump-back-in-impressions"
        case historyImpressions = "history-highlights-impressions"
        case recentlySavedBookmarkImpressions = "recently-saved-bookmark-impressions"
        case recentlySavedReadingItemImpressions = "recently-saved-reading-items-impressions"
        case inactiveTabTray = "inactiveTabTray"
        case reload = "reload"
        case reloadFromUrlBar = "reload-from-url-bar"
    }
    
    enum EventValue: String {
        case activityStream = "activity-stream"
        case appMenu = "app-menu"
        case awesomebarResults = "awesomebar-results"
        case browser = "browser"
        case contextMenu = "context-menu"
        case downloadCompleteToast = "download-complete-toast"
        case homePanel = "home-panel"
        case markAsRead = "mark-as-read"
        case markAsUnread = "mark-as-unread"
        case pageActionMenu = "page-action-menu"
        case readerModeToolbar = "reader-mode-toolbar"
        case readingListPanel = "reading-list-panel"
        case shareExtension = "share-extension"
        case shareMenu = "share-menu"
        case tabTray = "tab-tray"
        case topTabs = "top-tabs"
        case systemThemeSwitch = "system-theme-switch"
        case themeModeManually = "theme-manually"
        case themeModeAutomatically = "theme-automatically"
        case themeLight = "theme-light"
        case themeDark = "theme-dark"
        case privateTab = "private-tab"
        case normalTab = "normal-tab"
        case tabView = "tab-view"
        case bookmarksPanel = "bookmarks-panel"
        case historyPanel = "history-panel"
        case readingPanel = "reading-panel"
        case downloadsPanel = "downloads-panel"
        case syncPanel = "sync-panel"
        case yourLibrarySection = "your-library-section"
        case jumpBackInSectionShowAll = "jump-back-in-section-show-all"
        case jumpBackInSectionTabOpened = "jump-back-in-section-tab-opened"
        case jumpBackInSectionGroupOpened = "jump-back-in-section-group-opened"
        case recentlySavedSectionShowAll = "recently-saved-section-show-all"
        case recentlySavedBookmarkItemAction = "recently-saved-bookmark-item-action"
        case recentlySavedBookmarkItemView = "recently-saved-bookmark-item-view"
        case recentlySavedReadingListView = "recently-saved-reading-list-view"
        case recentlySavedReadingListAction = "recently-saved-reading-list-action"
        case historyHighlightsShowAll = "history-highlights-show-all"
        case historyHighlightsItemOpened = "history-highlights-item-opened"
        case customizeHomepageButton = "customize-homepage-button"
        case cycleWallpaperButton = "cycle-wallpaper-button"
        case toggleLogoWallpaperButton = "toggle-logo-wallpaper-button"
        case wallpaperSelected = "wallpaper-selected"
        case fxHomepageOrigin = "decentr-homepage-origin"
        case fxHomepageOriginZeroSearch = "zero-search"
        case fxHomepageOriginOther = "origin-other"
        case addBookmarkToast = "add-bookmark-toast"
        case openHomeFromAwesomebar = "open-home-from-awesomebar"
        case openHomeFromPhotonMenuButton = "open-home-from-photon-menu-button"
        case openInactiveTab = "openInactiveTab"
        case inactiveTabExpand = "inactivetab-expand"
        case inactiveTabCollapse = "inactivetab-collapse"
        case openRecentlyClosedList = "openRecentlyClosedList"
        case openRecentlyClosedTab = "openRecentlyClosedTab"
        case tabGroupWithExtras = "tabGroupWithExtras"
        case closeGroupedTab = "recordCloseGroupedTab"
    }
    
    enum EventExtraKey: String, CustomStringConvertible {
        case topSitePosition = "tilePosition"
        case topSiteTileType = "tileType"
        case pocketTilePosition = "pocketTilePosition"
        case fxHomepageOrigin = "fxHomepageOrigin"
        
        case preference = "pref"
        case preferenceChanged = "to"
        
        case wallpaperName = "wallpaperName"
        case wallpaperType = "wallpaperType"
        
        // Grouped Tab
        case groupsWithTwoTabsOnly = "groupsWithTwoTabsOnly"
        case groupsWithTwoMoreTab = "groupsWithTwoMoreTab"
        case totalNumberOfGroups = "totalNumOfGroups"
        case averageTabsInAllGroups = "averageTabsInAllGroups"
        case totalTabsInAllGroups = "totalTabsInAllGroups"
        var description: String {
            return self.rawValue
        }
    }
}

// MARK: - Decentr Home Page
extension TelemetryWrapper {
    
    /// Bundle the extras dictionnary for the home page origin
    static func getOriginExtras(isZeroSearch: Bool) -> [String: String] {
        [:]
    }
}
