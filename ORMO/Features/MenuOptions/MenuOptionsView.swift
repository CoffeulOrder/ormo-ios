import SwiftUI

struct MenuOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MenuOptionsViewModel

    let onAddedToCart: () -> Void
    let onOrderNow: () -> Void

    init(
        item: MenuItem,
        cart: CartStore,
        menuRepository: MenuRepository = MockMenuRepository(),
        onAddedToCart: @escaping () -> Void,
        onOrderNow: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: MenuOptionsViewModel(item: item, cart: cart, menuRepository: menuRepository))
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
                    }
                    .onChange(of: viewModel.scrollTrigger) {
                        guard let groupId = viewModel.scrollTargetGroupId else { return }
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(groupId, anchor: .top)
                        }
                    }
                }
                bottomCTA
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if viewModel.isSnackbarVisible {
                snackbar
                    .padding(.bottom, 104)
                    .transition(.opacity)
            }
        }
        .background(Colors.backgroundDefault.ignoresSafeArea())
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
                Button(action: {}) {
                    Image(.searchIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
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
                .font(Typography.bodyXlSemibold)
                .foregroundStyle(Colors.textPrimary)

            Text(viewModel.item.description)
                .font(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textSecondary)

            HStack(spacing: 10) {
                Text("\(viewModel.item.price.formatted())원")
                    .font(Typography.bodyXlBold)
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
                .fill(Colors.fieldBorder)
                .frame(width: 1, height: 16)

            Text("\(viewModel.quantity)")
                .font(Typography.bodyMdMedium)
                .foregroundStyle(Colors.textStrong)
                .frame(minWidth: 36)
                .padding(.horizontal, Spacing.spacing8)

            Rectangle()
                .fill(Colors.fieldBorder)
                .frame(width: 1, height: 16)

            quantityButton(isPlus: true)
        }
        .frame(height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .strokeBorder(Colors.fieldBorder, lineWidth: 1)
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
                .font(Typography.bodyLgSemibold)
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
            .font(Typography.bodyXsMedium)
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
                    .font(Typography.bodyLgRegular)
                    .foregroundStyle(choice.isSoldOut ? Colors.textQuaternary : Colors.textPrimary)

                Spacer()

                Text(choice.isSoldOut ? "품절" : "+\(choice.priceDelta.formatted())원")
                    .font(Typography.bodyMdRegular)
                    .foregroundStyle(Colors.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .disabled(choice.isSoldOut)
    }

    @ViewBuilder
    private func selectionControl(_ choice: MenuOptionChoice, in group: MenuOptionGroup) -> some View {
        let isSelected = viewModel.isSelected(choice, in: group)
        // Radio(단일 선택)는 선택 시 Fill/Brand 원 + 흰 점으로 바뀌지만,
        // Checkbox(다중 선택)는 선택 여부와 무관하게 테두리 원 그대로 두고 체크 표시만 더한다.
        let isBrandFilled = isSelected && group.selectionType == .single
        ZStack {
            Circle()
                .fill(isBrandFilled ? Colors.fillBrand : (choice.isSoldOut ? Colors.fillNeutralWeak : Color.clear))
            Circle()
                .strokeBorder(choice.isSoldOut ? Colors.borderDefault : Colors.fieldBorder, lineWidth: isBrandFilled ? 0 : 2)

            if isSelected {
                switch group.selectionType {
                case .single:
                    Circle()
                        .fill(Colors.textOnFill)
                        .frame(width: 8, height: 8)
                case .multiple:
                    Image(.checkIcon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Colors.iconTertiary)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .frame(width: 24, height: 24)
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
                        .font(Typography.bodyLgSemibold)
                        .foregroundStyle(Colors.textBrand)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.fillBrandWeak)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .buttonStyle(.plain)

                Button(action: { viewModel.addToCart() }) {
                    Text("\(viewModel.totalPrice.formatted())원 담기")
                        .font(Typography.bodyLgSemibold)
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
    }

    private var snackbar: some View {
        Text(viewModel.snackbarMessage)
            .font(Typography.bodyMdSemibold)
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
}

#Preview {
    MenuOptionsView(
        item: MenuItem(id: "coffee-1", name: "아메리카노", price: 4000, description: "산미가 적고 고소한 원두로 내린 기본 커피예요. 진하게 마시려면 샷을 추가해 보세요.", badge: .popular, isSoldOut: false),
        cart: CartStore(),
        onAddedToCart: {},
        onOrderNow: {}
    )
}
