package com.axaltacoating.servlet;

import com.axaltacoating.model.Supplier;
import com.axaltacoating.model.User;
import com.axaltacoating.util.DatabaseConnection;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

@WebServlet(name = "AiChatServlet", urlPatterns = {"/ai-chat"})
public class AiChatServlet extends HttpServlet {
    private static final String DEFAULT_MODEL = "gemini-2.5-flash";
    private static final String GEMINI_ENDPOINT =
            "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent";

    private static final String PROJECT_GUIDE =
            "You are Supplexio AI Copilot, an expert in-app assistant and platform guide for the Supplexio Enterprise Procurement & Global Trade Intelligence platform. "
            + "Supplexio combines a Buyer Portal, a Supplier Portal, Reverse Auctions, Automated Purchase Orders, Settlement Payments, Kanban Inventory, and a 1D-ResNet Global Trade Intelligence engine. "
            + "\n\nBUYER PORTAL ROUTES & FEATURES:\n"
            + "- /index.jsp (or /home?action=workspace): Buyer Command Cockpit with KPIs, spot ticker, savings trajectory, and live auction pulse.\n"
            + "- /product: Product Catalog with HSN codes and base pricing.\n"
            + "- /inventory: Kanban Inventory Management with stock thresholds, 1D-ResNet + multi-source live price forecasts (Yahoo Finance, World Bank Pink Sheet, FRED, UN Comtrade, DGFT/CBIC, NIRYAT), Top 10 Growing (+) and Top 10 Biggest Drops (-) lists, and one-click Reverse Auction launch.\n"
            + "- /trade-intelligence.jsp: Global Trade Intelligence & World Trade Matrix with 1D-ResNet neural forecasts and commodity analytics.\n"
            + "- /auction: Reverse Auction Management with live countdowns, Landed Duty-Paid (LDP) BACI Normalizer, bid history, Award PO, and Mark Delivered.\n"
            + "- /supplier: Verified Supplier Directory and onboarding management.\n"
            + "- /user-po-view: Buyer Purchase Orders (Draft PO -> Verify & Send -> PO Accepted -> Shipped -> Delivered -> Invoice Pending -> Payment Pending -> Paid & Settled -> Close) + PO/GRN/Invoice PDFs.\n"
            + "- /payment: Payment Management & Settlement Ledger.\n"
            + "- /todo: Procurement Action Center & Smart To-Do (including AI Trade Nudges and Stock Alerts).\n"
            + "- /settings: Buyer Workspace Configuration (Organization & Buyer Profile, Auction & AI Rules, Security & Preferences with Active Login Sessions, Change Password, Dark Mode, and optional Business Documents: PAN, Aadhar, Registration Certificate).\n"
            + "\nSUPPLIER PORTAL ROUTES & FEATURES:\n"
            + "- /bidding?action=login & /bidding?action=signup: Supplier Authentication & Onboarding.\n"
            + "- /bidding: Supplier Live Auction Marketplace with live timers, L1 floor prices, and quick bid drawer.\n"
            + "- /bidding?action=view&id=<ID>: Reverse Auction Bidding Room with Chart.js bid trend, quick undercut chips, product photos, and Buyer Messages.\n"
            + "- /supplier-po-view: Supplier My Purchase Orders workflow: PO_SENT (Accept PO) -> PO_ACCEPTED (Fill Shipping Details / ASN) -> SHIPPED -> DELIVERED / INVOICE REQUESTED (Upload Commercial Invoice) -> PAYMENT_PENDING -> PAYMENT_SUCCESSFUL -> CLOSED.\n"
            + "- /bidding?action=profile: Supplier Profile & Account Settings (editable Company Name, Email, Phone, Address, Change Password, and optional PAN, Aadhar, and Business Registration Certificate).\n"
            + "\nINSTRUCTIONS:\n"
            + "- Guide users clearly step-by-step on how to use any feature or complete any workflow in Supplexio.\n"
            + "- Use the LIVE PLATFORM & GLOBAL TRADE SNAPSHOT provided below to answer questions accurately about current counts, active auctions, low-stock items, POs, or trade forecasts.\n"
            + "- Never reveal private passwords, database credentials, or API keys. Keep answers concise, accurate, and actionable.";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        String apiKey = resolveEnvValue("GEMINI_API_KEY", "gemini.api.key", "geminiApiKey");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            writeJson(response, "Gemini is not configured yet. Paste GEMINI_API_KEY in d:\\World-trade-intelligence\\.env and try again.");
            return;
        }

        String question = null;
        String currentPage = null;
        try {
            JSONObject reqJson = readRequestJson(request);
            if (reqJson != null) {
                Object msgObj = reqJson.get("message");
                Object pageObj = reqJson.get("page");
                question = msgObj != null ? msgObj.toString() : null;
                currentPage = pageObj != null ? pageObj.toString() : null;
            } else {
                question = request.getParameter("message");
            }
        } catch (Exception ex) {
            Logger.getLogger(AiChatServlet.class.getName()).log(Level.SEVERE, null, ex);
        }

        if (question == null || question.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(response, "Please type a question first.");
            return;
        }

        if (question.length() > 1200) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(response, "Please keep the question under 1200 characters.");
            return;
        }

        try {
            String liveContext = buildLiveContext(request, currentPage);
            String answer = askGemini(apiKey.trim(), question.trim(), liveContext);
            writeJson(response, answer);
        } catch (Exception e) {
            Logger.getLogger(AiChatServlet.class.getName()).log(Level.SEVERE, "Error calling Gemini", e);
            response.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            writeJson(response, "I could not reach Gemini right now. Error: " + e.getMessage() + ". Please check your GEMINI_API_KEY in .env.");
        }
    }

    private String resolveEnvValue(String envName, String sysProp, String ctxParam) {
        String val = readFromDotEnv(envName);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }
        val = System.getenv(envName);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }
        val = System.getProperty(sysProp);
        if (val != null && !val.trim().isEmpty()) {
            return val.trim();
        }
        if (getServletContext() != null) {
            val = getServletContext().getInitParameter(ctxParam);
            if (val != null && !val.trim().isEmpty()) {
                return val.trim();
            }
        }
        return null;
    }

    private String readFromDotEnv(String keyName) {
        String[] candidates = new String[] {
            "d:\\World-trade-intelligence\\.env",
            "d:\\World-trade-intelligence\\Supplexio systems_final (3)\\Supplexio systems\\AxaltaWebApp\\.env",
            ".env"
        };
        for (String path : candidates) {
            File f = new File(path);
            if (!f.exists() || !f.isFile()) continue;
            try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String trimmed = line.trim();
                    if (trimmed.isEmpty() || trimmed.startsWith("#")) continue;
                    int eq = trimmed.indexOf('=');
                    if (eq <= 0) continue;
                    String k = trimmed.substring(0, eq).trim();
                    if (k.equals(keyName)) {
                        String v = trimmed.substring(eq + 1).trim();
                        if ((v.startsWith("\"") && v.endsWith("\"")) || (v.startsWith("'") && v.endsWith("'"))) {
                            v = v.substring(1, v.length() - 1).trim();
                        }
                        if (!v.isEmpty()) return v;
                    }
                }
            } catch (Exception ignored) {}
        }
        return null;
    }

    private String resolveModel() {
        String model = resolveEnvValue("GEMINI_MODEL", "gemini.model", "geminiModel");
        return (model == null || model.isEmpty()) ? DEFAULT_MODEL : model;
    }

    private JSONObject readRequestJson(HttpServletRequest request) throws Exception {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }
        if (body.length() == 0) return null;
        Object parsed = new JSONParser().parse(body.toString());
        return (parsed instanceof JSONObject) ? (JSONObject) parsed : null;
    }

    private String buildLiveContext(HttpServletRequest request, String currentPage) {
        StringBuilder ctx = new StringBuilder("\n\nLIVE PLATFORM & GLOBAL TRADE SNAPSHOT:\n");
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object uObj = session.getAttribute("user");
            Object sObj = session.getAttribute("supplier");
            if (uObj instanceof User) {
                User u = (User) uObj;
                ctx.append("- Signed-in Role: Buyer Portal (").append(u.getRole()).append(", user: ").append(u.getUsername()).append(")\n");
            } else if (sObj instanceof Supplier) {
                Supplier s = (Supplier) sObj;
                ctx.append("- Signed-in Role: Supplier Portal (").append(s.getName()).append(")\n");
            } else {
                ctx.append("- Signed-in Role: Public / Guest\n");
            }
        }
        if (currentPage != null && !currentPage.trim().isEmpty()) {
            ctx.append("- Current Page: ").append(currentPage.trim()).append("\n");
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            ctx.append("- Total Products: ").append(queryInt(conn, "SELECT COUNT(*) FROM products")).append("\n");
            ctx.append("- Total Inventory SKUs: ").append(queryInt(conn, "SELECT COUNT(*) FROM inventory")).append("\n");
            ctx.append("- Low-Stock Inventory Items: ").append(queryInt(conn, "SELECT COUNT(*) FROM inventory WHERE quantity <= min_threshold")).append("\n");
            ctx.append("- Active Suppliers: ").append(queryInt(conn, "SELECT COUNT(*) FROM suppliers WHERE status = 'ACTIVE'")).append("\n");
            ctx.append("- Total Reverse Auctions: ").append(queryInt(conn, "SELECT COUNT(*) FROM reverse_auctions")).append("\n");
            ctx.append("- Active Live Auctions: ").append(queryInt(conn, "SELECT COUNT(*) FROM reverse_auctions WHERE status = 'ACTIVE'")).append("\n");
            ctx.append("- Total Purchase Orders: ").append(queryInt(conn, "SELECT COUNT(*) FROM purchase_orders")).append("\n");
            ctx.append("- Settled Payments: ").append(queryInt(conn, "SELECT COUNT(*) FROM payments WHERE status = 'COMPLETED'")).append("\n");

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT ra.id, COALESCE(p.name, 'Lot') AS pname, ra.current_price, ra.required_quantity " +
                    "FROM reverse_auctions ra LEFT JOIN products p ON p.id = ra.product_id " +
                    "WHERE ra.status = 'ACTIVE' ORDER BY ra.id DESC LIMIT 5");
                 ResultSet rs = ps.executeQuery()) {
                StringBuilder lots = new StringBuilder();
                while (rs.next()) {
                    if (lots.length() > 0) lots.append("; ");
                    lots.append("#").append(rs.getLong("id")).append(" ").append(rs.getString("pname"))
                        .append(" (Qty: ").append(rs.getInt("required_quantity"))
                        .append(", Current L1: ₹").append(String.format("%.2f", rs.getDouble("current_price"))).append(")");
                }
                if (lots.length() > 0) {
                    ctx.append("- Live Auctions Now: ").append(lots).append("\n");
                }
            }
        } catch (Exception e) {
            ctx.append("- Database snapshot temporarily unavailable.\n");
        }

        // Check Flask 1D-ResNet Trade Intelligence API if running
        try {
            URL flaskUrl = new URL("http://127.0.0.1:5000/api/health");
            HttpURLConnection fconn = (HttpURLConnection) flaskUrl.openConnection();
            fconn.setConnectTimeout(600);
            fconn.setReadTimeout(600);
            if (fconn.getResponseCode() == 200) {
                ctx.append("- Global Trade Intelligence Engine (1D-ResNet + Yahoo Finance + World Bank Pink Sheet + FRED + UN Comtrade + DGFT/CBIC + NIRYAT): ONLINE on port 5000.\n");
            }
        } catch (Exception ignored) {
            ctx.append("- Global Trade Intelligence Engine: Integrated with 1D-ResNet multi-source forecasting on /inventory and /trade-intelligence.jsp.\n");
        }

        return ctx.toString();
    }

    private int queryInt(Connection conn, String sql) {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    @SuppressWarnings("unchecked")
    private String askGemini(String apiKey, String question, String liveContext) throws Exception {
        JSONObject payload = new JSONObject();

        JSONObject systemInstruction = new JSONObject();
        JSONArray systemParts = new JSONArray();
        JSONObject systemText = new JSONObject();
        systemText.put("text", PROJECT_GUIDE + liveContext);
        systemParts.add(systemText);
        systemInstruction.put("parts", systemParts);
        payload.put("systemInstruction", systemInstruction);

        JSONArray contents = new JSONArray();
        JSONObject userContent = new JSONObject();
        userContent.put("role", "user");
        JSONArray userParts = new JSONArray();
        JSONObject userText = new JSONObject();
        userText.put("text", question);
        userParts.add(userText);
        userContent.put("parts", userParts);
        contents.add(userContent);
        payload.put("contents", contents);

        JSONObject generationConfig = new JSONObject();
        generationConfig.put("temperature", 0.3);
        generationConfig.put("maxOutputTokens", 900);
        payload.put("generationConfig", generationConfig);

        URL url = new URL(String.format(GEMINI_ENDPOINT, resolveModel()));
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setConnectTimeout(15000);
        connection.setReadTimeout(30000);
        connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        connection.setRequestProperty("x-goog-api-key", apiKey);
        connection.setDoOutput(true);

        byte[] requestBody = payload.toJSONString().getBytes(StandardCharsets.UTF_8);
        try (OutputStream outputStream = connection.getOutputStream()) {
            outputStream.write(requestBody);
        }

        int status = connection.getResponseCode();
        BufferedReader reader = new BufferedReader(new InputStreamReader(
                status >= 200 && status < 300 ? connection.getInputStream() : connection.getErrorStream(),
                StandardCharsets.UTF_8));

        StringBuilder responseBody = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            responseBody.append(line);
        }

        if (status < 200 || status >= 300) {
            throw new IOException("Gemini API returned HTTP " + status + " - Response: " + responseBody.toString());
        }

        return extractAnswer(responseBody.toString());
    }

    private String extractAnswer(String responseBody) throws Exception {
        JSONObject root = (JSONObject) new JSONParser().parse(responseBody);
        JSONArray candidates = (JSONArray) root.get("candidates");
        if (candidates == null || candidates.isEmpty()) {
            return "I did not get a usable answer from Gemini. Please rephrase the question.";
        }

        JSONObject firstCandidate = (JSONObject) candidates.get(0);
        JSONObject content = (JSONObject) firstCandidate.get("content");
        JSONArray parts = content == null ? null : (JSONArray) content.get("parts");
        if (parts == null || parts.isEmpty()) {
            return "I did not get a usable answer from Gemini. Please rephrase the question.";
        }

        StringBuilder answer = new StringBuilder();
        for (Object part : parts) {
            if (part instanceof JSONObject && ((JSONObject) part).get("text") != null) {
                answer.append(((JSONObject) part).get("text").toString());
            }
        }

        return answer.length() == 0
                ? "I did not get a usable answer from Gemini. Please rephrase the question."
                : answer.toString();
    }

    @SuppressWarnings("unchecked")
    private void writeJson(HttpServletResponse response, String answer) throws IOException {
        JSONObject result = new JSONObject();
        result.put("answer", answer);
        response.getWriter().write(result.toJSONString());
    }
}
