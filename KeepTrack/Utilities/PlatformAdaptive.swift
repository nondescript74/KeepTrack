//
//  PlatformAdaptive.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import SwiftUI

// MARK: - Platform Detection

/// Platform-independent navigation bar title display mode
enum NavigationBarItemTitleDisplayMode {
    case automatic
    case inline
    case large
    
    #if os(iOS)
    func toNative() -> NavigationBarItem.TitleDisplayMode {
        switch self {
        case .automatic: return .automatic
        case .inline: return .inline
        case .large: return .large
        }
    }
    #endif
}

struct Platform {
    static let isIOS: Bool = {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }()
    
    static let isMacOS: Bool = {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }()
}

// MARK: - View Extensions for Cross-Platform Support

extension View {
    /// Applies navigation bar title display mode on iOS, does nothing on macOS
    @ViewBuilder
    func navigationBarTitleDisplayModeAdaptive(_ mode: NavigationBarItemTitleDisplayMode) -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(mode.toNative())
        #else
        self
        #endif
    }
    
    /// Applies platform-appropriate toolbar item placement
    @ViewBuilder
    func toolbarItemAdaptive<Content: View>(
        placement: ToolbarItemPlacement,
        macPlacement: ToolbarItemPlacement? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        #if os(macOS)
        self.toolbar {
            ToolbarItem(placement: macPlacement ?? placement) {
                content()
            }
        }
        #else
        self.toolbar {
            ToolbarItem(placement: placement) {
                content()
            }
        }
        #endif
    }
    
    /// Applies platform-appropriate frame sizing for sheets/modals
    @ViewBuilder
    func modalFrameAdaptive(width: CGFloat = 600, height: CGFloat = 400) -> some View {
        #if os(macOS)
        self.frame(minWidth: width, minHeight: height)
        #else
        self
        #endif
    }
    
    /// Applies inset grouped list style on iOS, sidebar style on macOS
    @ViewBuilder
    func listStyleAdaptive() -> some View {
        #if os(macOS)
        self.listStyle(.inset(alternatesRowBackgrounds: true))
        #else
        self.listStyle(.insetGrouped)
        #endif
    }
}

// MARK: - Toolbar Placement Helpers

extension ToolbarItemPlacement {
    static var adaptiveConfirmation: ToolbarItemPlacement {
        #if os(macOS)
        return .confirmationAction
        #else
        return .topBarTrailing
        #endif
    }
    
    static var adaptiveCancellation: ToolbarItemPlacement {
        #if os(macOS)
        return .cancellationAction
        #else
        return .topBarLeading
        #endif
    }
    
    static var adaptiveTrailing: ToolbarItemPlacement {
        #if os(macOS)
        return .primaryAction
        #else
        return .topBarTrailing
        #endif
    }
}

// MARK: - Platform-Specific Colors

extension Color {
    static var adaptiveBackground: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .systemBackground)
        #endif
    }
    
    static var adaptiveSecondaryBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }
}

// MARK: - Sheet Presentation Helpers

struct AdaptiveSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    self.sheetContent()
                        .frame(minWidth: 600, minHeight: 400)
                }
            }
        #else
        content
            .sheet(isPresented: $isPresented) {
                self.sheetContent()
            }
        #endif
    }
}

extension View {
    func adaptiveSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(AdaptiveSheet(isPresented: isPresented, sheetContent: content))
    }
}
