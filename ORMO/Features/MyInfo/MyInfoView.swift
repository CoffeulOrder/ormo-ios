import SwiftUI

struct MyInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @State private var viewModel = MyInfoViewModel()
    let onLogout: (String?) -> Void

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.spacing8) {
                    profileCard
                    listItem("주문 내역", action: orderHistoryTapped)
                    listItem("비밀번호 바꾸기", action: changePasswordTapped)
                    listItem("권한 설정", verticalPadding: Spacing.spacing16, action: notificationSettingsTapped)
                    listItem("약관 및 정책", action: termsTapped)
                    listItem("로그아웃", action: logoutTapped)
                    listItem("탈퇴하기", textColor: Colors.textQuaternary, action: withdrawTapped)
                }
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .task { await viewModel.loadProfileIfNeeded() }
        .alertDialogOverlay(isPresented: $viewModel.isLogoutDialogVisible) {
            AlertDialog(
                title: "로그아웃할까요?",
                message: "학교 이메일로 다시 로그인해주세요",
                secondaryTitle: "취소",
                primaryTitle: "로그아웃",
                secondaryAction: { viewModel.isLogoutDialogVisible = false },
                primaryAction: {
                    viewModel.isLogoutDialogVisible = false
                    onLogout(nil)
                }
            )
        }
        .alertDialogOverlay(isPresented: $viewModel.isWithdrawBlockedDialogVisible) {
            AlertDialog(
                title: "진행 중인 주문이 \(viewModel.ongoingOrderCount)건 있어요",
                message: "주문이 끝난 뒤에 탈퇴할 수 있어요",
                secondaryTitle: "닫기",
                primaryTitle: "주문 보기",
                secondaryAction: { viewModel.isWithdrawBlockedDialogVisible = false },
                primaryAction: {
                    viewModel.isWithdrawBlockedDialogVisible = false
                    router.path.append(HomeRoute.orderHistory)
                }
            )
        }
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("내 정보")
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

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing4) {
            Text(viewModel.profile?.name ?? "")
                .font(Typography.bodyXlSemibold)
                .foregroundStyle(Colors.textPrimary)
            Text(viewModel.profile?.email ?? "")
                .font(Typography.bodyMdRegular)
                .foregroundStyle(Colors.textSecondary)
            Text(viewModel.profile?.schoolName ?? "")
                .font(Typography.bodySmRegular)
                .foregroundStyle(Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.spacing20)
        .background(Colors.fillNeutralWeak)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.spacing20)
        .padding(.top, Spacing.spacing8)
        .padding(.bottom, Spacing.spacing16)
    }

    private func listItem(
        _ title: String,
        textColor: Color = Colors.textPrimary,
        verticalPadding: CGFloat = Spacing.spacing12,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing12) {
                Text(title)
                    .font(Typography.bodyMdMedium)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(.chevronRight)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Colors.iconTertiary)
            }
            .padding(.horizontal, Spacing.spacing24)
            .padding(.vertical, verticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func orderHistoryTapped() {
        router.path.append(HomeRoute.orderHistory)
    }

    private func changePasswordTapped() {
        router.path.append(HomeRoute.changePassword(email: viewModel.profile?.email ?? ""))
    }

    private func notificationSettingsTapped() {
        router.path.append(HomeRoute.notificationSettings)
    }

    private func termsTapped() {
        router.path.append(HomeRoute.termsAndPolicy)
    }

    private func logoutTapped() {
        viewModel.isLogoutDialogVisible = true
    }

    private func withdrawTapped() {
        if viewModel.hasOngoingOrders {
            viewModel.isWithdrawBlockedDialogVisible = true
        } else {
            router.path.append(HomeRoute.withdraw)
        }
    }
}

#Preview {
    NavigationStack {
        MyInfoView(onLogout: { _ in })
    }
    .environment(HomeRouter())
}
