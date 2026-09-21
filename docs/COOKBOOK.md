# Cookbook

_KitoDevKit · Wycliff · wyksoftsinc.com · 9/21/26_

Full, realistic screens built from several Kito kits at once — the kind of
composition a real app actually needs, not single-component snippets. Each
recipe names which kits it uses and links back to that kit's own README for
the API in isolation.

---

## 1. Sign-up screen

**Kits:** KitoValidation · KitoHaptics · KitoToasts · (your own text fields,
or `KitoFields` if you're using it)

```swift
import SwiftUI
import KitoDevKit

@Observable
final class SignUpViewModel {
    var email = ""
    var password = ""
    var emailError: String?
    var passwordError: String?
    let toasts: KitoToastCenter

    init(toasts: KitoToastCenter) {
        self.toasts = toasts
    }

    func submit() {
        emailError = kitoValidate(email, rules: [.required(), .email()])
        passwordError = kitoValidate(password, rules: [.required(), .minLength(8)])

        guard emailError == nil, passwordError == nil else {
            KitoHaptics.error()
            return
        }

        Task {
            do {
                try await AuthAPI.signUp(email: email, password: password)
                KitoHaptics.success()
                toasts.show("Welcome aboard!", style: .success)
            } catch {
                KitoHaptics.error()
                toasts.show("Couldn't create your account — try again", style: .error)
            }
        }
    }
}

struct SignUpScreen: View {
    @Environment(KitoToastCenter.self) private var toasts
    @State private var viewModel: SignUpViewModel

    init(toasts: KitoToastCenter) {
        _viewModel = State(initialValue: SignUpViewModel(toasts: toasts))
    }

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textInputAutocapitalization(.never)
            if let error = viewModel.emailError {
                Text(error).font(.caption).foregroundStyle(.red)
            }

            SecureField("Password", text: $viewModel.password)
            if let error = viewModel.passwordError {
                Text(error).font(.caption).foregroundStyle(.red)
            }

            let strength = KitoPasswordStrength.evaluate(viewModel.password)
            ProgressView(value: Double(strength.rawValue), total: 4)
            Text(strength.label).font(.caption2).foregroundStyle(.secondary)

            Button("Create account") { viewModel.submit() }
        }
        .padding()
    }
}
```

---

## 2. Checkout with a blocking status dialog and biometric confirmation

**Kits:** KitoBiometrics · KitoModals (`KitoStatusDialog`) · KitoHaptics ·
KitoToasts · KitoNetKit (for testing the failure path in DEBUG)

```swift
import SwiftUI
import KitoDevKit

@Observable
final class CheckoutViewModel {
    var paymentStatus: KitoStatusDialogState?
    let toasts: KitoToastCenter
    private let authenticator = KitoBiometricAuthenticator()

    init(toasts: KitoToastCenter) {
        self.toasts = toasts
    }

    func pay(amount: Decimal) async {
        let result = await authenticator.authenticate(reason: "Confirm your \(amount) payment")
        guard case .success = result else {
            if case .failed(let reason) = result { toasts.show(reason, style: .error) }
            return
        }

        paymentStatus = .pending(message: "Processing payment…")
        do {
            try await PaymentAPI.charge(amount: amount)
            KitoHaptics.success()
            paymentStatus = .success(message: "Payment complete")
        } catch {
            KitoHaptics.error()
            paymentStatus = .failure(message: "Payment failed — no charge was made")
        }
    }
}

struct CheckoutScreen: View {
    @State private var viewModel: CheckoutViewModel

    var body: some View {
        VStack {
            // ... cart summary, card/M-Pesa selection ...
            Button("Pay") { Task { await viewModel.pay(amount: 42.00) } }
        }
        .kitoStatusDialog($viewModel.paymentStatus)
    }
}
```

**Testing the failure path without a flaky real backend** (DEBUG only):

```swift
#if DEBUG
import KitoDevKitDebug

KitoNetKit.setScenario(KitoNetScenario(
    urlPattern: "api/payments/charge",
    condition: .forcedResponse(statusCode: 402, body: Data())
))
#endif
```

---

## 3. Dashboard with charts, loading, and empty states

**Kits:** KitoCharts · KitoLoaders · KitoEmptyStates (`KitoStateView`)

```swift
import SwiftUI
import KitoDevKit

@Observable
final class DashboardViewModel {
    var salesState: KitoLoadState<[ChartDataPoint]> = .idle

    func load() async {
        salesState = .loading
        do {
            let points = try await SalesAPI.recentSales()
            salesState = .loaded(points)
        } catch {
            salesState = .failed(error)
        }
    }
}

struct DashboardScreen: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        KitoStateView(viewModel.salesState, retry: { Task { await viewModel.load() } }) { points in
            ScrollView {
                LineChartView(viewModel: LineChartViewModel(points: points))
                    .frame(height: 220)
                    .padding()

                PieChartView(viewModel: PieChartViewModel(
                    points: points, innerRadiusFraction: 0.6
                ))
                .frame(height: 200)
                .padding()
            }
        }
        .task { await viewModel.load() }
    }
}
```

If `points` comes back empty specifically (not an error), swap in
`KitoEmptyStateView.noData(message: "No sales yet this month.")` inside the
`.loaded` branch instead of an empty chart.

---

## 4. App shell — side menu + tab bar + per-tab navigation stacks

**Kits:** KitoNavigation (all three navigation surfaces at once)

```swift
import SwiftUI
import KitoDevKit

enum HomeRoute: KitoRoute { case productDetails(id: String) }
enum ProfileRoute: KitoRoute { case editProfile, settings }

struct AppShell: View {
    @State private var menu = KitoSideMenuViewModel()
    @State private var tabs = KitoTabBarViewModel(items: [
        KitoTabItem(id: "home", title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
        KitoTabItem(id: "cart", title: "Cart", systemImage: "cart"),
        KitoTabItem(id: "profile", title: "Profile", systemImage: "person"),
    ])
    @State private var homeRouter = KitoRouter<HomeRoute>()
    @State private var profileRouter = KitoRouter<ProfileRoute>()

    var body: some View {
        KitoTabContainerView(viewModel: tabs) { tabID in
            switch tabID {
            case "home":
                KitoRouterView(router: homeRouter, root: { HomeScreen() }) { route in
                    switch route {
                    case .productDetails(let id): ProductDetailsScreen(id: id)
                    }
                }
            case "cart":
                CartScreen()
            case "profile":
                KitoRouterView(router: profileRouter, root: { ProfileScreen() }) { route in
                    switch route {
                    case .editProfile: EditProfileScreen()
                    case .settings: SettingsScreen()
                    }
                }
            default:
                EmptyView()
            }
        }
        .kitoSideMenu(viewModel: menu) {
            VStack(alignment: .leading, spacing: 4) {
                KitoSideMenuRow(systemImage: "house", title: "Home") { tabs.select("home"); menu.close() }
                KitoSideMenuRow(systemImage: "questionmark.circle", title: "Help") { menu.close() }
                KitoSideMenuRow(systemImage: "arrow.right.square", title: "Sign out") {
                    session.signOut()
                    menu.close()
                }
            }
            .padding(.top, 60)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Menu", systemImage: "line.3.horizontal") { menu.toggle() }
            }
        }
    }
}
```

---

## 5. Profile editing — avatar picker + validated fields

**Kits:** KitoMediaPicker · KitoValidation · KitoToasts

```swift
import SwiftUI
import KitoDevKit

@Observable
final class EditProfileViewModel {
    var avatarPicker = KitoMediaPickerViewModel()
    var displayName = ""
    var nameError: String?
    let toasts: KitoToastCenter

    init(toasts: KitoToastCenter) { self.toasts = toasts }

    func save() {
        nameError = kitoValidate(displayName, rules: [.required(), .maxLength(40)])
        guard nameError == nil else { return }
        Task {
            try? await ProfileAPI.update(name: displayName, avatar: avatarPicker.image)
            toasts.show("Profile updated", style: .success)
        }
    }
}

struct EditProfileScreen: View {
    @State private var viewModel: EditProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            KitoAvatarPicker(viewModel: viewModel.avatarPicker, size: 120)
            TextField("Display name", text: $viewModel.displayName)
            if let error = viewModel.nameError {
                Text(error).font(.caption).foregroundStyle(.red)
            }
            Button("Save", action: viewModel.save)
        }
        .padding()
    }
}
```

---

## 6. First launch — onboarding into a permission request

**Kits:** KitoOnboarding · KitoPermissions

```swift
import SwiftUI
import KitoDevKit

struct FirstLaunchFlow: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var showingCameraRationale = false

    var body: some View {
        if !hasOnboarded {
            KitoOnboardingView(viewModel: KitoOnboardingViewModel(
                pages: [
                    KitoOnboardingPage(systemImage: "bolt.fill", title: "Fast", message: "Everything loads instantly."),
                    KitoOnboardingPage(systemImage: "camera.fill", title: "Scan receipts", message: "Snap a photo, we'll do the rest."),
                ],
                onFinish: {
                    hasOnboarded = true
                    showingCameraRationale = true
                }
            ))
            .sheet(isPresented: $showingCameraRationale) {
                KitoPermissionRationaleView(
                    icon: "camera.fill",
                    title: "Scan receipts instantly",
                    message: "We only use your camera to scan receipts.",
                    onContinue: {
                        showingCameraRationale = false
                        Task { _ = await KitoPermissionManager.shared.request(.camera) }
                    },
                    onSkip: { showingCameraRationale = false }
                )
            }
        } else {
            MainAppView()
        }
    }
}
```

---

## Composing your own recipe

Every kit's ViewModel takes its data via `init` and exposes intents as
methods — see `KitoCharts/docs/ARCHITECTURE.md` for the full MVVM contract.
That means composing two kits is almost always "construct both ViewModels in
your screen's own ViewModel, wire one's output to the other's input" — there
is no hidden coupling to work around.
