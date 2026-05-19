import SwiftUI

struct FocusView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FocusViewModel
    
    init(task: TaskItem?) {
        _viewModel = StateObject(wrappedValue: FocusViewModel(task: task))
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            DSColor.background.ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [DSColor.accent.opacity(0.15), .clear]),
                center: .init(x: 0.5, y: 0.3),
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                taskInfo
                
                Spacer()
                
                timerRing
                
                Spacer()
                
                controls
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.startTimer()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button {
                if !viewModel.isFinished {
                    viewModel.finish(completed: false)
                }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(DSColor.surfaceElevated))
            }
            
            Spacer()
            
            Text("FOCUS SESSION")
                .font(.system(size: 12, weight: .bold))
                .kerning(1.2)
                .foregroundStyle(DSColor.textSecondary)
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, 20)
    }
    
    // MARK: - Task Info
    
    private var taskInfo: some View {
        VStack(spacing: 8) {
            Text(viewModel.isFinished ? (viewModel.progress >= 1.0 ? "COMPLETE" : "STOPPED") : (viewModel.isRunning ? "IN SESSION" : "PAUSED"))
                .font(.system(size: 12, weight: .bold))
                .kerning(0.6)
                .foregroundStyle(DSColor.accent)
            
            Text(viewModel.task?.title ?? "Deep Work")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
    }
    
    // MARK: - Timer Ring
    
    private var timerRing: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(DSColor.surfaceElevated, lineWidth: 16)
                .frame(width: 280, height: 280)
            
            // Progress Ring
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    LinearGradient(
                        colors: [DSColor.accent, DSColor.accentLight],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: viewModel.elapsedSeconds)
            
            // Time Display
            VStack(spacing: 4) {
                Text(viewModel.formattedRemainingTime)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                
                Text("of \(viewModel.goalSeconds / 60) min")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
    }
    
    // MARK: - Controls
    
    private var controls: some View {
        VStack(spacing: 16) {
            if viewModel.isFinished {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You focused for")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DSColor.textSecondary)
                    
                    Text(viewModel.formattedElapsedTime)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(viewModel.progress >= 1.0 ? "+1 streak day · Saved to analytics" : "Saved · \(Int(viewModel.progress * 100))% of goal")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(viewModel.progress >= 1.0 ? DSColor.success : DSColor.warning)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(DSColor.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(DSColor.hairline, lineWidth: 0.5)
                        )
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            HStack(spacing: 12) {
                if !viewModel.isFinished {
                    Button {
                        DSHaptics.medium()
                        viewModel.toggleTimer()
                    } label: {
                        Text(viewModel.isRunning ? "Pause" : "Resume")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(DSColor.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(DSColor.hairline, lineWidth: 0.5)
                                    )
                            )
                    }
                    
                    Button {
                        DSHaptics.medium()
                        viewModel.finish(completed: false)
                    } label: {
                        Text("End Session")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(DSColor.accent)
                                    .shadow(color: DSColor.accent.opacity(0.3), radius: 10, y: 4)
                            )
                    }
                } else {
                    Button {
                        DSHaptics.medium()
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(DSColor.accent)
                                    .shadow(color: DSColor.accent.opacity(0.3), radius: 10, y: 4)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.bottom, 40)
    }
}
