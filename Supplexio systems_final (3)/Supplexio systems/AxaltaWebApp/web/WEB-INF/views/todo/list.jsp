<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Procurement Action Center &amp; Smart To-Do - Supplexio</title>
    
    <!-- Fonts & Icons -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    
    <style>
        :root {
            --primary-navy: #0f172a;
            --accent-blue: #0284c7;
            --accent-purple: #7c3aed;
            --accent-rose: #e11d48;
            --accent-emerald: #059669;
            --card-border: #e2e8f0;
        }

        body {
            background-color: #f8fafc;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            color: #1e293b;
        }

        .action-header {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #ffffff;
            border-radius: 14px;
            padding: 24px 28px;
            margin-bottom: 24px;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.12);
        }

        /* KPI Stat Cards */
        .kpi-card {
            border-radius: 12px;
            border: 1px solid var(--card-border);
            background: #ffffff;
            padding: 18px 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.03);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.06);
        }
        .kpi-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }

        /* Nudge in Beak Hero Card */
        .nudge-cockpit {
            background: linear-gradient(135deg, #090d16 0%, #141b2d 50%, #0f172a 100%);
            color: #ffffff;
            border-radius: 14px;
            border: 1px solid rgba(124, 58, 237, 0.35);
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.25);
            margin-bottom: 24px;
            position: relative;
            overflow: hidden;
        }
        .nudge-cockpit::after {
            content: '';
            position: absolute;
            top: -40px;
            right: -40px;
            width: 180px;
            height: 180px;
            background: radial-gradient(circle, rgba(124, 58, 237, 0.25) 0%, transparent 70%);
            pointer-events: none;
        }
        .nudge-pill {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 10px;
            padding: 14px 16px;
            height: 100%;
            transition: all 0.2s ease;
        }
        .nudge-pill:hover {
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(255, 255, 255, 0.25);
            transform: translateY(-2px);
        }

        /* Modern Table Card */
        .table-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            overflow: hidden;
        }
        .table-card-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--card-border);
            background: #ffffff;
        }

        /* Quick Filters */
        .filter-tab {
            font-size: 0.85rem;
            font-weight: 600;
            padding: 6px 14px;
            border-radius: 20px;
            border: 1px solid #cbd5e1;
            background: #ffffff;
            color: #475569;
            cursor: pointer;
            margin-right: 6px;
            transition: all 0.15s ease;
        }
        .filter-tab.active, .filter-tab:hover {
            background: #0284c7;
            color: #ffffff;
            border-color: #0284c7;
        }
        .filter-tab.active-nudge {
            background: linear-gradient(135deg, #7c3aed, #4f46e5);
            color: #ffffff;
            border-color: #7c3aed;
        }

        /* Row styling */
        .todo-row {
            transition: background-color 0.15s ease;
        }
        .todo-row:hover {
            background-color: #f8fafc;
        }
        .todo-completed {
            opacity: 0.55;
            text-decoration: line-through;
        }

        /* Badges */
        .badge-nudge {
            background: linear-gradient(135deg, #7c3aed, #4338ca);
            color: #fff;
            font-weight: 700;
            font-size: 0.72rem;
            padding: 4px 8px;
            border-radius: 6px;
        }
        .badge-stock {
            background: linear-gradient(135deg, #ea580c, #c2410c);
            color: #fff;
            font-weight: 700;
            font-size: 0.72rem;
            padding: 4px 8px;
            border-radius: 6px;
        }
        .badge-trade {
            background: linear-gradient(135deg, #0284c7, #0369a1);
            color: #fff;
            font-weight: 700;
            font-size: 0.72rem;
            padding: 4px 8px;
            border-radius: 6px;
        }

        .btn-gradient-ai {
            background: linear-gradient(135deg, #7c3aed, #2563eb);
            color: #ffffff;
            border: none;
            transition: all 0.2s ease;
        }
        .btn-gradient-ai:hover {
            background: linear-gradient(135deg, #6d28d9, #1d4ed8);
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(124, 58, 237, 0.35);
        }
    </style>
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <div class="container-fluid px-4 py-3">

            <!-- Alerts -->
            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert" style="border-radius:10px;">
                    <i class="fas fa-check-circle mr-2"></i> ${success}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert" style="border-radius:10px;">
                    <i class="fas fa-exclamation-triangle mr-2"></i> ${error}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </c:if>

            <!-- Page Header -->
            <div class="action-header d-flex justify-content-between align-items-center flex-wrap">
                <div>
                    <h2 class="font-weight-bold mb-1 text-white">
                        <i class="fas fa-clipboard-check text-primary mr-2"></i>Procurement Action Center &amp; Smart To-Do
                    </h2>
                    <p class="text-light opacity-75 mb-0" style="font-size:0.95rem;">
                        Autonomous trade intelligence, predictive hedging alerts &amp; daily operational execution
                    </p>
                </div>
                <div class="mt-2 mt-md-0 d-flex flex-wrap">
                    <a href="${pageContext.request.contextPath}/todo?action=generateAiNudges" class="btn btn-gradient-ai font-weight-bold shadow-sm mr-2 mb-1">
                        <i class="fas fa-brain fa-pulse mr-1"></i> AI Sync: Trade Nudges
                    </a>
                    <a href="${pageContext.request.contextPath}/todo?action=new" class="btn btn-primary font-weight-bold shadow-sm mb-1">
                        <i class="fas fa-plus-circle mr-1"></i> Add New Task
                    </a>
                </div>
            </div>

            <!-- Compute KPI Counts -->
            <c:set var="totalTasks" value="${fn:length(todos)}" />
            <c:set var="pendingTasks" value="0" />
            <c:set var="highTasks" value="0" />
            <c:set var="nudgeTasks" value="0" />
            <c:set var="completedTasks" value="0" />

            <c:forEach var="t" items="${todos}">
                <c:if test="${t.status == 'PENDING'}">
                    <c:set var="pendingTasks" value="${pendingTasks + 1}" />
                </c:if>
                <c:if test="${t.status == 'COMPLETED'}">
                    <c:set var="completedTasks" value="${completedTasks + 1}" />
                </c:if>
                <c:if test="${t.priority == 'HIGH' and t.status == 'PENDING'}">
                    <c:set var="highTasks" value="${highTasks + 1}" />
                </c:if>
                <c:if test="${fn:contains(t.title, 'Nudge')}">
                    <c:set var="nudgeTasks" value="${nudgeTasks + 1}" />
                </c:if>
            </c:forEach>

            <!-- Top KPI Stat Cards -->
            <div class="row mb-4">
                <div class="col-xl-3 col-sm-6 mb-3 mb-xl-0">
                    <div class="kpi-card d-flex align-items-center justify-content-between">
                        <div>
                            <small class="text-muted font-weight-bold text-uppercase d-block mb-1" style="font-size:0.75rem;">Total Tasks</small>
                            <h3 class="font-weight-bold text-dark mb-0">${totalTasks}</h3>
                            <small class="text-muted"><i class="fas fa-tasks text-secondary mr-1"></i>In procurement queue</small>
                        </div>
                        <div class="kpi-icon" style="background:#e0f2fe; color:#0284c7;">
                            <i class="fas fa-list-ul"></i>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-sm-6 mb-3 mb-xl-0">
                    <div class="kpi-card d-flex align-items-center justify-content-between" style="border-left:4px solid #f59e0b;">
                        <div>
                            <small class="text-muted font-weight-bold text-uppercase d-block mb-1" style="font-size:0.75rem;">Pending Actions</small>
                            <h3 class="font-weight-bold mb-0" style="color:#d97706;">${pendingTasks}</h3>
                            <small class="text-warning font-weight-bold"><i class="fas fa-hourglass-half mr-1"></i>Awaiting fulfillment</small>
                        </div>
                        <div class="kpi-icon" style="background:#fef3c7; color:#d97706;">
                            <i class="fas fa-clock"></i>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-sm-6 mb-3 mb-xl-0">
                    <div class="kpi-card d-flex align-items-center justify-content-between" style="border-left:4px solid #e11d48;">
                        <div>
                            <small class="text-muted font-weight-bold text-uppercase d-block mb-1" style="font-size:0.75rem;">High Priority Actions</small>
                            <h3 class="font-weight-bold text-danger mb-0">${highTasks}</h3>
                            <small class="text-danger font-weight-bold"><i class="fas fa-fire mr-1"></i>Pending immediate action</small>
                        </div>
                        <div class="kpi-icon" style="background:#ffe4e6; color:#e11d48;">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-sm-6 mb-3 mb-xl-0">
                    <div class="kpi-card d-flex align-items-center justify-content-between" style="border-left:4px solid #059669;">
                        <div>
                            <small class="text-muted font-weight-bold text-uppercase d-block mb-1" style="font-size:0.75rem;">Completed</small>
                            <h3 class="font-weight-bold text-success mb-0">${completedTasks}</h3>
                            <small class="text-success"><i class="fas fa-check-circle mr-1"></i>Fulfilled &amp; closed</small>
                        </div>
                        <div class="kpi-icon" style="background:#d1fae5; color:#059669;">
                            <i class="fas fa-check-double"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Task Management Table Card -->
            <div class="table-card">
                <div class="table-card-header d-flex justify-content-between align-items-center flex-wrap">
                    <div class="d-flex align-items-center flex-wrap mb-2 mb-md-0">
                        <span class="font-weight-bold text-dark mr-3"><i class="fas fa-tasks mr-2 text-primary"></i>Task Directory</span>
                        <div class="d-flex flex-wrap" id="taskFilterButtons">
                            <button type="button" class="filter-tab active" data-filter="ALL">All (${totalTasks})</button>
                            <button type="button" class="filter-tab" data-filter="PENDING">⏳ Pending (${pendingTasks})</button>
                            <button type="button" class="filter-tab" data-filter="HIGH">🔥 High Priority (${highTasks})</button>
                            <button type="button" class="filter-tab" data-filter="COMPLETED">✅ Completed (${completedTasks})</button>
                        </div>
                    </div>

                    <!-- Live search box -->
                    <div class="input-group" style="max-width: 280px;">
                        <div class="input-group-prepend">
                            <span class="input-group-text bg-white border-right-0"><i class="fas fa-search text-muted"></i></span>
                        </div>
                        <input type="text" id="taskSearchInput" class="form-control border-left-0" placeholder="Filter tasks by keyword..." style="font-size:0.85rem;">
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="todoTable">
                        <thead style="background:#f1f5f9; color:#475569; font-size:0.85rem; text-transform:uppercase; letter-spacing:0.5px;">
                            <tr>
                                <th style="width:45px;" class="text-center">Status</th>
                                <th>Task Title &amp; Trade Narrative</th>
                                <th style="width:130px;">Due Date</th>
                                <th style="width:110px;">Priority</th>
                                <th style="width:100px;">State</th>
                                <th style="width:160px;" class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty todos}">
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            <i class="fas fa-check-circle fa-3x text-success mb-3 d-block"></i>
                                            <h5 class="font-weight-bold text-dark">No tasks in your queue!</h5>
                                            <p class="small text-muted mb-3">Click below to synchronize AI trade intelligence alerts.</p>
                                            <a href="${pageContext.request.contextPath}/todo?action=generateAiNudges" class="btn btn-sm btn-gradient-ai font-weight-bold">
                                                <i class="fas fa-brain mr-1"></i> Generate AI Trade Nudges
                                            </a>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="todo" items="${todos}">
                                        <c:set var="isNudge" value="${fn:contains(todo.title, 'Nudge')}" />
                                        <c:set var="isStockNudge" value="${fn:contains(todo.title, 'Stock')}" />
                                        <c:set var="isAuctionNudge" value="${fn:contains(todo.title, 'Titanium') or fn:contains(todo.title, 'Auction')}" />

                                        <tr class="todo-row ${todo.status == 'COMPLETED' ? 'todo-completed' : ''}"
                                            data-status="${todo.status}"
                                            data-priority="${todo.priority}"
                                            data-is-nudge="${isNudge ? 'true' : 'false'}">
                                            
                                            <!-- Checkbox Quick-Complete -->
                                            <td class="text-center align-middle">
                                                <c:choose>
                                                    <c:when test="${todo.status == 'COMPLETED'}">
                                                        <i class="fas fa-check-circle text-success fa-lg" title="Completed"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="${pageContext.request.contextPath}/todo" method="post" class="d-inline">
                                                            <input type="hidden" name="action" value="complete">
                                                            <input type="hidden" name="id" value="${todo.id}">
                                                            <button type="submit" class="btn btn-sm btn-link p-0 text-muted" title="Click to mark done" style="outline:none;">
                                                                <i class="far fa-circle fa-lg"></i>
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Title & Narrative -->
                                            <td class="align-middle">
                                                <div class="d-flex align-items-center mb-1">
                                                    <c:choose>
                                                        <c:when test="${fn:contains(todo.title, '[AI Nudge]')}">
                                                            <span class="badge badge-nudge mr-2"><i class="fas fa-brain mr-1"></i>1D-ResNet Surge</span>
                                                        </c:when>
                                                        <c:when test="${fn:contains(todo.title, '[Stock Nudge]')}">
                                                            <span class="badge badge-stock mr-2"><i class="fas fa-boxes mr-1"></i>Kanban Alert</span>
                                                        </c:when>
                                                        <c:when test="${fn:contains(todo.title, '[Trade Nudge]')}">
                                                            <span class="badge badge-trade mr-2"><i class="fas fa-globe mr-1"></i>Sourcing Shift</span>
                                                        </c:when>
                                                    </c:choose>
                                                    <strong class="text-dark task-title" style="font-size:0.95rem;">${todo.title}</strong>
                                                </div>
                                                <c:if test="${not empty todo.description}">
                                                    <div class="text-muted small task-desc" style="line-height:1.35; max-width:680px;">
                                                        ${todo.description}
                                                    </div>
                                                </c:if>
                                            </td>

                                            <!-- Due Date -->
                                            <td class="align-middle" style="font-size:0.85rem;">
                                                <c:choose>
                                                    <c:when test="${empty todo.dueDate}">
                                                        <span class="text-muted font-italic">No date</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="font-weight-bold text-dark">
                                                            <fmt:formatDate value="${todo.dueDate}" pattern="yyyy-MM-dd" />
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Priority -->
                                            <td class="align-middle">
                                                <c:choose>
                                                    <c:when test="${todo.priority == 'HIGH'}">
                                                        <span class="badge badge-danger font-weight-bold p-1 px-2" style="font-size:0.75rem;"><i class="fas fa-fire mr-1"></i>High</span>
                                                    </c:when>
                                                    <c:when test="${todo.priority == 'MEDIUM'}">
                                                        <span class="badge badge-warning text-dark font-weight-bold p-1 px-2" style="font-size:0.75rem;"><i class="fas fa-minus mr-1"></i>Medium</span>
                                                    </c:when>
                                                    <c:when test="${todo.priority == 'LOW'}">
                                                        <span class="badge badge-info font-weight-bold p-1 px-2" style="font-size:0.75rem;"><i class="fas fa-arrow-down mr-1"></i>Low</span>
                                                    </c:when>
                                                </c:choose>
                                            </td>

                                            <!-- State -->
                                            <td class="align-middle">
                                                <c:choose>
                                                    <c:when test="${todo.status == 'COMPLETED'}">
                                                        <span class="badge badge-success p-1 px-2" style="font-size:0.75rem;"><i class="fas fa-check mr-1"></i>Done</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary p-1 px-2" style="font-size:0.75rem;"><i class="fas fa-clock mr-1"></i>Pending</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Actions & Direct Links -->
                                            <td class="align-middle text-right">
                                                <div class="d-flex align-items-center justify-content-end">
                                                    <!-- Smart Action Links based on task context -->
                                                    <c:if test="${isAuctionNudge}">
                                                        <a href="${pageContext.request.contextPath}/auction?action=new" class="btn btn-xs btn-outline-danger font-weight-bold mr-1 p-1 px-2" style="font-size:0.75rem;" title="Launch Reverse Auction">
                                                            <i class="fas fa-gavel"></i> Auction
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${isStockNudge}">
                                                        <a href="${pageContext.request.contextPath}/inventory" class="btn btn-xs btn-outline-warning text-dark font-weight-bold mr-1 p-1 px-2" style="font-size:0.75rem;" title="Open Inventory">
                                                            <i class="fas fa-warehouse"></i> Stock
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${fn:contains(todo.title, 'Wood Door')}">
                                                        <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="btn btn-xs btn-outline-info font-weight-bold mr-1 p-1 px-2" style="font-size:0.75rem;" title="View Global Trade Intel">
                                                            <i class="fas fa-chart-line"></i> Intel
                                                        </a>
                                                    </c:if>

                                                    <div class="btn-group btn-group-sm">
                                                        <a href="${pageContext.request.contextPath}/todo?action=view&id=${todo.id}" 
                                                           class="btn btn-light border text-muted" title="View Details">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/todo?action=edit&id=${todo.id}" 
                                                           class="btn btn-light border text-primary" title="Edit">
                                                            <i class="fas fa-pencil-alt"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/todo?action=delete&id=${todo.id}" 
                                                           class="btn btn-light border text-danger" 
                                                           onclick="return confirm('Delete this task?')" title="Delete">
                                                            <i class="fas fa-trash-alt"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
    
    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function() {
            var currentFilter = 'ALL';

            // Filter button pill click handler
            $('.filter-tab').on('click', function() {
                $('.filter-tab').removeClass('active active-nudge');
                $(this).addClass('active');
                if ($(this).data('filter') === 'NUDGE') {
                    $(this).addClass('active-nudge');
                }
                currentFilter = $(this).data('filter');
                applyFilters();
            });

            // Live search input handler
            $('#taskSearchInput').on('input', function() {
                applyFilters();
            });

            function applyFilters() {
                var searchQ = $('#taskSearchInput').val().toLowerCase().trim();

                $('#todoTable tbody tr.todo-row').each(function() {
                    var $row = $(this);
                    var status = $row.data('status');
                    var priority = $row.data('priority');
                    var isNudge = $row.data('is-nudge') === true || $row.data('is-nudge') === 'true';
                    var titleText = $row.find('.task-title').text().toLowerCase();
                    var descText = $row.find('.task-desc').text().toLowerCase();

                    var matchesSearch = !searchQ || titleText.indexOf(searchQ) !== -1 || descText.indexOf(searchQ) !== -1;
                    var matchesFilter = true;

                    if (currentFilter === 'PENDING') {
                        matchesFilter = (status === 'PENDING');
                    } else if (currentFilter === 'COMPLETED') {
                        matchesFilter = (status === 'COMPLETED');
                    } else if (currentFilter === 'HIGH') {
                        matchesFilter = (priority === 'HIGH' && status === 'PENDING');
                    } else if (currentFilter === 'NUDGE') {
                        matchesFilter = isNudge;
                    }

                    if (matchesSearch && matchesFilter) {
                        $row.show();
                    } else {
                        $row.hide();
                    }
                });
            }
        });
    </script>
</body>
</html>
