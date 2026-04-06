package dev.cyphera.snowflake;

/**
 * Cyphera UDFs for Snowflake.
 *
 * Snowflake Java UDFs are plain static methods that take and return String.
 * No Snowflake SDK dependency is needed.
 *
 * Currently uses dummy (reversible shift) encryption as a placeholder.
 * Will be replaced with real FF1 FPE when cyphera-java is published to Maven.
 */
public final class CypheraUDF {

    private CypheraUDF() {}

    // ── Policy-based API (the primary interface) ──

    public static String cyphera_protect(String policyName, String value) {
        PolicyEntry policy = PolicyLoader.getInstance().getPolicy(policyName);
        if (policy == null) {
            return "[unknown policy: " + policyName + "]";
        }
        return DummyCipher.encrypt(value, policy.alphabet(), policy.keyMaterial());
    }

    public static String cyphera_unprotect(String policyName, String value) {
        PolicyEntry policy = PolicyLoader.getInstance().getPolicy(policyName);
        if (policy == null) {
            return "[unknown policy: " + policyName + "]";
        }
        return DummyCipher.decrypt(value, policy.alphabet(), policy.keyMaterial());
    }

    // ── Direct engine API (for testing / simple integrations) ──

    public static String cyphera_ff1_encrypt(String value, String keyHex, String alphabet) {
        return DummyCipher.encrypt(value, alphabet, keyHex);
    }

    public static String cyphera_ff1_decrypt(String value, String keyHex, String alphabet) {
        return DummyCipher.decrypt(value, alphabet, keyHex);
    }
}
