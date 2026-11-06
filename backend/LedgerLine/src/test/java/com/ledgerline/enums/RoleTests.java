package com.ledgerline.enums;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;

class RoleTests {

	@Test
	void exposesOnlyTheDefinedDayOneRoles() {
		assertArrayEquals(
				new Role[]{Role.ADMIN, Role.ACCOUNT_HOLDER, Role.AUDITOR},
				Role.values());
	}
}
