<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script>
window.applyBuyerDarkMode = function(isDark) {
    document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
    document.documentElement.classList.toggle('dark', !!isDark);
    if (document.body) {
        document.body.classList.toggle('dark', !!isDark);
    }
    localStorage.setItem('sp-theme', isDark ? 'dark' : 'light');
};
(function() {
    var savedTheme = localStorage.getItem('sp-theme') || 'light';
    window.applyBuyerDarkMode(savedTheme === 'dark');
})();
</script>
<style>
/* Global Buyer Portal Dark Mode Theme */
html.dark body,
html[data-theme="dark"] body {
    background-color: #0B1120 !important;
    color: #E2E8F0 !important;
}
html.dark main,
html.dark .main-content,
html.dark .sp-main,
html.dark .container-fluid,
html.dark .content-wrapper,
html.dark [class~="bg-[#F4F7FC]"],
html.dark [class~="bg-[#edf3ff]"],
html.dark [class~="bg-[#f8fafc]"],
html.dark [class~="bg-[#F8FAFC]"],
html[data-theme="dark"] .main-content,
html[data-theme="dark"] .sp-main {
    background-color: #0B1120 !important;
    color: #E2E8F0 !important;
}

/* White & Slate-50 Cards, Drawers, Panels, Toolbars */
html.dark .card,
html.dark .settings-card,
html.dark .stat-card,
html.dark .kpi-card,
html.dark .dashboard-card,
html.dark .panel,
html.dark .modal-content,
html.dark .table-card,
html.dark .bg-white,
html.dark [class~="bg-white/80"],
html.dark [class~="bg-white/90"],
html.dark [class~="bg-white/95"],
html.dark .bg-slate-50,
html.dark [class~="bg-slate-50/70"],
html.dark [class~="bg-slate-50/80"],
html.dark [class~="bg-slate-50/90"],
html.dark .bg-gray-50,
html.dark aside:not(#sp-unified-sidebar):not(.bg-gradient-to-b),
html[data-theme="dark"] .card,
html[data-theme="dark"] .settings-card,
html[data-theme="dark"] .modal-content {
    background-color: #111827 !important;
    border-color: #1E293B !important;
    color: #E2E8F0 !important;
}

/* Subtle Slate-100 / Slate-200 / Gray-100 Surfaces */
html.dark .bg-slate-100,
html.dark .bg-slate-200,
html.dark .bg-gray-100,
html.dark .bg-gray-200 {
    background-color: #1E293B !important;
    border-color: #334155 !important;
    color: #E2E8F0 !important;
}

/* Tinted 50-level Badges & Boxes (Exact class token match, never *-500!) */
html.dark .bg-blue-50,
html.dark .bg-indigo-50,
html.dark .bg-sky-50,
html.dark .bg-cyan-50,
html.dark .bg-teal-50,
html.dark [class~="bg-blue-50/70"],
html.dark [class~="bg-teal-50/50"] {
    background-color: rgba(14, 116, 144, 0.18) !important;
    border-color: rgba(45, 212, 191, 0.32) !important;
    color: #67E8F9 !important;
}
html.dark .bg-emerald-50,
html.dark .bg-green-50,
html.dark [class~="bg-emerald-50/70"] {
    background-color: rgba(16, 185, 129, 0.16) !important;
    border-color: rgba(52, 211, 153, 0.32) !important;
    color: #6EE7B7 !important;
}
html.dark .bg-amber-50,
html.dark .bg-yellow-50,
html.dark .bg-orange-50,
html.dark [class~="bg-amber-50/70"] {
    background-color: rgba(245, 158, 11, 0.16) !important;
    border-color: rgba(251, 191, 36, 0.32) !important;
    color: #FCD34D !important;
}
html.dark .bg-rose-50,
html.dark .bg-red-50,
html.dark [class~="bg-rose-50/70"] {
    background-color: rgba(244, 63, 94, 0.16) !important;
    border-color: rgba(251, 113, 133, 0.32) !important;
    color: #FDA4AF !important;
}

/* Headers, Modals, Bootstrap Surfaces */
html.dark .card-header,
html.dark .modal-header,
html.dark .modal-footer,
html.dark .bg-light {
    background-color: #0F172A !important;
    border-color: #1E293B !important;
    color: #F8FAFC !important;
}

/* Typography */
html.dark h1, html.dark h2, html.dark h3, html.dark h4, html.dark h5, html.dark h6,
html.dark .page-title, html.dark .card-title, html.dark .text-dark,
html.dark .text-slate-900, html.dark .text-slate-800,
html.dark .text-gray-900, html.dark .text-gray-800,
html.dark .text-black {
    color: #F8FAFC !important;
}
html.dark .text-slate-700, html.dark .text-slate-600,
html.dark .text-gray-700, html.dark .text-gray-600 {
    color: #CBD5E1 !important;
}
html.dark [class~="text-[#0B1E47]"],
html.dark [class~="text-[#102A63]"],
html.dark [class~="text-[#1E3A8A]"],
html.dark .text-blue-900,
html.dark .text-blue-800 {
    color: #93C5FD !important;
}
html.dark .text-muted, html.dark .text-secondary,
html.dark .text-slate-500, html.dark .text-gray-500 {
    color: #94A3B8 !important;
}

/* Borders & Dividers */
html.dark .border-slate-100, html.dark .border-slate-200, html.dark .border-slate-300,
html.dark .border-gray-100, html.dark .border-gray-200, html.dark .border-gray-300,
html.dark [class~="border-[#E2E8F0]"],
html.dark [class*="divide-slate-"] > :not([hidden]) ~ :not([hidden]) {
    border-color: #1E293B !important;
}

/* Tables */
html.dark table, html.dark .table {
    color: #E2E8F0 !important;
    background-color: #111827 !important;
}
html.dark .table th, html.dark .table td,
html.dark .table-bordered th, html.dark .table-bordered td,
html.dark th, html.dark td {
    border-color: #1E293B !important;
}
html.dark .table thead th, html.dark .thead-dark th, html.dark thead tr {
    background-color: #0F172A !important;
    color: #CBD5E1 !important;
    border-color: #1E293B !important;
}
html.dark .table-hover tbody tr:hover,
html.dark tbody tr:hover,
html.dark .table-striped tbody tr:nth-of-type(odd) {
    background-color: rgba(30, 41, 59, 0.55) !important;
}

/* Form Controls */
html.dark input:not([type="checkbox"]):not([type="radio"]):not([type="range"]),
html.dark select,
html.dark textarea,
html.dark .form-control {
    background-color: #0F172A !important;
    border-color: #334155 !important;
    color: #F8FAFC !important;
}
html.dark input::placeholder,
html.dark textarea::placeholder {
    color: #64748B !important;
}

/* Dropdowns */
html.dark .dropdown-menu {
    background-color: #111827 !important;
    border-color: #1E293B !important;
    color: #E2E8F0 !important;
}
html.dark .dropdown-item {
    color: #E2E8F0 !important;
}
html.dark .dropdown-item:hover {
    background-color: #1E293B !important;
}

/* Preserve vibrant primary & amber CTA buttons */
html.dark button[class*="bg-amber-"],
html.dark a[class*="bg-amber-"],
html.dark button[class~="bg-[#F59E0B]"],
html.dark a[class~="bg-[#F59E0B]"] {
    color: #0F172A !important;
}
html.dark button.bg-amber-500, html.dark a.bg-amber-500,
html.dark button.bg-amber-400, html.dark a.bg-amber-400 {
    background-color: #F59E0B !important;
    color: #0F172A !important;
}
</style>

