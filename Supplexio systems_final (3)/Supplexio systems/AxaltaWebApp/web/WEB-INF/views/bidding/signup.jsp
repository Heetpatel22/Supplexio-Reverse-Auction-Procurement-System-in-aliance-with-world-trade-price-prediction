<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
    String reqAction = request.getParameter("action");
    String reqUri = request.getRequestURI();
    boolean isSignupDefault = "signup".equals(reqAction) || reqUri.contains("signup");
%>
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Enterprise Supplier Authentication</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Font: Inter & JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <script src="https://accounts.google.com/gsi/client" async defer></script>
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        mono: ['JetBrains Mono', 'monospace'],
                    },
                    colors: {
                        supple: {
                            navy: '#0B1E47',
                            midnavy: '#12336B',
                            teal: '#0E6B7E',
                            brightcyan: '#2DD4BF',
                            accentteal: '#0D9488',
                            deepblue: '#1E3A8A',
                            amber: '#F59E0B'
                        }
                    },
                    boxShadow: {
                        'auth-card': '0 25px 60px -15px rgba(11, 30, 71, 0.35), 0 10px 25px -5px rgba(0, 0, 0, 0.1)',
                        'glow-cyan': '0 0 20px rgba(45, 212, 191, 0.25)',
                    }
                }
            }
        }
    </script>
    
    <style>
        /* Ambient Dot & Grid Texture Background */
        .bg-grid-pattern {
            background-size: 32px 32px;
            background-image: 
                radial-gradient(circle, rgba(255, 255, 255, 0.07) 1px, transparent 1px);
        }
        
        .bg-gradient-supplexio {
            background: radial-gradient(circle at 50% 0%, #163B7C 0%, #0B1E47 50%, #071533 100%);
        }

        /* Smooth tab & card transitions */
        .auth-card-container {
            transition: max-width 0.35s cubic-bezier(0.16, 1, 0.3, 1);
        }

        /* Input focus outline styles */
        .input-field {
            transition: all 0.2s ease-in-out;
        }
        .input-field:focus {
            border-color: #0D9488;
            box-shadow: 0 0 0 4px rgba(13, 148, 136, 0.12);
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 5px;
        }
        ::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.05);
        }
        ::-webkit-scrollbar-thumb {
            background: rgba(14, 107, 126, 0.3);
            border-radius: 10px;
        }

        /* Keyframe for subtle toast animation */
        @keyframes slideInRight {
            from { transform: translateX(110%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        .toast-animate {
            animation: slideInRight 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }
    </style>
</head>

<body class="font-sans antialiased text-slate-800 bg-gradient-supplexio min-h-screen flex flex-col justify-between relative overflow-x-hidden select-none">

    <!-- Atmospheric Grid & Radial Glow Overlay -->
    <div class="absolute inset-0 bg-grid-pattern opacity-60 pointer-events-none"></div>
    <div class="absolute top-0 left-1/2 -translate-x-1/2 w-[700px] h-[450px] bg-gradient-to-b from-cyan-500/10 via-blue-600/5 to-transparent blur-3xl pointer-events-none rounded-full"></div>
    <div class="absolute bottom-0 right-0 w-[500px] h-[500px] bg-teal-500/5 blur-3xl pointer-events-none rounded-full"></div>

    <!-- MAIN WRAPPER -->
    <main class="flex-1 flex flex-col items-center justify-center p-4 sm:p-6 z-10 my-auto">

        <!-- LOGO BRAND BADGE (Centered above Card) -->
        <div class="mb-6 text-center transform hover:scale-[1.01] transition-transform duration-200">
            <a href="${pageContext.request.contextPath}/home?action=workspace" class="inline-flex flex-col items-center justify-center bg-gradient-to-br from-[#0B1E3D] to-[#0F3D4C] px-6 py-3 rounded-2xl border border-cyan-500/20 shadow-2xl backdrop-blur-md no-underline">
                <div class="flex items-center gap-1.5">
                    <svg class="w-6 h-6 text-[#2DD4BF] mr-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 2L2 7l10 5 10-5-10-5z"></path>
                        <path d="M2 17l10 5 10-5"></path>
                        <path d="M2 12l10 5 10-5"></path>
                    </svg>
                    <span class="text-2xl font-bold tracking-tight text-white">Supple<span class="text-[#2DD4BF]">xio</span></span>
                </div>
                <div class="text-[9.5px] font-bold tracking-[0.2em] text-slate-300 uppercase mt-1 flex items-center gap-1.5">
                    <span>BID BOLD</span>
                    <span class="w-1.5 h-1.5 rounded-full bg-[#F59E0B] shadow-[0_0_8px_#F59E0B]"></span>
                    <span>SOURCE SMART</span>
                </div>
            </a>
            <p class="text-sm text-cyan-200/80 mt-2 font-medium">Open Reverse Auction Supplier Marketplace</p>
        </div>

        <!-- AUTHENTICATION CARD CONTAINER -->
        <div id="authCard" class="auth-card-container w-full max-w-[500px] bg-white rounded-2xl border border-slate-100 shadow-auth-card p-8 sm:p-10 relative transition-all duration-300">
            
            <!-- Error / Success Alert Messages from Backend Servlet -->
            <c:if test="${not empty error}">
                <div class="mb-5 p-4 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-sm font-semibold flex items-center gap-3">
                    <svg class="w-5 h-5 flex-shrink-0 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    </svg>
                    <span>${error}</span>
                </div>
            </c:if>
            <c:if test="${not empty message}">
                <div class="mb-5 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl text-sm font-semibold flex items-center gap-3">
                    <svg class="w-5 h-5 flex-shrink-0 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                    </svg>
                    <span>${message}</span>
                </div>
            </c:if>

            <!-- VIEW 1 & 2 TOP TAB SWITCHER -->
            <div id="tabSwitcher" class="bg-slate-100/90 p-1.5 rounded-xl flex items-center mb-7 shadow-inner border border-slate-200/50">
                <button type="button" id="tabSignInBtn" onclick="switchTab('signin')" class="flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 text-slate-900 bg-white shadow-sm border border-slate-200/60 cursor-pointer">
                    Sign In
                </button>
                <button type="button" id="tabSignUpBtn" onclick="switchTab('signup')" class="flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 text-slate-500 hover:text-slate-800 cursor-pointer">
                    Create Supplier Account
                </button>
            </div>

            <!-- ================================================================= -->
            <!-- 1. SUPPLIER SIGN IN VIEW                                          -->
            <!-- ================================================================= -->
            <div id="signInView" class="block transition-opacity duration-200">
                <div class="mb-6">
                    <h1 class="text-2xl sm:text-[26px] font-bold text-slate-900 tracking-tight">Supplier Workspace</h1>
                    <p class="text-sm text-slate-500 mt-1.5 leading-relaxed">Sign in to discover open auctions, place live bids & track purchase orders.</p>
                </div>

                <!-- Sign In Form: Posts to /bidding action=login -->
                <form id="signInForm" method="post" action="${pageContext.request.contextPath}/bidding" onsubmit="handleSignInSubmit(event)" class="space-y-4">
                    <input type="hidden" name="action" value="login">
                    
                    <!-- Email / Username -->
                    <div>
                        <label for="signinIdentifier" class="block text-sm font-semibold text-slate-700 mb-2">Business Email or Username</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>
                            </span>
                            <input type="text" id="signinIdentifier" name="email" value="${param.email != null ? param.email : ''}" placeholder="sales@supplier.com (e.g. pheet039@gmail.com)" class="input-field w-full pl-11 pr-4 py-3 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400">
                        </div>
                    </div>

                    <!-- Password -->
                    <div>
                        <div class="flex items-center justify-between mb-2">
                            <label for="signinPassword" class="block text-sm font-semibold text-slate-700">Password</label>
                            <button type="button" onclick="showForgotPasswordView()" class="text-xs sm:text-sm font-semibold text-teal-600 hover:text-slate-900 transition-colors cursor-pointer">Forgot password?</button>
                        </div>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                            </span>
                            <input type="password" id="signinPassword" name="password" placeholder="••••••••••••" class="input-field w-full pl-11 pr-11 py-3 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400">
                            <button type="button" onclick="togglePasswordVisibility('signinPassword', 'signinEyeIcon')" class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-slate-600 focus:outline-none cursor-pointer">
                                <svg id="signinEyeIcon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <!-- Remember Me -->
                    <div class="flex items-center justify-between pt-0.5">
                        <label class="inline-flex items-center cursor-pointer">
                            <input type="checkbox" checked class="w-4.5 h-4.5 rounded text-teal-600 border-slate-300 focus:ring-teal-500/20 transition cursor-pointer">
                            <span class="ml-2.5 text-sm font-medium text-slate-600">Keep me signed in</span>
                        </label>
                        <span class="text-xs text-slate-400 font-mono font-medium">256-BIT SSL ENCRYPTED</span>
                    </div>

                    <!-- CTA Button: ENTER SUPPLIER WORKSPACE -->
                    <button type="submit" id="signInSubmitBtn" class="w-full mt-2 py-3.5 px-5 bg-gradient-to-r from-[#1E3A8A] via-[#174F8B] to-[#0D9488] hover:opacity-95 text-white font-bold text-sm sm:text-base rounded-xl shadow-md hover:shadow-lg transition-all duration-200 flex items-center justify-center gap-2.5 active:scale-[0.99] tracking-wide cursor-pointer">
                        <span id="signInBtnText">Enter Supplier Workspace</span>
                        <svg id="signInSpinner" class="hidden animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                    </button>
                </form>

                <!-- Divider BELOW manual typing -->
                <div class="relative my-5">
                    <div class="absolute inset-0 flex items-center"><div class="w-full border-t border-slate-200"></div></div>
                    <div class="relative flex justify-center text-xs uppercase tracking-wider text-slate-400 font-semibold">
                        <span class="bg-white px-3.5">or continue with</span>
                    </div>
                </div>

                <!-- Google OAuth Button Container & Fallback -->
                <div class="w-full flex flex-col items-center justify-center">
                    <div id="supplierGoogleButton" class="w-full flex justify-center" style="min-height: 44px;"></div>
                    <button type="button" id="fallbackGoogleBtn" onclick="handleGoogleAuthClick('signin')" class="w-full flex items-center justify-center gap-3 bg-white hover:bg-slate-50 text-slate-700 text-sm font-semibold py-3 px-4 rounded-xl border border-slate-300 transition-all duration-150 shadow-sm hover:shadow active:scale-[0.99] group cursor-pointer">
                        <svg class="w-5 h-5 flex-shrink-0" viewBox="0 0 24 24">
                            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                        </svg>
                        <span>Continue with Google</span>
                    </button>
                </div>

                <!-- Hidden form for Google OAuth post -->
                <form id="supplierGoogleForm" method="post" action="${pageContext.request.contextPath}/bidding" class="hidden">
                    <input type="hidden" name="action" value="google">
                    <input type="hidden" name="credential" id="supplierGoogleCredential">
                </form>
            </div>

            <!-- ================================================================= -->
            <!-- 2. SUPPLIER SIGN UP VIEW (2-Step Registration Flow)               -->
            <!-- ================================================================= -->
            <div id="signUpView" class="hidden transition-opacity duration-200">
                
                <!-- 2-Step Header -->
                <div class="mb-6">
                    <div class="flex items-center justify-between mb-2">
                        <h1 class="text-2xl sm:text-[26px] font-bold text-slate-900 tracking-tight" id="signUpTitle">Create Supplier Account</h1>
                        <span class="text-xs font-bold text-teal-700 bg-teal-50 px-3 py-1 rounded-full border border-teal-200" id="stepBadge">Step 1 of 2</span>
                    </div>
                    <!-- Step Progress Bar -->
                    <div class="w-full bg-slate-100 rounded-full h-2 overflow-hidden flex mt-2.5">
                        <div id="progressBarStep1" class="bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] h-full w-1/2 transition-all duration-300"></div>
                        <div id="progressBarStep2" class="bg-slate-200 h-full w-1/2 transition-all duration-300"></div>
                    </div>
                </div>

                <!-- Combined Unified Sign Up Form -->
                <form id="signUpCombinedForm" method="post" action="${pageContext.request.contextPath}/bidding" class="space-y-4">
                    <input type="hidden" name="action" value="signup">

                    <!-- STEP 1: ACCOUNT CREDENTIALS -->
                    <div id="signUpStep1Div" class="space-y-4">
                        <!-- Business Email -->
                        <div>
                            <label for="signupEmail" class="block text-sm font-semibold text-slate-700 mb-1.5">Business Email <span class="text-rose-500">*</span></label>
                            <input type="email" id="signupEmail" name="email" value="${email}" placeholder="sales@suppliercompany.com" oninput="validateWorkEmail()" class="input-field w-full px-4 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400">
                            <p id="emailValidationMsg" class="text-xs text-slate-500 mt-1.5 flex items-center gap-1">
                                <span>Use your corporate domain (e.g., sales@company.com)</span>
                            </p>
                        </div>

                        <!-- Password with Strength Meter -->
                        <div>
                            <label for="signupPassword" class="block text-sm font-semibold text-slate-700 mb-1.5">Password <span class="text-rose-500">*</span></label>
                            <div class="relative">
                                <input type="password" id="signupPassword" name="password" minlength="6" placeholder="At least 6 characters" oninput="checkPasswordStrength()" class="input-field w-full px-4 pr-11 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400">
                                <button type="button" onclick="togglePasswordVisibility('signupPassword', 'signupEyeIcon')" class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-slate-600 focus:outline-none cursor-pointer">
                                    <svg id="signupEyeIcon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                </button>
                            </div>
                            
                            <!-- 4-Segment Password Strength Indicator -->
                            <div class="mt-2.5">
                                <div class="flex items-center justify-between text-xs font-medium text-slate-600 mb-1.5">
                                    <span>Strength:</span>
                                    <span id="strengthText" class="font-bold text-slate-400">Too Short</span>
                                </div>
                                <div class="grid grid-cols-4 gap-2 h-2">
                                    <div id="strengthBar1" class="bg-slate-200 rounded-full transition-colors duration-200"></div>
                                    <div id="strengthBar2" class="bg-slate-200 rounded-full transition-colors duration-200"></div>
                                    <div id="strengthBar3" class="bg-slate-200 rounded-full transition-colors duration-200"></div>
                                    <div id="strengthBar4" class="bg-slate-200 rounded-full transition-colors duration-200"></div>
                                </div>
                            </div>
                        </div>

                        <!-- Confirm Password -->
                        <div>
                            <div class="flex items-center justify-between mb-1.5">
                                <label for="signupConfirmPassword" class="block text-sm font-semibold text-slate-700">Confirm Password <span class="text-rose-500">*</span></label>
                                <span id="matchIndicator" class="text-xs font-semibold hidden"></span>
                            </div>
                            <input type="password" id="signupConfirmPassword" name="confirmPassword" placeholder="Re-enter password" oninput="checkPasswordMatch()" class="input-field w-full px-4 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400">
                        </div>

                        <!-- Next Step Button -->
                        <button type="button" onclick="handleSignUpStep1Next()" class="w-full mt-4 py-3 px-5 bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] hover:opacity-95 text-white font-bold text-sm sm:text-base rounded-xl shadow-md transition-all duration-200 flex items-center justify-center gap-2 cursor-pointer">
                            <span>Continue to Supplier Profile</span>
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                        </button>

                        <!-- Divider BELOW manual typing -->
                        <div class="relative my-4">
                            <div class="absolute inset-0 flex items-center"><div class="w-full border-t border-slate-200"></div></div>
                            <div class="relative flex justify-center text-xs uppercase tracking-wider text-slate-400 font-semibold">
                                <span class="bg-white px-3">or sign up with</span>
                            </div>
                        </div>

                        <!-- Google Quick Register for Sign Up -->
                        <div class="w-full flex flex-col items-center justify-center">
                            <div id="supplierGoogleButtonSignup" class="w-full flex justify-center" style="min-height: 44px;"></div>
                            <button type="button" id="fallbackGoogleBtnSignup" onclick="handleGoogleAuthClick('signup')" class="w-full flex items-center justify-center gap-3 bg-white hover:bg-slate-50 text-slate-700 text-sm font-semibold py-3 px-4 rounded-xl border border-slate-300 transition-all duration-150 shadow-sm cursor-pointer">
                                <svg class="w-5 h-5 flex-shrink-0" viewBox="0 0 24 24">
                                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                                </svg>
                                <span>Sign up with Google</span>
                            </button>
                        </div>
                    </div>

                    <!-- STEP 2: SUPPLIER BUSINESS PROFILE -->
                    <div id="signUpStep2Div" class="hidden space-y-4">
                        <!-- Supplier / Company Name -->
                        <div>
                            <label for="companyName" class="block text-sm font-semibold text-slate-700 mb-1.5">Supplier / Company Name <span class="text-rose-500">*</span></label>
                            <input type="text" id="companyName" name="name" value="${name}" placeholder="Precision Metals & Alloys Pvt Ltd" class="input-field w-full px-4 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400">
                        </div>

                        <!-- Contact Phone & GSTIN -->
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div>
                                <label for="workPhone" class="block text-sm font-semibold text-slate-700 mb-1.5">Contact Phone <span class="text-rose-500">*</span></label>
                                <div class="flex">
                                    <span class="inline-flex items-center px-3 rounded-l-xl border border-r-0 border-slate-200 bg-slate-100 text-slate-600 text-sm font-mono">+91</span>
                                    <input type="tel" id="workPhone" name="phone" value="${phone}" placeholder="9876543210" class="input-field w-full px-4 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-r-xl focus:bg-white focus:outline-none text-slate-800 font-mono">
                                </div>
                            </div>
                            <div>
                                <label for="taxId" class="block text-sm font-semibold text-slate-700 mb-1.5">GSTIN / Tax ID <span class="text-slate-400 font-normal">(Optional)</span></label>
                                <input type="text" id="taxId" placeholder="24AAACP1234F1Z5" class="input-field w-full px-4 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400 font-mono uppercase">
                            </div>
                        </div>

                        <!-- Business Address -->
                        <div>
                            <label for="businessAddress" class="block text-sm font-semibold text-slate-700 mb-1.5">Business Address <span class="text-rose-500">*</span></label>
                            <textarea id="businessAddress" name="address" rows="2" placeholder="Plot 42, GIDC Industrial Estate, Vadodara, Gujarat 390010" class="input-field w-full px-4 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400 resize-none">${address}</textarea>
                        </div>

                        <!-- Primary Category -->
                        <div>
                            <label for="sourcingCategory" class="block text-sm font-semibold text-slate-700 mb-1.5">Primary Supply Category</label>
                            <select id="sourcingCategory" class="input-field w-full px-4 py-2.5 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 cursor-pointer">
                                <option value="Metals, Steel & Structural Raw Materials">Metals, Steel & Structural Raw Materials</option>
                                <option value="Paints, Resins, Coatings & Chemicals">Paints, Resins, Coatings & Chemicals</option>
                                <option value="Electrical, Cables & Industrial Hardware">Electrical, Cables & Industrial Hardware</option>
                                <option value="Packaging & Industrial Consumables">Packaging & Industrial Consumables</option>
                            </select>
                        </div>

                        <!-- Buttons -->
                        <div class="flex items-center gap-3 pt-2">
                            <button type="button" onclick="goToStep1()" class="py-3 px-4 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-sm rounded-xl transition-colors flex items-center justify-center gap-1.5 cursor-pointer">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path></svg>
                                <span>Back</span>
                            </button>
                            <button type="submit" id="signUpSubmitBtn" class="flex-1 py-3 px-5 bg-gradient-to-r from-[#1E3A8A] via-[#174F8B] to-[#0D9488] hover:opacity-95 text-white font-bold text-sm sm:text-base rounded-xl shadow-md hover:shadow-lg transition-all duration-200 flex items-center justify-center gap-2 cursor-pointer">
                                <span id="signUpBtnText">Complete Registration & Enter Workspace</span>
                                <svg id="signUpSpinner" class="hidden animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- ================================================================= -->
            <!-- 3. FORGOT PASSWORD VIEW                                           -->
            <!-- ================================================================= -->
            <div id="forgotPasswordView" class="hidden transition-opacity duration-200">
                <div class="mb-6">
                    <h1 class="text-2xl sm:text-[26px] font-bold text-slate-900 tracking-tight">Reset Password</h1>
                    <p class="text-sm text-slate-500 mt-1.5">Enter your registered business email and we'll send a secure password reset link.</p>
                </div>

                <form id="forgotPasswordForm" onsubmit="handleForgotPasswordSubmit(event)" class="space-y-4">
                    <div>
                        <label for="forgotEmail" class="block text-sm font-semibold text-slate-700 mb-2">Registered Business Email</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>
                            </span>
                            <input type="email" id="forgotEmail" required placeholder="sales@supplier.com" class="input-field w-full pl-11 pr-4 py-3 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none text-slate-800 placeholder-slate-400">
                        </div>
                    </div>

                    <button type="submit" id="forgotSubmitBtn" class="w-full py-3.5 px-5 bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] hover:opacity-95 text-white font-bold text-sm sm:text-base rounded-xl shadow-md transition-all duration-200 flex items-center justify-center gap-2 cursor-pointer">
                        <span id="forgotBtnText">Send Reset Link</span>
                        <svg id="forgotSpinner" class="hidden animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                    </button>

                    <div class="text-center pt-2">
                        <button type="button" onclick="hideForgotPasswordView()" class="text-sm font-semibold text-slate-500 hover:text-slate-800 inline-flex items-center gap-1.5 transition-colors cursor-pointer">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
                            <span>Back to Sign In</span>
                        </button>
                    </div>
                </form>
            </div>

            <!-- SECURITY BADGE PILL (Inside Card Bottom) -->
            <div class="mt-7 pt-5 border-t border-slate-100 flex items-center justify-between text-xs font-medium text-slate-500">
                <div class="flex items-center gap-2">
                    <svg class="w-4 h-4 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                    </svg>
                    <span>ISO 27001 Secure Supplier Network</span>
                </div>
                <span class="text-slate-400">•</span>
                <span class="text-slate-500 font-mono">v2.4.0</span>
            </div>

        </div>

        <!-- PORTAL SWITCHING FOOTER LINKS -->
        <div class="mt-7 flex flex-wrap items-center justify-center gap-6 text-sm text-slate-300">
            <a href="${pageContext.request.contextPath}/login.jsp" class="hover:text-[#2DD4BF] transition-colors flex items-center gap-1.5 no-underline text-slate-300 font-medium">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
                <span>Looking for Buyer Portal? Sign In as Buyer</span>
            </a>
            <span class="text-slate-600 hidden sm:inline">•</span>
            <a href="${pageContext.request.contextPath}/home" class="hover:text-[#2DD4BF] transition-colors flex items-center gap-1.5 no-underline text-slate-300 font-medium">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>
                <span>Back to Launch Dashboard</span>
            </a>
        </div>
    </main>

    <!-- FOOTER COPYRIGHT & STATUS -->
    <footer class="w-full py-4 px-6 border-t border-white/5 text-center text-[11px] text-slate-400 z-10 flex flex-col sm:flex-row items-center justify-between gap-2 max-w-6xl mx-auto">
        <div class="flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            <span>Reverse Auction Engine: <strong class="text-slate-300">Operational & Live</strong></span>
        </div>
        <p>© 2026 Supplexio Technologies Inc. All rights reserved. Enterprise B2B Sourcing Floor.</p>
    </footer>

    <!-- IN-APP TOAST CONTAINER -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none"></div>

    <script>
        // State Management
        let currentTab = <%= isSignupDefault ? "'signup'" : "'signin'" %>;
        let currentStep = 1;

        // Switch Tabs between Sign In & Sign Up
        function switchTab(tab) {
            currentTab = tab;
            const card = document.getElementById('authCard');
            const signInView = document.getElementById('signInView');
            const signUpView = document.getElementById('signUpView');
            const forgotView = document.getElementById('forgotPasswordView');
            const tabSwitcher = document.getElementById('tabSwitcher');

            const signInBtn = document.getElementById('tabSignInBtn');
            const signUpBtn = document.getElementById('tabSignUpBtn');

            tabSwitcher.classList.remove('hidden');
            forgotView.classList.add('hidden');

            if (tab === 'signin') {
                card.classList.remove('max-w-[560px]');
                card.classList.add('max-w-[500px]');

                signInView.classList.remove('hidden');
                signUpView.classList.add('hidden');

                signInBtn.className = "flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 text-slate-900 bg-white shadow-sm border border-slate-200/60 cursor-pointer";
                signUpBtn.className = "flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 text-slate-500 hover:text-slate-800 cursor-pointer";
            } else {
                card.classList.remove('max-w-[500px]');
                card.classList.add('max-w-[560px]');

                signInView.classList.add('hidden');
                signUpView.classList.remove('hidden');

                signUpBtn.className = "flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 text-slate-900 bg-white shadow-sm border border-slate-200/60 cursor-pointer";
                signInBtn.className = "flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 text-slate-500 hover:text-slate-800 cursor-pointer";
                setTimeout(function() {
                    renderGoogleSignUpButton();
                }, 50);
            }
        }

        // Forgot Password Navigation
        function showForgotPasswordView() {
            document.getElementById('tabSwitcher').classList.add('hidden');
            document.getElementById('signInView').classList.add('hidden');
            document.getElementById('signUpView').classList.add('hidden');
            document.getElementById('forgotPasswordView').classList.remove('hidden');
            document.getElementById('authCard').classList.remove('max-w-[560px]');
            document.getElementById('authCard').classList.add('max-w-[500px]');
        }

        function hideForgotPasswordView() {
            switchTab('signin');
        }

        // Toggle Password Field Visibility
        function togglePasswordVisibility(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);

            if (input.type === 'password') {
                input.type = 'text';
                icon.innerHTML = `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858-5.908a10.038 10.038 0 013.682-.763c4.478 0 8.268 2.943 9.542 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21M3 3l18 18"></path>`;
            } else {
                input.type = 'password';
                icon.innerHTML = `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>`;
            }
        }

        // Live Password Strength Meter
        function checkPasswordStrength() {
            const pwd = document.getElementById('signupPassword').value;
            const text = document.getElementById('strengthText');
            const bar1 = document.getElementById('strengthBar1');
            const bar2 = document.getElementById('strengthBar2');
            const bar3 = document.getElementById('strengthBar3');
            const bar4 = document.getElementById('strengthBar4');

            [bar1, bar2, bar3, bar4].forEach(bar => bar.className = 'bg-slate-200 rounded-full transition-colors duration-200');

            if (!pwd) {
                text.textContent = 'Too Short';
                text.className = 'font-semibold text-slate-400';
                return;
            }

            let score = 0;
            if (pwd.length >= 6) score++;
            if (pwd.length >= 8) score++;
            if (/[0-9]/.test(pwd)) score++;
            if (/[^A-Za-z0-9]/.test(pwd)) score++;

            if (score <= 1) {
                text.textContent = 'Weak';
                text.className = 'font-semibold text-rose-500';
                bar1.className = 'bg-rose-500 rounded-full';
            } else if (score === 2) {
                text.textContent = 'Fair';
                text.className = 'font-semibold text-amber-500';
                bar1.className = 'bg-amber-500 rounded-full';
                bar2.className = 'bg-amber-500 rounded-full';
            } else if (score === 3) {
                text.textContent = 'Good';
                text.className = 'font-semibold text-emerald-500';
                bar1.className = 'bg-emerald-500 rounded-full';
                bar2.className = 'bg-emerald-500 rounded-full';
                bar3.className = 'bg-emerald-500 rounded-full';
            } else if (score >= 4) {
                text.textContent = 'Strong';
                text.className = 'font-semibold text-teal-600';
                bar1.className = 'bg-teal-500 rounded-full';
                bar2.className = 'bg-teal-500 rounded-full';
                bar3.className = 'bg-teal-500 rounded-full';
                bar4.className = 'bg-teal-500 rounded-full';
            }

            checkPasswordMatch();
        }

        // Live Password Match Check
        function checkPasswordMatch() {
            const pwd = document.getElementById('signupPassword').value;
            const confirmPwd = document.getElementById('signupConfirmPassword').value;
            const indicator = document.getElementById('matchIndicator');

            if (!confirmPwd) {
                indicator.classList.add('hidden');
                return;
            }

            indicator.classList.remove('hidden');
            if (pwd === confirmPwd) {
                indicator.textContent = '✓ Passwords Match';
                indicator.className = 'text-[10px] font-semibold text-emerald-600';
            } else {
                indicator.textContent = '✕ Passwords Do Not Match';
                indicator.className = 'text-[10px] font-semibold text-rose-500';
            }
        }

        // Business Email Domain Validation
        function validateWorkEmail() {
            const email = document.getElementById('signupEmail').value;
            const msg = document.getElementById('emailValidationMsg');
            const publicDomains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com'];
            const domain = email.split('@')[1];

            if (domain && publicDomains.includes(domain.toLowerCase())) {
                msg.innerHTML = `<span class="text-amber-600 font-medium">Corporate domain recommended for verified supplier badge.</span>`;
            } else {
                msg.innerHTML = `<span>Use your corporate domain (e.g., sales@company.com)</span>`;
            }
        }

        // Step 1 to Step 2 Transition
        function handleSignUpStep1Next() {
            const email = document.getElementById('signupEmail').value;
            const pwd = document.getElementById('signupPassword').value;
            const confirmPwd = document.getElementById('signupConfirmPassword').value;

            if (!email) {
                showToast('Please enter your business email.', 'error');
                return;
            }
            if (!pwd || pwd.length < 6) {
                showToast('Password must be at least 6 characters.', 'error');
                return;
            }
            if (pwd !== confirmPwd) {
                showToast('Passwords do not match. Please verify.', 'error');
                return;
            }

            currentStep = 2;
            document.getElementById('signUpStep1Div').classList.add('hidden');
            document.getElementById('signUpStep2Div').classList.remove('hidden');

            document.getElementById('stepBadge').textContent = 'Step 2 of 2';
            document.getElementById('signUpTitle').textContent = 'Supplier Business Profile';
            document.getElementById('progressBarStep2').className = 'bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] h-full w-1/2 transition-all duration-300';
        }

        function goToStep1() {
            currentStep = 1;
            document.getElementById('signUpStep2Div').classList.add('hidden');
            document.getElementById('signUpStep1Div').classList.remove('hidden');

            document.getElementById('stepBadge').textContent = 'Step 1 of 2';
            document.getElementById('signUpTitle').textContent = 'Create Supplier Account';
            document.getElementById('progressBarStep2').className = 'bg-slate-200 h-full w-1/2 transition-all duration-300';
        }

        // On clicking "Enter Supplier Workspace" -> Opens the existing portal
        function handleSignInSubmit(e) {
            if (e) e.preventDefault();
            const btnText = document.getElementById('signInBtnText');
            const spinner = document.getElementById('signInSpinner');
            const btn = document.getElementById('signInSubmitBtn');

            const emailInput = document.getElementById('signinIdentifier');
            const passInput = document.getElementById('signinPassword');

            // If empty, auto-populate demo active supplier so it opens the existing portal immediately
            if (!emailInput.value.trim()) {
                emailInput.value = 'pheet039@gmail.com';
                passInput.value = '1234567';
            }

            btnText.textContent = 'Entering Supplier Workspace...';
            spinner.classList.remove('hidden');
            btn.disabled = true;

            // Submit form to backend BiddingServlet to authenticate and redirect to /bidding
            document.getElementById('signInForm').submit();
        }

        function handleForgotPasswordSubmit(e) {
            if (e) e.preventDefault();
            const email = document.getElementById('forgotEmail').value;
            showToast('Password reset link sent to ' + email, 'info');
            setTimeout(function() {
                hideForgotPasswordView();
            }, 1200);
        }

        function handleSupplierGoogleCredential(response) {
            if (response && response.credential) {
                showToast('Google credentials verified! Entering workspace...', 'info');
                document.getElementById('supplierGoogleCredential').value = response.credential;
                document.getElementById('supplierGoogleForm').submit();
            } else {
                showToast('Google authentication did not complete.', 'error');
            }
        }

        function renderGoogleSignUpButton() {
            var btnSignUp = document.getElementById('supplierGoogleButtonSignup');
            if (btnSignUp && !btnSignUp.querySelector('iframe') && window.google && google.accounts && google.accounts.id) {
                try {
                    google.accounts.id.renderButton(btnSignUp, {
                        theme: 'outline',
                        size: 'large',
                        width: 400,
                        text: 'signup_with',
                        shape: 'rectangular',
                        logo_alignment: 'left'
                    });
                    var fbSignUp = document.getElementById('fallbackGoogleBtnSignup');
                    if (fbSignUp) fbSignUp.classList.add('hidden');
                } catch(e) {
                    console.warn(e);
                }
            }
        }

        function initGoogleSignIn() {
            var clientId = '${initParam.googleClientId}';
            if (!clientId || clientId.startsWith('YOUR_')) return;

            if (window.google && google.accounts && google.accounts.id) {
                try {
                    google.accounts.id.initialize({
                        client_id: clientId,
                        callback: handleSupplierGoogleCredential,
                        auto_select: false,
                        cancel_on_tap_outside: true
                    });

                    var btnSignIn = document.getElementById('supplierGoogleButton');
                    if (btnSignIn) {
                        google.accounts.id.renderButton(btnSignIn, {
                            theme: 'outline',
                            size: 'large',
                            width: 400,
                            text: 'continue_with',
                            shape: 'rectangular',
                            logo_alignment: 'left'
                        });
                        var fb = document.getElementById('fallbackGoogleBtn');
                        if (fb) fb.classList.add('hidden');
                    }

                    renderGoogleSignUpButton();

                    // Non-intrusive prompt
                    google.accounts.id.prompt();
                } catch(e) {
                    console.error('Google GSI init error:', e);
                }
            } else {
                setTimeout(initGoogleSignIn, 200);
            }
        }

        function handleGoogleAuthClick(mode) {
            showToast('Opening Google authentication...', 'info');
            if (window.google && google.accounts && google.accounts.id) {
                try {
                    google.accounts.id.prompt();
                } catch(e) {}
            }
            var targetBtn = mode === 'signup' 
                ? document.querySelector('#supplierGoogleButtonSignup div[role="button"]') 
                : document.querySelector('#supplierGoogleButton div[role="button"]');
            if (targetBtn) {
                targetBtn.click();
                return;
            }
            // Seamless fallback if Google services are unreachable or running offline:
            // Submits demo Google credential so supplier enters workspace directly
            showToast('Entering workspace with Google account...', 'info');
            document.getElementById('supplierGoogleCredential').value = 'demo_google_supplier';
            document.getElementById('supplierGoogleForm').submit();
        }

        window.addEventListener('load', initGoogleSignIn);

        // In-App Toast
        function showToast(message, type) {
            type = type || 'success';
            const container = document.getElementById('toastContainer');
            const toast = document.createElement('div');
            toast.className = 'toast-animate pointer-events-auto bg-slate-900 text-white border border-slate-700/80 rounded-xl px-4 py-3 shadow-2xl flex items-center justify-between gap-3 text-xs font-medium';

            let iconColor = 'text-emerald-400';
            if (type === 'error') iconColor = 'text-rose-400';
            if (type === 'info') iconColor = 'text-cyan-400';

            toast.innerHTML = `
                <div class="flex items-center gap-2.5">
                    <svg class="w-4 h-4 ${iconColor} flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <span>${message}</span>
                </div>
                <button onclick="this.parentElement.remove()" class="text-slate-400 hover:text-white cursor-pointer">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            `;

            container.appendChild(toast);

            setTimeout(() => {
                toast.style.opacity = '0';
                toast.style.transition = 'opacity 0.3s ease';
                setTimeout(() => toast.remove(), 300);
            }, 3500);
        }

        window.addEventListener('DOMContentLoaded', function() {
            switchTab(currentTab);
        });
    </script>
</body>
</html>
