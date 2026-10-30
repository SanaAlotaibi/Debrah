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
    @State private var showWelcome = true

    var body: some View {
        ZStack {
            NavigationStack(path: $router.path) {
                ServicesView()
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
            .tint(Theme.mintAction)
            .accessibilityHidden(showWelcome)

            if showWelcome {
                WelcomeView {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showWelcome = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .environment(router)
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
