package com.bbc.cairtech.utils;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.bibleClub.BibleClub;
import com.bbc.cairtech.model.member.MemberEntity;
import com.bbc.cairtech.model.user.Incharge;
import com.bbc.cairtech.model.user.User;
import com.fasterxml.jackson.databind.ObjectMapper;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;

@Service
public class JwtUtils {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ObjectMapper objectMapper;

    @Value("${spring.secretKey}")
    private String secret;

    @Value("${spring.expiration}")
    private long expiration;

    private String secretKey;

    private Key key;

    @PostConstruct
    public void init() {
        this.secretKey = passwordEncoder.encode(secret);
        this.key = Keys.hmacShaKeyFor(secretKey.getBytes());
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> toMap(Object entity) {
        Map<String, Object> map = objectMapper.convertValue(entity, Map.class);
        map.remove("password");
        return map;
    }

    public String generateUserToken(User user, List<String> roles) {
        Map<String, Object> claims = toMap(user);
        claims.put("roles", roles);
        return createToken(claims);
    }

    public String generateMemberToken(User user, MemberEntity member, List<String> roles) {
        Map<String, Object> claims = toMap(user);
        Map<String, Object> memberMap = toMap(member);
        // Renommer pour eviter la collision avec User.status
        if (memberMap.containsKey("status")) {
            memberMap.put("memberStatus", memberMap.remove("status"));
        }
        claims.putAll(memberMap);
        claims.put("roles", roles);
        return createToken(claims);
    }

    public String generateInchargeToken(User user, MemberEntity member, Incharge incharge, List<String> roles) {
        Map<String, Object> claims = toMap(user);
        Map<String, Object> memberMap = toMap(member);
        if (memberMap.containsKey("status")) {
            memberMap.put("memberStatus", memberMap.remove("status"));
        }
        claims.putAll(memberMap);
        claims.putAll(toMap(incharge));
        claims.put("roles", roles);
        return createToken(claims);
    }

    public String generateBBCToken(BibleClub bbc) {
        Map<String, Object> claims = toMap(bbc);
        return createToken(claims);
    }

    private String createToken(Map<String, Object> claims) {
        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(key)
                .compact();
    }
}
