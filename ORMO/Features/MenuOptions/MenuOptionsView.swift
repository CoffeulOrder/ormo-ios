import SwiftUI

struct MenuOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeRouter.self) private var router
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: MenuOptionsViewModel

    let searchableMenuItems: [MenuItem]
    let onAddedToCart: () -> Void
    let onOrderNow: () -> Void

    // 버튼이 1개든 2개든 한 줄(56px 높이)이라 하단 CTA 전체 높이가 항상 같다(포그40+버튼56+하단여백32).
    // Bottom CTA가 스크롤 영역 위에 떠 있는 오버레이라, 옵션이 적어 내용이 짧을 때도 마지막 항목이
    // CTA에 가리지 않도록 스크롤 콘텐츠 맨 아래에 이만큼 여백을 미리 둔다.
    private let bottomCTAHeight: CGFloat = 128

    init(
        item: MenuItem,
        cart: CartStore,
        searchableMenuItems: [MenuItem] = [],
        menuRepository: MenuRepository = MockMenuRepository(),
        onAddedToCart: @escaping () -> Void,
        onOrderNow: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: MenuOptionsViewModel(item: item, cart: cart, menuRepository: menuRepository))
        self.searchableMenuItems = searchableMenuItems
        self.onAddedToCart = onAddedToCart
        self.onOrderNow = onOrderNow
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                topNavigationBar
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            headerSection
                            thickDivider
                            ForEach(viewModel.optionGroups) { group in
                                optionGroupSection(group)
                                    .id(group.id)
                            }
                        }
                        .padding(.bottom, bottomCTAHeight)
                    }
                    .onChange(of: viewModel.scrollTrigger) {
                        guard let groupId = viewModel.scrollTargetGroupId else { return }
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(groupId, anchor: .top)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            bottomCTA

            if viewModel.isSnackbarVisible {
                snackbar
                    .padding(.bottom, 97) // 버튼 상단(하단여백32+버튼56=88)에서 9pt 띄움
                    .ignoresSafeArea(edges: .bottom) // bottomCTA와 같은 기준(화면 끝)으로 맞춰야 버튼과의 9pt 간격이 정확해짐
                    .transition(.opacity)
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .animation(.easeOut(duration: 0.2), value: viewModel.isSnackbarVisible)
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.didAddToCart) {
            if viewModel.didAddToCart {
                onAddedToCart()
            }
        }
    }

    private var topNavigationBar: some View {
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

            HStack(spacing: 0) {
                Button(action: searchTapped) {
                    Image(.searchIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                Button(action: myPageTapped) {
                    Image(.userIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.spacing8)
        .frame(height: 56)
        .background(Colors.backgroundDefault)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing16) {
            Text(viewModel.item.name)
                .typography(Typography.bodyXlSemibold)
                .foregroundStyle(Colors.textPrimary)

            Text(viewModel.item.description)
                .typography(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: 10) {
                Text("\(viewModel.item.price.formatted())원")
                    .typography(Typography.bodyXlBold)
                    .foregroundStyle(Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                quantityPicker
            }
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quantityPicker: some View {
        HStack(spacing: 0) {
            quantityButton(isPlus: false)

            Rectangle()
                .fill(Colors.fillNeutralWeak)
                .frame(width: 1, height: 16)

            Text("\(viewModel.quantity)")
                .typography(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textStrong)
                .padding(.horizontal, Spacing.spacing8)
                .frame(minWidth: 36)

            Rectangle()
                .fill(Colors.fillNeutralWeak)
                .frame(width: 1, height: 16)

            quantityButton(isPlus: true)
        }
        .frame(height: 40)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                // 다크모드에서는 BorderDefault가 배경과 거의 같은 색이라 경계가 안 보여서 흰색으로 바꾼다.
                // 라이트모드는 원래 테두리(BorderDefault) 그대로 유지한다.
                .strokeBorder(colorScheme == .dark ? .white : Colors.borderDefault, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private func quantityButton(isPlus: Bool) -> some View {
        let enabled = isPlus ? viewModel.canIncreaseQuantity : viewModel.canDecreaseQuantity
        return Button(action: { isPlus ? viewModel.increaseQuantity() : viewModel.decreaseQuantity() }) {
            Image(isPlus ? .plusIcon : .minusIcon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(enabled ? Colors.textStrong : Colors.textQuaternary)
                .frame(width: 18, height: 18)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func optionGroupSection(_ group: MenuOptionGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            groupHeaderRow(group)
            choicesStack(group)
        }
    }

    private func groupHeaderRow(_ group: MenuOptionGroup) -> some View {
        HStack(spacing: Spacing.spacing8) {
            Text(group.name)
                .typography(Typography.bodyLgSemibold)
                .foregroundStyle(Colors.textPrimary)
            badge(for: group)
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // 배지는 필수/선택 두 가지뿐이다: 필수 = Critical·Weak, 선택 = Brand·Weak (스펙: 307:4978)
    private func badge(for group: MenuOptionGroup) -> some View {
        let background = group.isRequired ? Colors.fillDangerWeak : Colors.fillBrandWeak
        let foreground = group.isRequired ? Colors.textDanger : Colors.textBrand
        return Text(group.isRequired ? "필수" : "선택")
            .typography(Typography.bodyXsMedium)
            .foregroundStyle(foreground)
            .padding(.horizontal, Spacing.spacing8)
            .frame(height: 24)
            .background(background)
            .clipShape(Capsule())
    }

    private func choicesStack(_ group: MenuOptionGroup) -> some View {
        VStack(spacing: Spacing.spacing24) {
            ForEach(group.choices) { choice in
                choiceRow(choice, in: group)
            }
        }
        .padding(.horizontal, Spacing.spacing20)
        .padding(.vertical, Spacing.spacing12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func choiceRow(_ choice: MenuOptionChoice, in group: MenuOptionGroup) -> some View {
        Button(action: { viewModel.choiceTapped(choice, in: group) }) {
            HStack(spacing: Spacing.spacing12) {
                selectionControl(choice, in: group)

                Text(choice.name)
                    .typography(Typography.bodyLgRegular)
                    .foregroundStyle(choice.isSoldOut ? Colors.textQuaternary : Colors.textPrimary)

                Spacer()

                Text(choice.isSoldOut ? "품절" : "+\(choice.priceDelta.formatted())원")
                    .typography(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .disabled(choice.isSoldOut)
    }

    @ViewBuilder
    private func selectionControl(_ choice: MenuOptionChoice, in group: MenuOptionGroup) -> some View {
        let isSelected = viewModel.isSelected(choice, in: group)
        switch group.selectionType {
        case .single:
            Radio(isSelected: isSelected, isEnabled: !choice.isSoldOut, size: 24)
        case .multiple:
            Checkbox(isSelected: isSelected, isEnabled: !choice.isSoldOut, size: 24)
        }
    }

    private var thickDivider: some View {
        Rectangle()
            .fill(Colors.backgroundLower)
            .frame(height: 12)
            .frame(maxWidth: .infinity)
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundDefault.opacity(0), Colors.backgroundDefault],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Spacing.spacing40)

            HStack(spacing: Spacing.spacing8) {
                Button(action: orderNowTapped) {
                    Text("바로 주문")
                        .typography(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textBrand)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.fillBrandWeak)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)

                Button(action: { viewModel.addToCart() }) {
                    Text("\(viewModel.totalPrice.formatted())원 담기")
                        .typography(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textOnFill)
                        .frame(width: 200, height: 56)
                        .background(Colors.fillBrand)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.spacing20)
            .padding(.bottom, Spacing.spacing32)
            .background(Colors.backgroundDefault)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var snackbar: some View {
        Text(viewModel.snackbarMessage)
            .typography(Typography.bodyMdSemibold)
            .foregroundStyle(Colors.textOnFill)
            .padding(.horizontal, Spacing.spacing20)
            .padding(.vertical, Spacing.spacing12)
            .background(Colors.fillNeutral)
            .clipShape(Capsule())
    }

    private func orderNowTapped() {
        guard viewModel.orderNow() else { return }
        onOrderNow()
    }

    private func searchTapped() {
        router.path.append(HomeRoute.search(searchableMenuItems))
    }

    private func myPageTapped() {
        router.path.append(HomeRoute.myInfo)
    }
}

#Preview {
    MenuOptionsView(
        item: MenuItem(id: "coffee-1", name: "아메리카노", price: 4000, description: "산미가 적고 고소한 원두로 내린 기본 커피예요. 진하게 마시려면 샷을 추가해 보세요.", badge: .popular, isSoldOut: false),
        cart: CartStore(),
        onAddedToCart: {},
        onOrderNow: {}
    )
    .environment(HomeRouter())
}
