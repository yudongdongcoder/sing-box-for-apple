
import Library
import SwiftUI

public struct SettingView: View {
    private enum Tabs: Int, CaseIterable, Identifiable {
        public var id: Self {
            self
        }

        #if os(macOS)
            case app
        #endif

        case core, packetTunnel, onDemandRules, profileOverride, sponsors

        var label: some View {
            Label(title, systemImage: iconImage)
        }

        var title: String {
            switch self {
            #if os(macOS)
                case .app:
                    return NSLocalizedString("App", comment: "")
            #endif
            case .core:
                return NSLocalizedString("Core", comment: "")
            case .packetTunnel:
                return NSLocalizedString("Packet Tunnel", comment: "")
            case .onDemandRules:
                return NSLocalizedString("On Demand Rules", comment: "")
            case .profileOverride:
                return NSLocalizedString("Profile Override", comment: "")
            case .sponsors:
                return NSLocalizedString("Sponsors", comment: "")
            }
        }

        private var iconImage: String {
            switch self {
            #if os(macOS)
                case .app:
                    return "app.badge.fill"
            #endif
            case .core:
                return "shippingbox.fill"
            case .packetTunnel:
                return "aspectratio.fill"
            case .onDemandRules:
                return "filemenu.and.selection"
            case .profileOverride:
                return "square.dashed.inset.filled"
            case .sponsors:
                return "heart.fill"
            }
        }

        @MainActor
        var contentView: some View {
            viewBuilder {
                switch self {
                #if os(macOS)
                    case .app:
                        MacAppView()
                #endif
                case .core:
                    CoreView()
                case .packetTunnel:
                    PacketTunnelView()
                case .onDemandRules:
                    OnDemandRulesView()
                case .profileOverride:
                    ProfileOverrideView()
                case .sponsors:
                    SponsorsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            #if os(iOS)
                .background(Color(uiColor: .systemGroupedBackground))
            #endif
        }

        @MainActor
        var navigationLink: some View {
            FormNavigationLink {
                contentView
            } label: {
                label
            }
        }
    }

    @State private var isLoading = true
    @State private var taiwanFlagAvailable = false

    public init() {}
    public var body: some View {
        FormView {
            #if os(macOS)
                Tabs.app.navigationLink
            #endif
            ForEach([Tabs.core, Tabs.packetTunnel, Tabs.onDemandRules, Tabs.profileOverride]) { it in
                it.navigationLink
            }
            #if !os(tvOS)
                Section("About") {
                    Link(destination: URL(string: "https://sing-box.sagernet.org/")!) {
                        Label("Documentation", systemImage: "doc.on.doc.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    RequestReviewButton {
                        Label("Rate on the App Store", systemImage: "text.bubble.fill")
                    }
                    #if os(macOS)
                        if Variant.useSystemExtension {
                            Tabs.sponsors.navigationLink
                        }
                    #endif
                }
            #endif
            Section("Debug") {
                FormNavigationLink {
                    ServiceLogView()
                } label: {
                    Label("Service Log", systemImage: "doc.on.clipboard")
                }
                FormTextItem("Taiwan Flag Available", "touchid") {
                    if isLoading {
                        Text("Loading...")
                            .onAppear {
                                Task.detached {
                                    let available: Bool
                                    if ApplicationLibrary.inPreview {
                                        available = true
                                    } else {
                                        available = !DeviceCensorship.isChinaDevice()
                                    }
                                    await MainActor.run {
                                        taiwanFlagAvailable = available
                                        isLoading = false
                                    }
                                }
                            }
                    } else {
                        Text(taiwanFlagAvailable.description)
                    }
                }
            }
        }
    }
}
