import SwiftUI

struct AppCard<Content: View>: View {
    var accent: Color?
    let content: Content

    init(accent: Color? = nil, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appSurface(elevation: .medium, accent: accent, tintStrength: accent != nil ? 0.08 : 0)
    }
}

struct AppInsetCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .appInsetSurface()
    }
}
