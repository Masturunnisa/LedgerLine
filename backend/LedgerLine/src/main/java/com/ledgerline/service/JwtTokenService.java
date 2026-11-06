package com.ledgerline.service;

import com.ledgerline.dto.TokenResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.Duration;
import java.util.List;

@Service
public class JwtTokenService {

	private final JwtEncoder jwtEncoder;
	private final String issuer;
	private final Duration tokenTtl;

	public JwtTokenService(
			JwtEncoder jwtEncoder,
			@Value("${app.jwt.issuer}") String issuer,
			@Value("${app.jwt.ttl}") Duration tokenTtl) {
		this.jwtEncoder = jwtEncoder;
		this.issuer = issuer;
		this.tokenTtl = tokenTtl;
	}

	public TokenResponse issueToken(String subject, List<String> roles) {
		Instant issuedAt = Instant.now();
		JwtClaimsSet claims = JwtClaimsSet.builder()
				.issuer(issuer)
				.issuedAt(issuedAt)
				.expiresAt(issuedAt.plus(tokenTtl))
				.subject(subject)
				.claim("roles", roles)
				.build();

		String token = jwtEncoder.encode(JwtEncoderParameters.from(
				JwsHeader.with(org.springframework.security.oauth2.jose.jws.MacAlgorithm.HS256).build(),
				claims)).getTokenValue();
		return new TokenResponse(token, "Bearer", tokenTtl.toSeconds());
	}
}
