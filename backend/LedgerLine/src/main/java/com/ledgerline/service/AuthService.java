package com.ledgerline.service;

import com.ledgerline.dto.LoginRequest;
import com.ledgerline.dto.TokenResponse;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

	private final AuthenticationManager authenticationManager;
	private final JwtTokenService jwtTokenService;

	public AuthService(AuthenticationManager authenticationManager, JwtTokenService jwtTokenService) {
		this.authenticationManager = authenticationManager;
		this.jwtTokenService = jwtTokenService;
	}

	public TokenResponse login(LoginRequest request) {
		Authentication authentication = authenticationManager.authenticate(
				UsernamePasswordAuthenticationToken.unauthenticated(
						request.email().trim(), request.password()));
		var roles = authentication.getAuthorities().stream()
				.map(authority -> authority.getAuthority().replaceFirst("^ROLE_", ""))
				.toList();
		return jwtTokenService.issueToken(authentication.getName(), roles);
	}
}
