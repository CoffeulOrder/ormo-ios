import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = NotificationSettingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.isSystemNotificationDenied {
                        disabledCallout(
                            title: "ORMO 알림이 꺼져 있어요",
                            message: "주문 알림을 받으려면\n휴대폰 설정에서 알림을 켜주세요"
                        )
                    }
                    if viewModel.isSystemLocationDenied {
                        disabledCallout(
                            title: "위치 권한이 꺼져 있어요",
                            message: "매장까지 거리를 보려면 휴대폰 설정에서\n위치를 켜 주세요"
                        )
                    }

                    sectionHeader("알림")
                    listItem(
                        title: "주문 알림",
                        description: "음료가 준비되거나\n주문 상태가 변경되면 알려드려요",
                        isOn: Binding(
                            get: { viewModel.isOrderNotificationEffectivelyOn },
                            set: { viewModel.orderNotificationToggled(to: $0) }
                        ),
                        isDisabled: viewModel.isSystemNotificationDenied
                    )
                    listItem(
                        title: "잠금 화면 실시간 현황",
                        description: "주문 상태를 잠금 화면에서 확인할 수 있어요",
                        isOn: Binding(
                            get: { viewModel.isLockScreenLiveStatusEffectivelyOn },
                            set: { viewModel.isLockScreenLiveStatusEnabled = $0 }
                        ),
                        isDisabled: viewModel.isSystemNotificationDenied
                    )

                    sectionHeader("위치")
                    listItem(
                        title: "내 위치 사용",
                        description: "매장까지 거리와 도보 시간을 보여줘요",
                        isOn: Binding(
                            get: { viewModel.isLocationEffectivelyOn },
                            set: { viewModel.locationToggled(to: $0) }
                        ),
                        isDisabled: viewModel.isSystemLocationDenied
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.refreshSystemNotificationStatus()
            viewModel.refreshSystemLocationStatus()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task { await viewModel.refreshSystemNotificationStatus() }
                viewModel.refreshSystemLocationStatus()
            }
        }
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("권한 설정")
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textStrong)

            HStack(spacing: 0) {
                Button(action: { dismiss() }) {
                    Image(.arrowBackIos)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private func disabledCallout(title: String, message: String) -> some View {
        Button(action: viewModel.openSystemSettingsTapped) {
            HStack(alignment: .top, spacing: Spacing.spacing8) {
                Image(.calloutWarningIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: Spacing.spacing2) {
                    Text(title)
                        .typography(Typography.bodySmBold)
                        .foregroundStyle(Colors.textWarning)
                    Text(message)
                        .typography(Typography.bodySmRegular)
                        .foregroundStyle(Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.spacing16)
            .padding(.vertical, Spacing.spacing12)
            .background(Colors.fillWarningWeak)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.spacing16)
        .padding(.top, Spacing.spacing16)
        .padding(.bottom, Spacing.spacing8)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .typography(Typography.bodyLgSemibold)
            .foregroundStyle(Colors.textSecondary)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.top, Spacing.spacing16)
            .padding(.bottom, Spacing.spacing8)
    }

    private func listItem(title: String, description: String, isOn: Binding<Bool>, isDisabled: Bool = false) -> some View {
        HStack(spacing: Spacing.spacing12) {
            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                Text(title)
                    .typography(Typography.bodyMdMedium)
                    .foregroundStyle(isDisabled ? Colors.textQuaternary : Colors.textPrimary)
                Text(description)
                    .typography(Typography.bodySmRegular)
                    .foregroundStyle(isDisabled ? Colors.textQuaternary : Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Colors.fillBrand)
                .disabled(isDisabled)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing16)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
