# EXP-001 — Validate Astra client-certificate mTLS enforcement

**Status:** Validated  
**Date:** 2026-10-03  
**Tags:** `experiment`, `security`, `identity`, `containers`

## Question

Does the Astra reverse-proxy path allow a trusted endpoint presenting an Astra-issued client certificate while rejecting a client that does not present one?

## Hypothesis

If Nginx Proxy Manager is correctly configured with the Astra client-CA trust bundle and client verification enabled, a browser presenting a valid Astra client certificate should reach the backend application, while a request that does not present a client certificate should be rejected before backend access.

## Environment

Sanitised test environment:

- Raspberry Pi 5 running Docker;
- Nginx Proxy Manager as the reverse proxy;
- Astra Root CA and Astra Internal Issuing CA;
- one Windows administrator endpoint with a unique client certificate;
- a dedicated private DNS name and proxy host used only for the test;
- Homepage used as the harmless backend application.

Exact private addresses, exact internal test hostname, private keys and certificate export files are intentionally omitted.

## Safety / scope boundary

The test used a dedicated proxy host rather than modifying existing administration or portal endpoints. Existing normal HTTPS proxy hosts were left unchanged. A direct management path remained available throughout the test.

## Variables and measurements

| Item | Definition |
| --- | --- |
| Independent variable | Whether the client presents the Astra-issued client certificate |
| Dependent measure | HTTP/application access result |
| Controls | Same proxy host, backend application, server-side TLS certificate and network path |

## Acceptance criteria

- The reverse proxy configuration passes Nginx syntax validation.
- The browser can present the Astra client certificate and reach the backend.
- A request with client-certificate use disabled is rejected.
- The negative result occurs before successful backend access.

## Procedure

1. Validate the Astra client-CA bundle is available to the reverse proxy.
2. Configure the dedicated proxy host to require client-certificate verification.
3. Confirm the generated Nginx configuration contains the expected client-certificate directives.
4. Run an Nginx configuration syntax test.
5. Browse to the test endpoint from the trusted Windows endpoint and present the Astra client certificate.
6. Confirm the backend application loads.
7. Send a second request using a client that explicitly does not automatically present the Windows client certificate.
8. Record the returned HTTP status.

## Results

| Test | Observed result | Status |
| --- | --- | --- |
| Nginx syntax validation | Configuration test successful | Passed |
| Positive client-cert test | Browser prompted for the Astra device certificate and backend loaded | Passed |
| Negative no-cert test | HTTP 400 | Passed |

During the positive test, the backend initially returned host-validation failure because the dedicated test hostname was not yet in the backend application's allowed-host list. After adding the test hostname to the application configuration and recreating the container, the browser test passed. This was an application-layer issue rather than a failure of the client-certificate handshake.

## Interpretation

The positive and negative results together show that the test proxy was enforcing client-certificate authentication. The successful browser test shows a valid Astra-issued client certificate can pass the mTLS gate. The HTTP 400 result without a certificate shows that normal HTTPS access alone was insufficient for this path.

The host-validation issue also demonstrated that mTLS success does not imply the downstream application will accept the request; reverse-proxy trust and application host policy are separate controls.

## Limitations

- Only one trusted Windows endpoint was validated in this run.
- The experiment does not validate certificate revocation.
- The test does not prove all browsers, operating systems or applications will behave identically.
- The test proxy used a non-critical backend and does not prove that every administration service can be protected without usability or recovery issues.
- Certificate renewal and automated enrolment were outside scope.

## Evidence

Public-safe summaries are recorded in:

- [Validation and Evidence Register](../../validation.md)
- [Raspberry Pi Operations and Recovery](../../raspberry-pi-operations.md)
- [2026-10-03 — Astra PKI and device trust Phase 1](../entries/2026-10-03-astra-pki-device-trust-phase-1.md)

## Follow-up

Repeat the positive test with additional trusted devices during Phase 2, then use the same acceptance pattern before selectively enabling mTLS on sensitive administration endpoints.
