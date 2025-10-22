import SwiftUI

// MARK: - MBTI Quiz View
struct MBTIQuizView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel: MBTIQuizViewModel
    let onSubmit: (([String:Int]) -> Void)?

    @Namespace private var listNS
    @State private var scrollProxy: ScrollViewProxy?
    @State private var highlightIndex: Int? = nil
    
    init(provider: MBTIQuestionsProvider = MBTIDefaultQuestionsProvider(), onSubmit: (([String:Int]) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: MBTIQuizViewModel(provider: provider))
        self.onSubmit = onSubmit
    }

    private var answeredCount: Int { viewModel.answers.count }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.1)
            content
            footer
        }
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("PERSONALITY TEST")
                    .font(.custom("Tanker-Regular", size: 20))
                    .foregroundStyle(Color.nudgeGreen900)
                Spacer()
                Text("Page \\(viewModel.pageIndex + 1) of \\(viewModel.totalPages)")
                    .font(.footnote)
                    .foregroundStyle(Color.nudgeGreen900.opacity(0.7))
            }
            .padding(.horizontal, 16)

            // Web-like capsule progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.nudgeGreen900.opacity(0.15))
                    Capsule().fill(Color.nudgeGreen900)
                        .frame(width: max(0, min(1, viewModel.progressFraction)) * geo.size.width)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 16)

            HStack {
                Text("\(answeredCount)/\(viewModel.questions.count) answered")
                    .font(.caption)
                    .foregroundStyle(Color.nudgeGreen900.opacity(0.8))
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.95))
    }

    private var content: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading questions…").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let err = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(err).multilineTextAlignment(.center)
                    Button("Retry") { Task { await viewModel.load() } }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(viewModel.currentRange), id: \.self) { idx in
                                MBTIQuestionRow(
                                    index: idx,
                                    total: viewModel.questions.count,
                                    question: viewModel.questions[idx].question,
                                    selected: viewModel.answers[idx] ?? 0,
                                    highlight: highlightIndex == idx,
                                    onSelect: { value in
                                        viewModel.setAnswer(for: idx, value: value)
                                        #if canImport(UIKit)
                                        if appSettings.hapticFeedbackEnabled {
                                            HapticsService.shared.impact(.soft)
                                        }
                                        #endif
                                        // Auto-scroll to next in page if available
                                        let next = idx + 1
                                        if viewModel.currentRange.contains(next) {
                                            withAnimation(.easeInOut) {
                                                proxy.scrollTo("q_\\(next)", anchor: .center)
                                            }
                                        }
                                    }
                                )
                                .id("q_\\(idx)")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .onAppear { scrollProxy = proxy }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea(edges: .bottom))
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.goBack() }) {
                Label("Back", systemImage: "chevron.left")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.pageIndex == 0)

            Spacer()

            if viewModel.pageIndex + 1 < viewModel.totalPages {
                Button(action: onNextPage) {
                    Label("Next", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(action: onSubmitTapped) {
                    Text("Submit")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.findFirstUnansweredGlobal() != nil)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func onNextPage() {
        if let missing = viewModel.validateCurrentPage() {
            #if canImport(UIKit)
            if appSettings.hapticFeedbackEnabled {
                HapticsService.shared.impact(.rigid)
            }
            #endif
            withAnimation(.easeInOut) {
                highlightIndex = missing
                scrollProxy?.scrollTo("q_\\(missing)", anchor: .center)
            }
            // Clear highlight after pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut) { highlightIndex = nil }
            }
            return
        }
        viewModel.goNext()
        #if canImport(UIKit)
        if appSettings.hapticFeedbackEnabled {
            HapticsService.shared.impact(.soft)
        }
        #endif
        // Reset scroll to top of page
    }

    private func onSubmitTapped() {
        if let missing = viewModel.findFirstUnansweredGlobal() {
#if canImport(UIKit)
            if appSettings.hapticFeedbackEnabled {
                HapticsService.shared.impact(.rigid)
            }
            #endif
            // Jump to that page
            withAnimation(.easeInOut) {
                viewModel.pageIndex = missing / viewModel.pageSize
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut) {
                    scrollProxy?.scrollTo("q_\(missing)", anchor: .center)
                }
            }
            return
        }
        let payload = viewModel.buildSubmissionPayload()
        onSubmit?(payload)
    }
}

// MARK: - Row
private struct MBTIQuestionRow: View {
    let index: Int
    let total: Int
    let question: String
    let selected: Int // 0 (none) or 1..5
    let highlight: Bool
    let onSelect: (Int) -> Void

    @State private var pulse: Bool = false

    private let labels: [Int:String] = [
        1: "Strongly Disagree",
        2: "Disagree",
        3: "Neutral",
        4: "Agree",
        5: "Strongly Agree"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.custom("Tanker-Regular", size: 18))
                .foregroundStyle(Color.nudgeGreen900)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { value in
                    Button(action: { onSelect(value) }) {
                        VStack(spacing: 6) {
                            Text("\(value)")
                                .font(.subheadline.weight(.semibold))
                            Text(labels[value] ?? "")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(NavPillStyle(variant: (value == selected) ? .primary : .outline, compact: false))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text("Question \(index+1) of \(total)"))
                    .accessibilityHint(Text(labels[value] ?? ""))
                }
            }
        }
        .padding(14)
        .retroConsoleSurface()
        .scaleEffect((highlight || pulse) ? 1.015 : 1.0)
        .onChange(of: highlight) { _, newVal in
            if newVal { pulseOnce() }
        }
        .onAppear {
            if highlight { pulseOnce() }
        }
    }

    private func pulseOnce() {
        withAnimation(.easeInOut(duration: 0.15)) { pulse = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeInOut(duration: 0.15)) { pulse = false }
        }
    }
}

#Preview {
    MBTIQuizView { payload in
        print(payload)
    }
    .environmentObject(AppSettings())
}

