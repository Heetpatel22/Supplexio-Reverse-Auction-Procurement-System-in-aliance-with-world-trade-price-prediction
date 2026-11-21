<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html data-theme="light">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Trade Intelligence - Supplexio Intellect</title>
    
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <style>
        .intel-header-card {
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #0369a1 100%);
            color: #ffffff;
            padding: 1.5rem 2rem;
            border-radius: 14px;
            margin-bottom: 1.5rem;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.25);
        }
        .intel-badge {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            padding: 4px 12px;
            font-size: 0.8rem;
            display: inline-block;
            margin-bottom: 0.5rem;
            color: #bae6fd;
            font-weight: 600;
        }
        .intel-kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        .intel-kpi-item {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 10px;
            padding: 0.75rem 1rem;
        }
        .intel-kpi-item small {
            display: block;
            color: #93c5fd;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .intel-kpi-item strong {
            font-size: 1.25rem;
            font-weight: 700;
            color: #ffffff;
        }
        .streamlit-frame-card {
            background: var(--card-bg, #ffffff);
            border: 1px solid var(--border-color, #e2e8f0);
            border-radius: 14px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .frame-toolbar {
            background: var(--table-header-bg, #f8fafc);
            border-bottom: 1px solid var(--border-color, #e2e8f0);
            padding: 0.75rem 1.25rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .embedded-frame {
            width: 100%;
            height: 900px;
            border: none;
            display: block;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <div class="main-content">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb" style="background:transparent; padding:0;">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home?action=workspace" style="color:var(--primary-color);">Dashboard</a></li>
                <li class="breadcrumb-item active" style="color:var(--muted-text);">Global Trade Intelligence Engine</li>
            </ol>
        </nav>

        <!-- Executive Banner -->
        <div class="intel-header-card">
            <div class="d-flex justify-content-between align-items-start flex-wrap">
                <div>
                    <span class="intel-badge"><i class="fas fa-brain mr-1"></i> 1D-ResNet & PySpark Lakehouse Integrated</span>
                    <h2 class="font-weight-bold mb-1">Global Trade Dynamics & Predictive Sourcing Intelligence</h2>
                    <p class="mb-0 text-white-50" style="max-width: 800px;">
                        Monitoring macroeconomic bilateral trade flows across 153 export and 226 import nations ($4.2T UN Comtrade/BACI data) with deep learning price forecasting for critical raw materials (Titanium Dioxide, Solvents, Resins, Copper).
                    </p>
                </div>
                <div class="mt-3 mt-md-0">
                    <a href="${pageContext.request.contextPath}/auction?action=new" class="btn btn-warning font-weight-bold shadow-sm mr-2">
                        <i class="fas fa-gavel mr-1"></i> Launch Reverse Auction
                    </a>
                    <a href="http://localhost:8501" target="_blank" class="btn btn-outline-light">
                        <i class="fas fa-external-link-alt mr-1"></i> Fullscreen View
                    </a>
                </div>
            </div>

            <div class="intel-kpi-grid">
                <div class="intel-kpi-item">
                    <small>Deep Learning Model</small>
                    <strong>1D-ResNet Neural Net</strong>
                </div>
                <div class="intel-kpi-item">
                    <small>Price Forecast Accuracy</small>
                    <strong>R² = 88.29%</strong>
                </div>
                <div class="intel-kpi-item">
                    <small>Inference Latency</small>
                    <strong>&lt; 9.4 ms</strong>
                </div>
                <div class="intel-kpi-item">
                    <small>Cluster Segmentation</small>
                    <strong>PCA (28) + K-Means (10)</strong>
                </div>
                <div class="intel-kpi-item">
                    <small>Big Data Runtime</small>
                    <strong>PySpark Lakehouse</strong>
                </div>
            </div>
        </div>

        <!-- Embedded Streamlit Analytics Container -->
        <div class="streamlit-frame-card">
            <div class="frame-toolbar">
                <div>
                    <i class="fas fa-chart-line text-primary mr-2"></i>
                    <strong>Interactive Trade Flow Analytics & Model Diagnostics</strong>
                    <span class="badge badge-success ml-2">Live Connected (:8501)</span>
                </div>
                <div>
                    <button class="btn btn-sm btn-outline-secondary" onclick="document.getElementById('streamlitFrame').src += ''">
                        <i class="fas fa-sync-alt mr-1"></i> Reload Feed
                    </button>
                </div>
            </div>
            <iframe id="streamlitFrame" src="http://localhost:8501/?embed=true" class="embedded-frame"></iframe>
        </div>
    </div>
</body>
</html>

