<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:choose><c:when test="${isAdmin}">User Management</c:when><c:otherwise>Settings</c:otherwise></c:choose> - Supplexio</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/settings.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body {
            padding-left: 250px;
            background: var(--bg-color);
        }
        .main-content {
            margin-left: 0;
            padding: 2rem;
        }
        @media (max-width: 991px) {
            body {
                padding-left: 0;
            }
            .main-content {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <div class="main-content">
        <div class="page-header">
            <h1 class="page-title">
                <c:choose>
                    <c:when test="${isAdmin}">User Management</c:when>
                    <c:otherwise>Settings</c:otherwise>
                </c:choose>
            </h1>
            <c:if test="${isAdmin}">
            <a href="${pageContext.request.contextPath}/settings?action=newUser" class="btn-supplexio">
                <i class="fas fa-plus-circle"></i> Add New User
            </a>
            </c:if>
        </div>

        <div class="settings-grid">
            <div class="settings-card">
                <div class="theme-setting-row">
                    <div>
                        <h2>Appearance</h2>
                        <p>Use this switch to change the dashboard theme.</p>
                        <div class="theme-setting-label">
                            <i class="fas fa-moon"></i>
                            <span>Dark Mode</span>
                        </div>
                    </div>
                    <label class="sp-toggle-switch" title="Toggle dark mode">
                        <input type="checkbox" id="spDarkToggle">
                        <span class="sp-toggle-slider"></span>
                    </label>
                </div>
            </div>

            <div class="settings-card">
                <h2><i class="fas fa-lock"></i> Change Password</h2>
                <p>Update the password for your signed-in account.</p>

                <c:if test="${not empty sessionScope.pwdSuccess}">
                    <div class="settings-feedback ok">
                        <i class="fas fa-check-circle"></i> ${sessionScope.pwdSuccess}
                    </div>
                    <c:remove var="pwdSuccess" scope="session" />
                </c:if>
                <c:if test="${not empty sessionScope.pwdError}">
                    <div class="settings-feedback err">
                        <i class="fas fa-exclamation-circle"></i> ${sessionScope.pwdError}
                    </div>
                    <c:remove var="pwdError" scope="session" />
                </c:if>

                <form class="password-settings-form" method="post" action="${pageContext.request.contextPath}/settings">
                    <input type="hidden" name="action" value="changePassword">
                    <input type="password" name="oldPassword" class="form-control" placeholder="Current Password" required>
                    <input type="password" name="newPassword" class="form-control" placeholder="New Password" required minlength="6">
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm New Password" required minlength="6">
                    <button type="submit" class="btn-supplexio">
                        <i class="fas fa-save"></i> Update Password
                    </button>
                </form>
            </div>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${sessionScope.successMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${sessionScope.errorMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <c:if test="${isAdmin}">
        <div class="users-table">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Last Login</th>
                        <th>Created</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${users}" var="user">
                        <tr>
                            <td>${user.id}</td>
                            <td>${user.username}</td>
                            <td>${user.email}</td>
                            <td>${user.role}</td>
                            <td>
                                <span class="status-badge status-${user.status.toLowerCase()}">
                                    ${user.status}
                                </span>
                            </td>
                            <td>
                                <fmt:formatDate value="${user.lastLogin}" pattern="yyyy-MM-dd HH:mm" />
                            </td>
                            <td>
                                <fmt:formatDate value="${user.createdAt}" pattern="yyyy-MM-dd" />
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/settings?action=editUser&id=${user.id}" class="action-btn edit">
                                    Edit
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        </c:if>

        <div class="footer-text">
            <p>Global leader in coatings providing customers with innovative, colorful, beautiful and sustainable solutions.</p>
            <p>&copy; ${java.time.Year.now().getValue()} Supplexio. All rights reserved.</p>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var darkToggle = document.getElementById('spDarkToggle');
            if (!darkToggle) {
                return;
            }

            var currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
            darkToggle.checked = currentTheme === 'dark';

            darkToggle.addEventListener('change', function() {
                var theme = this.checked ? 'dark' : 'light';
                document.documentElement.setAttribute('data-theme', theme);
                localStorage.setItem('sp-theme', theme);
            });
        });
    </script>
</body>
</html>
