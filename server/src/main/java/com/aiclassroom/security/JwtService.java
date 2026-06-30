package com.aiclassroom.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
    private final SecretKey key;

    public JwtService(@Value("${app.jwt-secret}") String secret) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String createToken(String subject, String role) {
        var now = Instant.now();
        return Jwts.builder()
            .subject(subject)
            .claim("role", role)
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plusSeconds(60L * 60L * 24L * 7L)))
            .signWith(key)
            .compact();
    }

    public String subject(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload().getSubject();
    }

    public String role(String token) {
        return String.valueOf(Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload().get("role"));
    }
}
