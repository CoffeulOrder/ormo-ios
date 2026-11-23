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
                        systemDisabledCallout
                    }
                    listItem(
                        title: "주문 알림",
                        description: "음료가 준비되거나\n주문 상태가 변경되면 알려드려요",
                        isOn: Binding(
                            get: { viewModel.isOrderNotificationEnabled },
                            set: { viewModel.orderNotificationToggled(to: $0) }
                        )
                    )
                    listItem(
                        title: "잠금 화면 실시간 현황",
                        description: "주문 상태를 잠금 화면에서 확인할 수 있어요",
                        isOn: $viewModel.isLockScreenLiveStatusEnabled
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .task { await viewModel.refreshSystemNotificationStatus() }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task { await viewModel.refreshSystemNotificationStatus() }
            }
        }
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("알림 설정")
                .font(Typography.bodyLgSemibold)
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

    private var systemDisabledCallout: some View {
        Button(action: viewModel.openSystemSettingsTapped) {
            HStack(alignment: .top, spacing: Spacing.spacing8) {
                Image(.calloutWarningIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: Spacing.spacing2) {
                    Text("ORMO 알림이 꺼져 있어요")
                        .font(Typography.bodySmBold)
                        .foregroundStyle(Colors.textWarning)
                    Text("주문 알림을 받으려면\n휴대폰 설정에서 알림을 켜주세요")
                        .font(Typography.bodySmRegular)
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

    private func listItem(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.spacing12) {
            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                Text(title)
                    .font(Typography.bodyMdMedium)
                    .foregroundStyle(Colors.textPrimary)
                Text(description)
                    .font(Typography.bodySmRegular)
                    .foregroundStyle(Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Colors.fillBrand)
        }
        .padding(.horizontal, Spacing.spacing24)
        .padding(.vertical, Spacing.spacing16)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
