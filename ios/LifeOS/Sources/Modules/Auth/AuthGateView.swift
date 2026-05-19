import SwiftUI
import AuthenticationServices

struct AuthGateView: View {
    @State private var authService = AuthService.shared
    @State private var mode: AuthMode = .welcome
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var currentNonce = ""
    
    enum AuthMode {
        case welcome, login, signup
    }
    
    var body: some View {
        ZStack {
            // Background
            DSColor.background.ignoresSafeArea()
            
            // Subtle gradient orbs
            Circle()
                .fill(DSColor.accent.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: -200)
            
            Circle()
                .fill(DSColor.cyan.opacity(0.06))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 100, y: 200)
            
            VStack(spacing: 0) {
                switch mode {
                case .welcome:
                    welcomeContent
                case .login:
                    loginContent
                case .signup:
                    signupContent
                }
            }
            .animation(DSAnimation.springMedium, value: mode)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Welcome
    
    private var welcomeContent: some View {
        VStack(spacing: DSSpacing.xxl) {
            Spacer()
            
            // Logo & branding
            VStack(spacing: DSSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(DSGradient.accent)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                .glowShadow(DSColor.accent)
                
                VStack(spacing: DSSpacing.xs) {
                    Text("LifeOS")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Your life, organized.")
                        .font(DSFont.subheadline())
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            
            Spacer()
            
            // Feature highlights
            VStack(spacing: DSSpacing.sm) {
                featureRow(icon: "checkmark.circle.fill", text: "Tasks & Projects", color: DSColor.accent)
                featureRow(icon: "calendar", text: "Time Blocking", color: DSColor.cyan)
                featureRow(icon: "chart.pie.fill", text: "Finance Tracking", color: DSColor.success)
                featureRow(icon: "book.fill", text: "Knowledge Capture", color: DSColor.warning)
            }
            .padding(.horizontal, DSSpacing.xxl)
            
            Spacer()
            
            // Auth buttons
            VStack(spacing: DSSpacing.sm) {
                // Sign in with Apple
                SignInWithAppleButton(.signIn) { request in
                    currentNonce = randomNonceString()
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(currentNonce)
                } onCompletion: { result in
                    Task {
                        await authService.handleAppleSignIn(result, nonce: currentNonce)
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .cornerRadius(DSRadius.pill)
                
                // Sign in with Google
                Button {
                    Task { await authService.signInWithGoogle() }
                } label: {
                    HStack(spacing: DSSpacing.sm) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 20))
                        Text("Continue with Google")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.pill)
                            .fill(Color(red: 0.26, green: 0.52, blue: 0.96))
                    )
                }
                
                DSButton("Continue with Email", icon: DSIcon.email, style: .secondary, isFullWidth: true) {
                    withAnimation(DSAnimation.springMedium) { mode = .login }
                }
                
                Button {
                    withAnimation(DSAnimation.springMedium) { mode = .signup }
                } label: {
                    Text("Create an account")
                        .font(DSFont.subheadline())
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.top, DSSpacing.xs)
            }
            .padding(.horizontal, DSSpacing.xl)
            .padding(.bottom, DSSpacing.xxl)
        }
    }
    
    // MARK: - Login
    
    private var loginContent: some View {
        VStack(spacing: DSSpacing.xl) {
            // Header
            HStack {
                Button {
                    withAnimation(DSAnimation.springMedium) { mode = .welcome }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DSColor.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, DSSpacing.xl)
            .padding(.top, DSSpacing.lg)
            
            Spacer()
            
            VStack(spacing: DSSpacing.lg) {
                VStack(spacing: DSSpacing.xs) {
                    Text("Welcome back")
                        .font(DSFont.largeTitle())
                        .foregroundStyle(.white)
                    Text("Sign in to your account")
                        .font(DSFont.subheadline())
                        .foregroundStyle(DSColor.textSecondary)
                }
                
                VStack(spacing: DSSpacing.md) {
                    DSTextField(placeholder: "Email", text: $email, icon: DSIcon.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    DSTextField(placeholder: "Password", text: $password, icon: DSIcon.lock, isSecure: true)
                        .textContentType(.password)
                }
                .padding(.horizontal, DSSpacing.xl)
                
                if let error = authService.errorMessage {
                    Text(error)
                        .font(DSFont.caption())
                        .foregroundStyle(DSColor.error)
                        .padding(.horizontal, DSSpacing.xl)
                }
                
                VStack(spacing: DSSpacing.sm) {
                    DSButton("Sign In", style: .primary, isLoading: authService.isLoading, isFullWidth: true) {
                        Task { await authService.signInWithEmail(email, password: password) }
                    }
                    .padding(.horizontal, DSSpacing.xl)
                    
                    Button {
                        Task { await authService.sendPasswordReset(email: email) }
                    } label: {
                        Text("Forgot password?")
                            .font(DSFont.caption())
                            .foregroundStyle(DSColor.accent)
                    }
                }
            }
            
            Spacer()
            
            Button {
                withAnimation(DSAnimation.springMedium) { mode = .signup }
            } label: {
                HStack(spacing: DSSpacing.xxs) {
                    Text("Don't have an account?")
                        .foregroundStyle(DSColor.textTertiary)
                    Text("Sign Up")
                        .foregroundStyle(DSColor.accent)
                }
                .font(DSFont.subheadline())
            }
            .padding(.bottom, DSSpacing.xxl)
        }
    }
    
    // MARK: - Sign Up
    
    private var signupContent: some View {
        VStack(spacing: DSSpacing.xl) {
            HStack {
                Button {
                    withAnimation(DSAnimation.springMedium) { mode = .welcome }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DSColor.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, DSSpacing.xl)
            .padding(.top, DSSpacing.lg)
            
            Spacer()
            
            VStack(spacing: DSSpacing.lg) {
                VStack(spacing: DSSpacing.xs) {
                    Text("Create account")
                        .font(DSFont.largeTitle())
                        .foregroundStyle(.white)
                    Text("Get started with LifeOS")
                        .font(DSFont.subheadline())
                        .foregroundStyle(DSColor.textSecondary)
                }
                
                VStack(spacing: DSSpacing.md) {
                    DSTextField(placeholder: "Full Name", text: $displayName, icon: DSIcon.person)
                        .textContentType(.name)
                    
                    DSTextField(placeholder: "Email", text: $email, icon: DSIcon.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    DSTextField(placeholder: "Password", text: $password, icon: DSIcon.lock, isSecure: true)
                        .textContentType(.newPassword)
                }
                .padding(.horizontal, DSSpacing.xl)
                
                if let error = authService.errorMessage {
                    Text(error)
                        .font(DSFont.caption())
                        .foregroundStyle(DSColor.error)
                        .padding(.horizontal, DSSpacing.xl)
                }
                
                DSButton("Create Account", style: .primary, isLoading: authService.isLoading, isFullWidth: true) {
                    Task { await authService.signUpWithEmail(email, password: password, displayName: displayName) }
                }
                .padding(.horizontal, DSSpacing.xl)
            }
            
            Spacer()
            
            Button {
                withAnimation(DSAnimation.springMedium) { mode = .login }
            } label: {
                HStack(spacing: DSSpacing.xxs) {
                    Text("Already have an account?")
                        .foregroundStyle(DSColor.textTertiary)
                    Text("Sign In")
                        .foregroundStyle(DSColor.accent)
                }
                .font(DSFont.subheadline())
            }
            .padding(.bottom, DSSpacing.xxl)
        }
    }
    
    // MARK: - Helpers
    
    private func featureRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 32)
            
            Text(text)
                .font(DSFont.body())
                .foregroundStyle(DSColor.textSecondary)
            
            Spacer()
        }
    }
}
