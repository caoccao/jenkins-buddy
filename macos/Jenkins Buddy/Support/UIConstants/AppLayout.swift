import CoreGraphics

enum AppLayout {
    static let minimumWindowWidth: CGFloat = 900
    static let minimumWindowHeight: CGFloat = 600
    static let defaultWindowWidth: CGFloat = 980
    static let defaultWindowHeight: CGFloat = 680
    static let settingsWidth: CGFloat = 820
    static let settingsHeight: CGFloat = 560
    static let settingsSidebarMinimumWidth: CGFloat = 200
    static let settingsSidebarWidth: CGFloat = 220
    static let settingsSidebarMaximumWidth: CGFloat = 260
    static let settingsContentWidth: CGFloat = 640
    static let statusBarHeight: CGFloat = 26
    static let contentPadding: CGFloat = 20
}

enum UIConstants {
    enum Jobs {
        /// Horizontal inset for the job-search control.
        static let searchHorizontalPadding: CGFloat = 12
        /// Horizontal gap between the search symbol and text field.
        static let searchSpacing: CGFloat = 8
        /// Fixed height of the job-search bar above a populated tree.
        static let searchBarHeight: CGFloat = 36
    }

    enum Toolbar {
        /// Horizontal gap between toolbar controls.
        static let controlSpacing: CGFloat = 10
        /// Horizontal inset around the toolbar's controls.
        static let horizontalPadding: CGFloat = 12
        /// Fixed height of the in-window toolbar.
        static let height: CGFloat = 36
        /// Gap between the detail and card view buttons.
        static let viewModeSpacing: CGFloat = 2
        /// Square hit target used by each view-mode button.
        static let viewModeButtonSize: CGFloat = 26
        /// Corner radius of the selected view-mode highlight.
        static let viewModeCornerRadius: CGFloat = 6
    }

    enum JobDetail {
        /// Vertical spacing between the job header, metadata, and builds.
        static let sectionSpacing: CGFloat = 18
        /// Vertical spacing between the job name and server link.
        static let titleSpacing: CGFloat = 4
        /// Horizontal spacing in the job metadata grid.
        static let metadataHorizontalSpacing: CGFloat = 16
        /// Vertical spacing in the job metadata grid.
        static let metadataVerticalSpacing: CGFloat = 7
        /// Minimum width of an adaptive build card.
        static let cardMinimumWidth: CGFloat = 300
        /// Gap between build cards.
        static let cardSpacing: CGFloat = 14
        /// Horizontal spacing between labels and values within a build card.
        static let cardContentColumnSpacing: CGFloat = 16
        /// Vertical spacing between values within a build card.
        static let cardContentRowSpacing: CGFloat = 8
        /// Horizontal spacing between columns in the detailed build table.
        static let detailColumnSpacing: CGFloat = 16
        /// Vertical spacing between rows in the detailed build table.
        static let detailRowSpacing: CGFloat = 10
        /// Inset within the detailed build table surface.
        static let detailPadding: CGFloat = 12
        /// Corner radius of the detailed build table surface.
        static let detailCornerRadius: CGFloat = 8
    }

    enum Settings {
        /// Horizontal gap between a settings label and its control.
        static let rowSpacing: CGFloat = 12
        /// Width reserved for leading labels so controls align vertically.
        static let labelWidth: CGFloat = 180
        /// Vertical gap between a control row and its supporting text.
        static let hintSpacing: CGFloat = 6
        /// Width of compact numeric fields in settings rows.
        static let numericFieldWidth: CGFloat = 80
    }

    enum Tabs {
        static let height: CGFloat = 34
        static let minimumWidth: CGFloat = 128
        static let maximumWidth: CGFloat = 220
        /// Opacity of the accent wash across the selected tab surface.
        static let selectedBackgroundOpacity: CGFloat = 0.12
        /// Height of the accent indicator under the selected tab.
        static let selectionIndicatorHeight: CGFloat = 2
    }
}
