package com.axaltacoating.util;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Verifies Google ID tokens with Google's tokeninfo endpoint.
 */
public final class GoogleTokenVerifier {

    private GoogleTokenVerifier() {
    }

    public static GoogleProfile verify(String idToken, String expectedAudience) throws IOException {
        if (idToken == null || idToken.trim().isEmpty()) {
            throw new IOException("Missing Google credential");
        }

        String encodedToken = URLEncoder.encode(idToken, StandardCharsets.UTF_8.name());
        URL url = new URL("https://oauth2.googleapis.com/tokeninfo?id_token=" + encodedToken);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(10000);
        connection.setReadTimeout(10000);

        int statusCode = connection.getResponseCode();
        if (statusCode != HttpURLConnection.HTTP_OK) {
            throw new IOException("Google token verification failed with status " + statusCode);
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
            JsonObject payload = JsonParser.parseReader(reader).getAsJsonObject();

            GoogleProfile profile = new GoogleProfile();
            profile.setGoogleSubject(getAsString(payload, "sub"));
            profile.setEmail(getAsString(payload, "email"));
            profile.setName(getAsString(payload, "name"));
            profile.setAudience(getAsString(payload, "aud"));
            profile.setEmailVerified("true".equalsIgnoreCase(getAsString(payload, "email_verified")));

            if (expectedAudience != null && !expectedAudience.trim().isEmpty()
                    && !expectedAudience.equals(profile.getAudience())) {
                throw new IOException("Google token audience mismatch");
            }

            if (!profile.isEmailVerified()) {
                throw new IOException("Google account email is not verified");
            }

            return profile;
        } finally {
            connection.disconnect();
        }
    }

    private static String getAsString(JsonObject payload, String key) {
        return payload.has(key) && !payload.get(key).isJsonNull()
            ? payload.get(key).getAsString()
            : null;
    }

    public static class GoogleProfile {
        private String googleSubject;
        private String email;
        private String name;
        private String audience;
        private boolean emailVerified;

        public String getGoogleSubject() {
            return googleSubject;
        }

        public void setGoogleSubject(String googleSubject) {
            this.googleSubject = googleSubject;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getAudience() {
            return audience;
        }

        public void setAudience(String audience) {
            this.audience = audience;
        }

        public boolean isEmailVerified() {
            return emailVerified;
        }

        public void setEmailVerified(boolean emailVerified) {
            this.emailVerified = emailVerified;
        }
    }
}
