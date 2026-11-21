package com.axaltacoating.servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

@WebServlet(name = "AiChatServlet", urlPatterns = {"/ai-chat"})
public class AiChatServlet extends HttpServlet {
    private static final String DEFAULT_MODEL = "gemini-2.5-flash";
    private static final String GEMINI_ENDPOINT =
            "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent";

    private static final String PROJECT_GUIDE =
            "You are Supplexio Assistant, a concise in-app guide for the Supplexio procurement system. "
            + "Supplexio is a Java JSP/Servlet web app for procurement, reverse auctions, supplier onboarding, "
            + "inventory visibility, purchase orders, payments, and todo tracking. "
            + "Key user journeys: buyers log in from Buyer Workspace Login, use the internal dashboard, manage products, "
            + "manage suppliers, create reverse auctions, invite suppliers, monitor bids, award winners, generate purchase orders, "
            + "track deliveries, and handle payments. Suppliers use Supplier Signup or Supplier Login, view live auctions, bid, "
            + "message buyers, and manage awarded purchase orders. "
            + "Important routes: /home shows the public launch dashboard; /home?action=workspace shows the buyer dashboard; "
            + "/login.jsp is buyer login; /auction manages reverse auctions; /product manages products; /supplier manages suppliers; "
            + "/inventory manages inventory; /payment manages payments; /todo manages tasks; /bidding is the supplier portal. "
            + "Always guide users step by step inside this project. If a question asks for private data, credentials, API keys, "
            + "or database secrets, refuse briefly and suggest a safe alternative. If you are unsure, explain where in the app "
            + "the user should check instead of inventing values. Keep answers short, practical, and friendly.";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        String apiKey = resolveApiKey();
        if (apiKey == null || apiKey.trim().isEmpty()) {
            writeJson(response, "Gemini is not configured yet. Set GEMINI_API_KEY on the server and restart the app.");
            return;
        }

        String question = null;
        try {
            question = readQuestion(request);
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
            String answer = askGemini(apiKey, question.trim());
            writeJson(response, answer);
        } catch (Exception e) {
            Logger.getLogger(AiChatServlet.class.getName()).log(Level.SEVERE, "Error calling Gemini", e);
            response.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            writeJson(response, "I could not reach Gemini right now. Error: " + e.getMessage() + ". Please try again in a moment.");
        }
    }

    private String resolveApiKey() {
        String key = System.getenv("GEMINI_API_KEY");
        if (key == null || key.trim().isEmpty()) {
            key = System.getProperty("gemini.api.key");
        }
        if ((key == null || key.trim().isEmpty()) && getServletContext() != null) {
            key = getServletContext().getInitParameter("geminiApiKey");
        }
        return key;
    }

    private String resolveModel() {
        String model = System.getenv("GEMINI_MODEL");
        if (model == null || model.trim().isEmpty()) {
            model = System.getProperty("gemini.model");
        }
        if ((model == null || model.trim().isEmpty()) && getServletContext() != null) {
            model = getServletContext().getInitParameter("geminiModel");
        }
        return model == null || model.trim().isEmpty() ? DEFAULT_MODEL : model.trim();
    }

    private String readQuestion(HttpServletRequest request) throws Exception {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }

        if (body.length() == 0) {
            return request.getParameter("message");
        }

        Object parsed = new JSONParser().parse(body.toString());
        if (!(parsed instanceof JSONObject)) {
            return null;
        }
        Object message = ((JSONObject) parsed).get("message");
        return message == null ? null : message.toString();
    }

    private String askGemini(String apiKey, String question) throws Exception {
        JSONObject payload = new JSONObject();

        JSONObject systemInstruction = new JSONObject();
        JSONArray systemParts = new JSONArray();
        JSONObject systemText = new JSONObject();
        systemText.put("text", PROJECT_GUIDE);
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
        generationConfig.put("maxOutputTokens", 500);
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

    private void writeJson(HttpServletResponse response, String answer) throws IOException {
        JSONObject result = new JSONObject();
        result.put("answer", answer);
        response.getWriter().write(result.toJSONString());
    }
}
