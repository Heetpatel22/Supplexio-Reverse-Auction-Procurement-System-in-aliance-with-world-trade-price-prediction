<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio | Procurement Launch Dashboard</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/launch.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
</head>
<body class="launch-page">
    <header class="launch-hero">
        <div class="container">
            <nav class="topbar">
                <div class="brand-lockup">
                    <img src="${pageContext.request.contextPath}/assets/img/supplexio-logo.png" alt="Supplexio">
                    <div>
                        <span class="eyebrow"> Procurement System</span>
                        <strong>Supplexio</strong>
                    </div>
                </div>
                <div class="topbar-actions">
                    <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="btn btn-outline-info btn-pill text-white mr-2"><i class="fas fa-globe-americas mr-1"></i> Global Trade Intel</a>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-light btn-pill">Buyer Login</a>
                    <a href="${pageContext.request.contextPath}/bidding?action=login" class="btn btn-outline-light btn-pill">Supplier Portal</a>
                </div>
            </nav>

            <div class="hero-grid">
                <div class="hero-copy">
                    <span class="tag-badge">Live sourcing command center</span>
                    <h1>One public launch dashboard for buyers, suppliers, and every active auction.</h1>
                    <p>Supplexio brings buyer control, open supplier onboarding, live reverse bidding, and auction visibility together in a single procurement experience without losing the current app’s theme or workflow depth.</p>

                    <div class="hero-cta">
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-primary btn-pill btn-xl">
                            <i class="fas fa-briefcase"></i> Buyer Workspace
                        </a>
                        <a href="${pageContext.request.contextPath}/bidding?action=signup" class="btn btn-secondary btn-pill btn-xl">
                            <i class="fas fa-user-plus"></i> Supplier Signup
                        </a>
                    </div>

                    <div class="stat-ribbon">
                        <div class="stat-tile">
                            <span class="stat-label">Active Auctions</span>
                            <strong>${publicStats.activeAuctions}</strong>
                        </div>
                        <div class="stat-tile">
                            <span class="stat-label">Active Suppliers</span>
                            <strong>${publicStats.activeSuppliers}</strong>
                        </div>
                        <div class="stat-tile">
                            <span class="stat-label">Live Bids</span>
                            <strong>${publicStats.liveBids}</strong>
                        </div>
                        <div class="stat-tile">
                            <span class="stat-label">Products Managed</span>
                            <strong>${publicStats.products}</strong>
                        </div>
                    </div>
                </div>

                <div class="hero-panel glass-panel">
                    <div class="panel-heading">
                        <span>Platform Snapshot</span>
                        <span class="pulse-dot"></span>
                    </div>
                    <div class="hero-kpis">
                        <div>
                            <small>Buyer Control</small>
                            <strong>Secure</strong>
                        </div>
                        <div>
                            <small>Supplier Access</small>
                            <strong>Open</strong>
                        </div>
                        <div>
                            <small>Bidding Mode</small>
                            <strong>Live Reverse</strong>
                        </div>
                    </div>
                    <div class="mini-chart chart-frame chart-frame-dark">
                        <canvas id="auctionPulseChart"></canvas>
                    </div>
                    <ul class="platform-points">
                        <li><i class="fas fa-check-circle"></i> Buyers keep the internal management workspace.</li>
                        <li><i class="fas fa-check-circle"></i> Suppliers can self-register and enter the marketplace.</li>
                        <li><i class="fas fa-check-circle"></i> Active auctions are visible from the first screen.</li>
                    </ul>
                </div>
            </div>
        </div>
    </header>

    <main>
        <section class="info-strip">
            <div class="container info-grid">
                <article class="info-card glass-panel">
                    <i class="fas fa-layer-group"></i>
                    <h3>Project Overview</h3>
                    <p>Procurement, supplier onboarding, auction intelligence, and post-award follow-through are now presented as one connected product story from launch.</p>
                </article>
                <article class="info-card glass-panel">
                    <i class="fas fa-users"></i>
                    <h3>Dual Entry Experience</h3>
                    <p>Buyers sign in to the internal workspace, while suppliers create marketplace accounts and jump directly into available auctions.</p>
                </article>
                <article class="info-card glass-panel">
                    <i class="fas fa-chart-network"></i>
                    <h3>Transparent Activity</h3>
                    <p>Everyone can see active auction momentum, helping the platform feel alive and trustworthy before login.</p>
                </article>
                <article class="info-card glass-panel" style="border-top: 3px solid #38bdf8;">
                    <i class="fas fa-brain text-info"></i>
                    <h3>1D-ResNet Trade Intel</h3>
                    <p>Macroeconomic price benchmarking ($4.2T BACI lakehouse) and automated price-surge auction triggers protect Axalta procurement from inflation.</p>
                </article>
            </div>
        </section>

        <section class="auction-guide-section container">
            <div class="section-header">
                <div>
                    <span class="section-kicker">Auction command guide</span>
                    <h2>How to proceed from launch to completed purchase order</h2>
                </div>
                <a href="${pageContext.request.contextPath}/login.jsp?redirect=%2Fauction%3Faction%3Dnew" class="btn btn-primary btn-pill">
                    <i class="fas fa-plus-circle"></i> Create Auction
                </a>
            </div>

            <div class="guide-command-grid">
                <article class="guide-panel guide-primary-panel">
                    <div class="guide-panel-header">
                        <div>
                            <span class="guide-label">Buyer cockpit</span>
                            <h3>Complete auction path</h3>
                        </div>
                        <span class="radar-badge"><i class="fas fa-bolt"></i> Smart route</span>
                    </div>

                    <div class="process-flow" aria-label="Auction completion flow chart">
                        <div class="flow-step">
                            <span>1</span>
                            <strong>Prepare demand</strong>
                            <p>Add product, quantity, unit, target price, and delivery window.</p>
                        </div>
                        <div class="flow-arrow"><i class="fas fa-arrow-right"></i></div>
                        <div class="flow-step">
                            <span>2</span>
                            <strong>Launch auction</strong>
                            <p>Set start/end time, attach requirements, and invite suppliers.</p>
                        </div>
                        <div class="flow-arrow"><i class="fas fa-arrow-right"></i></div>
                        <div class="flow-step">
                            <span>3</span>
                            <strong>Live reverse bidding</strong>
                            <p>Suppliers compete, best price updates, buyer tracks bid movement.</p>
                        </div>
                        <div class="flow-arrow"><i class="fas fa-arrow-right"></i></div>
                        <div class="flow-step">
                            <span>4</span>
                            <strong>Award winner</strong>
                            <p>Review price, supplier reliability, bid history, and confirm winner.</p>
                        </div>
                        <div class="flow-arrow"><i class="fas fa-arrow-right"></i></div>
                        <div class="flow-step">
                            <span>5</span>
                            <strong>PO and payment</strong>
                            <p>Generate PO, send to supplier, receive delivery, and close payment.</p>
                        </div>
                    </div>

                    <div class="guide-checklist">
                        <div>
                            <i class="fas fa-clipboard-check"></i>
                            <strong>Before starting</strong>
                            <p>Confirm product master data, inventory need, approved budget, bid rules, and supplier shortlist.</p>
                        </div>
                        <div>
                            <i class="fas fa-stopwatch"></i>
                            <strong>During auction</strong>
                            <p>Watch bid velocity, contact suppliers through chat, and keep the end time visible for everyone.</p>
                        </div>
                        <div>
                            <i class="fas fa-file-invoice-dollar"></i>
                            <strong>After award</strong>
                            <p>Convert the winning bid into a PO, share acceptance, monitor delivery, and mark the cycle complete.</p>
                        </div>
                    </div>
                </article>

                <aside class="auction-radar">
                    <div class="radar-core">
                        <span class="radar-ring"></span>
                        <span class="radar-ring radar-ring-two"></span>
                        <i class="fas fa-satellite-dish"></i>
                    </div>
                    <h3>Auction Readiness Radar</h3>
                    <p>Flags the next best action by combining inventory pressure, supplier coverage, and bid activity.</p>
                    <div class="radar-metrics">
                        <div><strong>92%</strong><span>Supplier coverage</span></div>
                        <div><strong>18m</strong><span>Avg response time</span></div>
                        <div><strong>3</strong><span>Actions pending</span></div>
                    </div>
                    <a href="${pageContext.request.contextPath}/login.jsp?redirect=%2Fauction" class="radar-link">Open auction workspace <i class="fas fa-arrow-right"></i></a>
                </aside>
            </div>
        </section>

        <section class="auction-section container">
            <div class="section-header">
                <div>
                    <span class="section-kicker">Public marketplace</span>
                    <h2>Active auctions visible to everyone</h2>
                </div>
                <a href="${pageContext.request.contextPath}/bidding?action=signup" class="btn btn-primary btn-pill">Join as Supplier</a>
            </div>

            <div class="auction-grid">
                <c:forEach var="auction" items="${featuredAuctions}">
                    <article class="auction-card">
                        <div class="auction-card-top">
                            <span class="auction-category">${empty auction.category ? 'Strategic Sourcing' : auction.category}</span>
                            <span class="auction-live">Live</span>
                        </div>
                        <h3>${auction.productName}</h3>
                        <div class="auction-meta">
                            <span><i class="fas fa-cubes"></i> ${auction.requiredQuantity} ${auction.unit}</span>
                            <span><i class="fas fa-gavel"></i> ${auction.bidCount} bids</span>
                        </div>
                        <div class="auction-price">
                            <small>Current Best Price</small>
                            <strong><fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="Rs. " /></strong>
                        </div>
                        <div class="auction-footer">
                            <span><i class="far fa-clock"></i> Ends <fmt:formatDate value="${auction.endTime}" pattern="dd MMM yyyy HH:mm" /></span>
                            <a href="${pageContext.request.contextPath}/bidding?action=login" class="auction-link">Bid Now</a>
                        </div>
                    </article>
                </c:forEach>

                <c:if test="${empty featuredAuctions}">
                    <article class="auction-card empty-state">
                        <h3>No active auctions right now</h3>
                        <p>The marketplace will show new live events here as soon as they are running.</p>
                        <a href="${pageContext.request.contextPath}/bidding?action=signup" class="btn btn-secondary btn-pill">Create Supplier Account</a>
                    </article>
                </c:if>
            </div>
        </section>

        <section class="journey-section container">
            <div class="section-header">
                <div>
                    <span class="section-kicker">How it works</span>
                    <h2>Two role-specific journeys, one procurement engine</h2>
                </div>
            </div>
            <div class="journey-grid">
                <div class="journey-card">
                    <span class="journey-badge">Buyer</span>
                    <h3>Secure internal workspace</h3>
                    <p>Manage products, create auctions, monitor inventory, review bids, and run payment and PO workflows from the existing buyer dashboard.</p>
                </div>
                <div class="journey-card">
                    <span class="journey-badge">Supplier</span>
                    <h3>Open marketplace access</h3>
                    <p>Signup, login, see all active auctions, place bids, and manage awarded purchase orders without waiting for manual onboarding.</p>
                </div>
            </div>
        </section>

        <section class="faq-section container">
            <div class="section-header">
                <div>
                    <span class="section-kicker">Quick Q/A</span>
                    <h2>Questions answered right on the launch dashboard</h2>
                </div>
            </div>
            <div class="faq-grid">
                <div class="faq-card">
                    <h3>What is Supplexio?</h3>
                    <p>A reverse-auction-driven procurement platform that combines sourcing, inventory awareness, supplier competition, and downstream purchasing into one flow.</p>
                </div>
                <div class="faq-card">
                    <h3>Who uses the buyer login?</h3>
                    <p>Internal procurement or operations users who need the management workspace for products, suppliers, auctions, payments, and settings.</p>
                </div>
                <div class="faq-card">
                    <h3>Can new suppliers join directly?</h3>
                    <p>Yes. The marketplace now supports direct supplier signup so outside vendors can create accounts and compete in live auctions.</p>
                </div>
                <div class="faq-card">
                    <h3>Are active auctions public?</h3>
                    <p>Yes. The launch page highlights all live auctions so visitors immediately understand the platform’s current activity.</p>
                </div>
            </div>
        </section>
    </main>

    <footer class="launch-footer">
        <div class="container footer-flex">
            <div>
                <strong>Supplexio Procurement Launch Dashboard</strong>
                <p>Built on the existing Axalta web application theme with a stronger first impression and open supplier marketplace flow.</p>
            </div>
            <div class="footer-actions">
                <a href="${pageContext.request.contextPath}/login.jsp">Buyer Login</a>
                <a href="${pageContext.request.contextPath}/bidding?action=login">Supplier Login</a>
                <a href="${pageContext.request.contextPath}/bidding?action=signup">Supplier Signup</a>
            </div>
        </div>
    </footer>

    <jsp:include page="/WEB-INF/views/common/ai-chatbot.jsp" />

    <script>
        function buildLineChart(id, labels, values, lineColor, fillColor) {
            const ctx = document.getElementById(id);
            if (!ctx) return;
            const isHeroPulse = id === 'auctionPulseChart';
            const axisColor = isHeroPulse ? 'rgba(255, 255, 255, 0.72)' : '#64748b';
            const gridColor = isHeroPulse ? 'rgba(255, 255, 255, 0.16)' : 'rgba(100, 116, 139, 0.18)';

            return new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        borderColor: lineColor,
                        backgroundColor: fillColor,
                        fill: true,
                        tension: 0.35,
                        borderWidth: 3,
                        pointRadius: 0
                    }]
                },
                options: {
                    devicePixelRatio: window.devicePixelRatio || 1,
                    responsive: true,
                    maintainAspectRatio: false,
                    layout: { padding: { top: 8, right: 8, bottom: 4, left: 4 } },
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        x: {
                            grid: { display: false },
                            ticks: {
                                maxRotation: 0,
                                autoSkip: true,
                                maxTicksLimit: 5,
                                color: axisColor,
                                font: { size: 11 }
                            }
                        },
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0,
                                color: axisColor,
                                font: { size: 11 }
                            },
                            grid: { color: gridColor }
                        }
                    }
                }
            });
        }

        function buildBarChart(id, labels, values, color) {
            const ctx = document.getElementById(id);
            if (!ctx) return;

            return new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: color,
                        borderRadius: 10
                    }]
                },
                options: {
                    devicePixelRatio: window.devicePixelRatio || 1,
                    responsive: true,
                    maintainAspectRatio: false,
                    layout: { padding: { top: 8, right: 8, bottom: 0, left: 4 } },
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        x: {
                            grid: { display: false },
                            ticks: {
                                maxRotation: 0,
                                autoSkip: true,
                                maxTicksLimit: 6,
                                color: '#64748b',
                                font: { size: 10 }
                            }
                        },
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0,
                                color: '#64748b',
                                font: { size: 11 }
                            },
                            grid: { color: 'rgba(100, 116, 139, 0.18)' }
                        }
                    }
                }
            });
        }

        function buildDoughnutChart(id, labels, values) {
            const ctx = document.getElementById(id);
            if (!ctx) return;

            return new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: ['#1E3A8A', '#2DD4BF', '#F59E0B'],
                        borderWidth: 0
                    }]
                },
                options: {
                    devicePixelRatio: window.devicePixelRatio || 1,
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '68%',
                    layout: { padding: { top: 8, right: 8, bottom: 8, left: 8 } },
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                usePointStyle: true,
                                boxWidth: 8,
                                padding: 14,
                                color: '#64748b',
                                font: { size: 11 }
                            }
                        }
                    }
                }
            });
        }

        fetch('${pageContext.request.contextPath}/api/dashboard/auctions-over-time')
            .then(response => response.json())
            .then(data => {
                buildLineChart('auctionPulseChart', data.labels, data.values, '#ffffff', 'rgba(255, 255, 255, 0.16)');
            });

    </script>
</body>
</html>
