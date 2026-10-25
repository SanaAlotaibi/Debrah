
import SwiftUI

// MARK: - Models

struct HomeData: Codable {
    let categories: [HomeCategory]
}

struct HomeCategory: Codable, Identifiable {
    let id: String
    let name: String
    let applianceGroups: [ApplianceGroup]
}

struct ApplianceGroup: Codable, Identifiable {
    let id: String
    let name: String
    let appliances: [Appliance]
}

struct Appliance: Codable, Identifiable {
    let id: String
    let name: String
    let problems: [HomeProblem]
}

struct HomeProblem: Codable, Identifiable {
    let id: String
    let title: String
    let questions: [DiagnosisQuestion]
    let solutionSteps: [String]
}

struct DiagnosisQuestion: Codable, Identifiable {
    let id: String
    let text: String
    let expectedAnswer: Bool
}

// MARK: - Loading JSON

func loadHomeData() throws -> HomeData {
    guard let url = Bundle.main.url(
        forResource: "home_problems",
        withExtension: "json"
    ) else {
        throw CocoaError(.fileNoSuchFile)
    }

    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(HomeData.self, from: data)
}

// MARK: - Main Screen

struct ContentView: View {
    @State private var categories: [HomeCategory] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(category.name) {
                        GroupListView(groups: category.applianceGroups)
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("مشاكل المنزل")
            .task {
                do {
                    categories = try loadHomeData().categories
                } catch {
                    errorMessage = "فشل تحميل البيانات: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Appliance Groups

struct GroupListView: View {
    let groups: [ApplianceGroup]

    var body: some View {
        List(groups) { group in
            NavigationLink(group.name) {
                ApplianceListView(appliances: group.appliances)
            }
        }
        .navigationTitle("تصنيفات الأجهزة")
    }
}

// MARK: - Appliances

struct ApplianceListView: View {
    let appliances: [Appliance]

    var body: some View {
        List(appliances) { appliance in
            NavigationLink(appliance.name) {
                ProblemListView(problems: appliance.problems)
            }
        }
        .navigationTitle("الأجهزة")
    }
}

// MARK: - Problems

struct ProblemListView: View {
    let problems: [HomeProblem]

    var body: some View {
        List(problems) { problem in
            NavigationLink(problem.title) {
                ProblemDetailView(problem: problem)
            }
        }
        .navigationTitle("المشاكل")
    }
}

// MARK: - Diagnosis and Solution

struct ProblemDetailView: View {
    let problem: HomeProblem

    @State private var answers: [String: Bool] = [:]

    var isComplete: Bool {
        problem.questions.allSatisfy {
            answers[$0.id] != nil
        }
    }

    var isMatching: Bool {
        problem.questions.allSatisfy {
            answers[$0.id] == $0.expectedAnswer
        }
    }

    var body: some View {
        List {
            Section("التشخيص") {
                ForEach(problem.questions) { question in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(question.text)

                        HStack {
                            Button("نعم") {
                                answers[question.id] = true
                            }
                            .buttonStyle(.borderedProminent)

                            Button("لا") {
                                answers[question.id] = false
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 6)
                }

                if isComplete {
                    Text(isMatching ? "مطابق" : "غير مطابق")
                        .font(.headline)
                }
            }

            Section("الحل") {
                ForEach(
                    Array(problem.solutionSteps.enumerated()),
                    id: \.offset
                ) { index, step in
                    Text("\(index + 1). \(step)")
                }
            }
        }
        .navigationTitle(problem.title)
    }
}

