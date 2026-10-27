//
//  SolutionDoneView.swift
//  Debrah
//
//  صفحة "تم الإصلاح !" (بطاقة + زر العودة).
//  تُستخدم داخل SolutionView بعد آخر خطوة، أو لحالها.
//

import SwiftUI

// MARK: - Theme (خاص بهذا الملف)

private enum DoneTheme {
    static let brown  = Color(red: 0.40, green: 0.29, blue: 0.20)
    static let check  = Color(red: 0.56, green: 0.69, blue: 0.64)
    static let card   = Color(red: 1.0,  green: 0.99, blue: 0.98)
    static let shadow = Color(red: 0.25, green: 0.36, blue: 0.31)
    static let button = Color(red: 0.78, green: 0.85, blue: 0.81)
}

// MARK: - علامة الصح (خط سميك بأطراف دائرية)

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.maxX, y: rect.height * 0.55))
        p.addLine(to: CGPoint(x: rect.width * 0.64, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        return p
    }
}

// MARK: - SolutionDoneView

struct SolutionDoneView: View {

    var lines: [String] = ["لقد انتهيت من خطوات الإصلاح",
                           "تأكد من عمل الإصلاح بشكل جيد"]
    var buttonTitle: String = "العودة إلى قائمة الخدمات"
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            card

            Button(action: onFinish) {
                Text(buttonTitle)
                    .font(.system(size: 18, design: .serif))
                    .foregroundStyle(DoneTheme.brown)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(DoneTheme.button.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 36)
            .padding(.top, 26)
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            Spacer()

            CheckmarkShape()
                .stroke(DoneTheme.check,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .frame(width: 170, height: 160)

            Text("تم الإصلاح !")
                .font(.system(size: 40, design: .serif))
                .foregroundStyle(DoneTheme.brown)
                .padding(.top, 44)

            VStack(spacing: 26) {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .font(.system(size: 17, design: .serif))
                        .foregroundStyle(DoneTheme.brown)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DoneTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: DoneTheme.shadow.opacity(0.3), radius: 8, x: 0, y: 6)
    }
}

// MARK: - Preview (الصفحة كاملة مع العنوان والخلفية)

#Preview {
    NavigationStack {
        VStack(spacing: 0) {
            Text("الحل")
                .font(.system(size: 34, design: .serif))
                .foregroundStyle(Color(red: 0.40, green: 0.29, blue: 0.20))
                .padding(.top, 40)
                .padding(.bottom, 24)

            SolutionDoneView(
                lines: ["لقد انتهيت من خطوات الإصلاح",
                        "تأكد من عمل الدرج بشكل جيد"],
                onFinish: {}
            )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(
            LinearGradient(colors: [.white, .white, Color(red: 0.91, green: 0.97, blue: 0.94)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
    .environment(\.layoutDirection, .rightToLeft)
}
