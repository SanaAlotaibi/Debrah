import SwiftUI

// MARK: - Welcome Screen

/// الشاشة الترحيبية: لوقو التطبيق واسمه فوق خلفية متدرجة ناعمة.
///
/// تبقى 5 ثوانٍ ثم تستدعي `onFinish`. يمكن تخطيها باللمس.
struct WelcomeView: View {

    /// يُستدعى مرة واحدة عند انتهاء المدة أو عند اللمس.
    let onFinish: () -> Void

    /// مدة الظهور بالثواني.
    private let duration: Double = 3

    @State private var appeared = false
    @State private var breathing = false
    @State private var didFinish = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var logoSize: CGFloat = 64

    var body: some View {
        ZStack {
            WelcomeBackground()

            VStack(spacing: Theme.Spacing.lg) {
                logo

                VStack(spacing: Theme.Spacing.xs) {
                    Text("دبره")
                        .themed(46, relativeTo: .largeTitle)
                        .foregroundStyle(Theme.brown)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.9).delay(0.35), value: appeared)

                    Text("دليلك للعناية بمنزلك")
                        .typography(.body)
                        .foregroundStyle(Theme.brown.opacity(0.8))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.9).delay(0.7), value: appeared)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .accessibilityElement(children: .combine)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: finish)
        .task {
            appeared = true
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            finish()
        }
    }

    // MARK: Logo

    private var logo: some View {
        Image(systemName: "house")
            .font(.system(size: logoSize, weight: .regular))
            .foregroundStyle(Theme.mintAction)
            .frame(width: logoSize * 2.1, height: logoSize * 2.1)
            .background(
                Circle()
                    .fill(.white.opacity(0.6))
                    .shadow(color: Theme.mintAction.opacity(0.25), radius: 24, x: 0, y: 10)
            )
            .scaleEffect(appeared ? (breathing ? 1.04 : 1) : 0.8)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.9, dampingFraction: 0.75), value: appeared)
            .accessibilityHidden(true)
    }

    // MARK: Actions

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }
}

// MARK: - Background

/// خلفية من بقع ألوان ضبابية تتحرك ببطء.
private struct WelcomeBackground: View {

    @State private var drift = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let base = Color(hex: 0xF6FBF7)
    private let lime = Color(hex: 0xD6EDAA)
    private let teal = Color(hex: 0x9AD3CB)
    private let mint = Color(hex: 0xCFF0E3)
    private let butter = Color(hex: 0xF3F6C8)

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let shift: CGFloat = drift ? 1 : -1

            ZStack {
                base

                blob(lime, size: w * 0.9)
                    .offset(x: -w * 0.30 + shift * 20, y: -h * 0.28 + shift * 14)

                blob(teal, size: w * 0.8)
                    .offset(x: w * 0.38 - shift * 16, y: -h * 0.10 + shift * 22)

                blob(mint, size: w * 0.85)
                    .offset(x: -w * 0.32 + shift * 14, y: h * 0.22 - shift * 18)

                blob(butter, size: w * 0.9)
                    .offset(x: w * 0.25 - shift * 20, y: h * 0.38 + shift * 12)
            }
            .frame(width: w, height: h)
            .clipped()
        }
        .ignoresSafeArea()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
        .accessibilityHidden(true)
    }

    private func blob(_ color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 70)
    }
}

// MARK: - Preview

#Preview("Welcome") {
    WelcomeView(onFinish: {})
        .appPreviewEnvironment()
}


/*
import SwiftUI
import Observation

// MARK: - App

@main
struct DebrahApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Navigation

/// كل شاشة يمكن الانتقال إليها، معرّفة بالمعرّف فقط.
enum Route: Hashable {

    /// قائمة داخل خدمة أو قسم (مثل: مشاكل المياه، الأجهزة المنزلية، الثلاجات).
    case category(categoryID: String)

    /// شاشة مقدمة المشكلة.
    case intro(problemID: String)

    /// بطاقات أسئلة التشخيص.
    case diagnosis(problemID: String)

    /// خطوات الحل.
    case solution(problemID: String)
}

/// يحتفظ بمسار التنقل، فتستطيع أي شاشة الانتقال إلى أي شاشة أخرى.
@Observable
final class Router {
    var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    /// يستبدل الشاشة الحالية، فلا يعود زر الرجوع إليها (مثل: التشخيص بعد انتهائه).
    func replaceCurrent(with route: Route) {
        if !path.isEmpty { path.removeLast() }
        path.append(route)
    }

    /// العودة إلى قائمة الخدمات.
    func popToRoot() {
        path.removeAll()
    }
}

// MARK: - Root

/// الجذر الوحيد للتنقل في التطبيق. لا توجد أي `NavigationStack` أخرى.
struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            ServicesView()
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
        }
        .environment(router)
        .tint(Theme.mintAction)
        // The whole app is Arabic / right-to-left.
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .category(let id):
            if let category = DiagnosisData.category(id: id) {
                ProblemListView(category: category)
            }
        case .intro(let id):
            if let problem = DiagnosisData.problem(id: id) {
                DiagnosisIntroductionView(problem: problem)
            }
        case .diagnosis(let id):
            if let problem = DiagnosisData.problem(id: id) {
                DiagnosisFlowView(problem: problem)
            }
        case .solution(let id):
            if let problem = DiagnosisData.problem(id: id) {
                SolutionView(problem: problem)
            }
        }
    }
}

#Preview {
    ContentView()
}
*/
