package com.ledgerline.config;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PasswordEncoderTests {

	@Test
	void bcryptEncodesAndVerifiesWithoutRetainingThePlaintext() {
		var encoder = new BCryptPasswordEncoder();
		String password = "correct horse battery staple";
		String hash = encoder.encode(password);

		assertNotEquals(password, hash);
		assertTrue(encoder.matches(password, hash));
	}
}
