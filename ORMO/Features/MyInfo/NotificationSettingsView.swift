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
                    if viewModel.isNotificationDenied {
                        disabledCallout(
                            title: "ORMO 알림이 꺼져 있어요",
                            message: "주문 알림을 받으려면\n휴대폰 설정에서 알림을 켜주세요"
                        )
                    }
                    if !viewModel.isLiveActivityOn {
                        disabledCallout(
                            title: "잠금 화면 실시간 현황이 꺼져 있어요",
                            message: "주문 상태를 잠금 화면에서 보려면\n휴대폰 설정에서 켜주세요"
                        )
                    }
                    if viewModel.isLocationDenied {
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
                            get: { viewModel.isNotificationOn },
                            set: { _ in viewModel.notificationToggled() }
                        )
                    )
                    listItem(
                        title: "잠금 화면 실시간 현황",
                        description: "주문 상태를 잠금 화면에서 확인할 수 있어요",
                        isOn: Binding(
                            get: { viewModel.isLiveActivityOn },
                            set: { _ in viewModel.liveActivityToggled() }
                        )
                    )

                    sectionHeader("위치")
                    listItem(
                        title: "내 위치 사용",
                        description: "매장까지 거리와 도보 시간을 보여줘요",
                        isOn: Binding(
                            get: { viewModel.isLocationOn },
                            set: { _ in viewModel.locationToggled() }
                        )
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.refreshSystemNotificationStatus()
        }
        .onChange(of: scenePhase) {
            // 위치·Live Activity 권한은 LocationPermissionManager/ActivityAuthorizationInfo를 직접
            // 읽어서 항상 최신값이라 따로 새로고침할 필요가 없다. 알림 권한만 OS에 비동기로
            // 물어봐야 해서(UNUserNotificationCenter), 설정 앱에 다녀온 뒤(.active) 다시 읽는다.
            if scenePhase == .active {
                Task { await viewModel.refreshSystemNotificationStatus() }
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

    // 권한이 이미 거부된 상태에서도 토글을 탭하면 설정 앱으로 보내야 해서(viewModel의
    // ...Toggled()가 항상 처리) disabled로 막지 않는다 — 눌러서 바로 설정으로 갈 수 있어야 한다.
    private func listItem(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.spacing12) {
            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                Text(title)
                    .typography(Typography.bodyMdMedium)
                    .foregroundStyle(Colors.textPrimary)
                Text(description)
                    .typography(Typography.bodySmRegular)
                    .foregroundStyle(Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Colors.fillBrand)
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
