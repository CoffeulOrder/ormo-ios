import SwiftUI

struct OrderHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @State private var viewModel: OrderHistoryViewModel
    let cart: CartStore

    init(cart: CartStore, viewModel: OrderHistoryViewModel = OrderHistoryViewModel()) {
        self.cart = cart
        _viewModel = State(initialValue: viewModel)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yy.MM.dd (E)"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            if viewModel.isLoaded && viewModel.orders.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.orders.enumerated()), id: \.element.pickupNumber) { index, order in
                            orderCard(order)
                            if index != viewModel.orders.count - 1 {
                                Colors.backgroundLower.frame(height: Spacing.spacing12)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .navigationBarHidden(true)
        .task { await viewModel.loadIfNeeded() }
        .alertDialogOverlay(isPresented: $viewModel.isSoldOutDialogVisible) {
            AlertDialog(
                title: "메뉴가 모두 품절이에요",
                message: "다른 메뉴를 선택해 주세요",
                secondaryTitle: "닫기",
                primaryTitle: "메뉴 보기",
                secondaryAction: { viewModel.isSoldOutDialogVisible = false },
                primaryAction: {
                    viewModel.isSoldOutDialogVisible = false
                    router.path = NavigationPath()
                }
            )
        }
    }

    private var topNavigationBar: some View {
        ZStack {
            Text("주문 내역")
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

    private var emptyView: some View {
        ResultView(
            icon: .coffeeIcon,
            title: "주문 내역이 없어요",
            message: nil,
            buttonTitle: "메뉴 보기",
            action: { router.path = NavigationPath() }
        )
        .padding(.top, 120)
    }

    private func orderCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { headerTapped(order) }) {
                HStack(spacing: Spacing.spacing8) {
                    Text("\(order.storeName) ∙ \(Self.dateFormatter.string(from: order.paidAt))")
                        .typography(Typography.bodySmMedium)
                        .foregroundStyle(Colors.textSecondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(.chevronRight)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Colors.iconTertiary)
                }
                .padding(.vertical, Spacing.spacing12)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: Spacing.spacing16) {
                ForEach(order.items) { item in
                    VStack(alignment: .leading, spacing: Spacing.spacing8) {
                        HStack(spacing: Spacing.spacing4) {
                            Text(item.name)
                                .typography(Typography.bodyMdSemibold)
                                .foregroundStyle(Colors.textPrimary)
                            Text("\(item.quantity)개")
                                .typography(Typography.bodySmMedium)
                                .foregroundStyle(Colors.textSecondary)
                        }
                        Text(item.optionsSummary)
                            .typography(Typography.bodySmRegular)
                            .foregroundStyle(Colors.textSecondary)
                    }
                }

                Rectangle()
                    .fill(Colors.borderDefault)
                    .frame(height: 1)

                HStack {
                    if order.status == .cancelled {
                        Text("\(order.subtotalPrice.formatted())원")
                            .strikethrough()
                            .typography(Typography.bodyMdSemibold)
                            .foregroundStyle(Colors.textQuaternary)
                    } else {
                        Text("\(order.subtotalPrice.formatted())원")
                            .typography(Typography.bodyMdSemibold)
                            .foregroundStyle(Colors.textPrimary)
                    }

                    Spacer()

                    Text(order.status == .cancelled ? "매장 주문 취소" : "픽업 완료")
                        .typography(Typography.bodySmMedium)
                        .foregroundStyle(Colors.textSecondary)
                }
            }

            actionButton(for: order)
                .padding(.vertical, Spacing.spacing16)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing12)
    }

    @ViewBuilder
    private func actionButton(for order: Order) -> some View {
        if order.status == .cancelled {
            Button(action: { browseMenuTapped() }) {
                Text("메뉴 보러 가기")
                    .typography(Typography.bodyMdSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Colors.fillBrand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r14))
            }
            .buttonStyle(.plain)
        } else {
            Button(action: { reorderTapped(order) }) {
                Text("재주문하기")
                    .typography(Typography.bodyMdSemibold)
                    .foregroundStyle(Colors.textOnFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Colors.fillBrand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r14))
            }
            .buttonStyle(.plain)
        }
    }

    private func headerTapped(_ order: Order) {
        router.path.append(HomeRoute.orderDetailHistory(order))
    }

    private func browseMenuTapped() {
        router.path = NavigationPath()
    }

    private func reorderTapped(_ order: Order) {
        Task {
            guard let lineItems = await viewModel.reorderLineItems(for: order) else {
                viewModel.isSoldOutDialogVisible = true
                return
            }
            for lineItem in lineItems {
                cart.addSilently(lineItem)
            }
            router.path.append(HomeRoute.cart)
        }
    }
}

#Preview {
    NavigationStack {
        OrderHistoryView(cart: CartStore())
    }
    .environment(HomeRouter())
}

#Preview("빈 목록") {
    NavigationStack {
        OrderHistoryView(cart: CartStore(), viewModel: OrderHistoryViewModel(orderHistoryRepository: EmptyOrderHistoryRepository()))
    }
    .environment(HomeRouter())
}

private struct EmptyOrderHistoryRepository: OrderHistoryRepository {
    func fetchOrderHistory() async throws -> [Order] { [] }
}
