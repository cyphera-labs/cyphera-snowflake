package io.cyphera.snowflake;

import io.cyphera.Cyphera;

/**
 * Cyphera UDFs for Snowflake.
 *
 * Snowflake Java UDFs are plain static methods that take and return String.
 * No Snowflake SDK dependency is needed.
 */
public final class CypheraUDF {

    private CypheraUDF() {}

    private static final Cyphera CLIENT = CypheraLoader.getInstance();

    public static String cyphera_protect(String policyName, String value) {
        try { return CLIENT.protect(value, policyName); }
        catch (Exception e) { return "[error: " + e.getMessage() + "]"; }
    }

    public static String cyphera_access(String protectedValue) {
        try { return CLIENT.access(protectedValue); }
        catch (Exception e) { return "[error: " + e.getMessage() + "]"; }
    }

    public static String cyphera_access(String policyName, String protectedValue) {
        try { return CLIENT.access(protectedValue, policyName); }
        catch (Exception e) { return "[error: " + e.getMessage() + "]"; }
    }
}
