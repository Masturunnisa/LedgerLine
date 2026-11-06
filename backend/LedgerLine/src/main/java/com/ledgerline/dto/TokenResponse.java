package com.ledgerline.dto;

public record TokenResponse(String accessToken, String tokenType, long expiresIn) {
}
