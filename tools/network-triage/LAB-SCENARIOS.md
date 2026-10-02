# Controlled triage experiments

Status: planned, not executed. Use a disposable Windows VM and test web service. Record a healthy baseline and save the original settings before each change. Keep the management/remote-access path independent of the test. Restore each fault before starting the next.

| Scenario | Controlled change | Expected observations | Restore |
| --- | --- | --- | --- |
| Healthy baseline | None; known service listening with valid TLS | Resolution and TCP pass; HTTP expected response | None |
| DNS failure | Use a deliberately nonexistent hostname under `.invalid` | Resolution Attention; TCP/ICMP/HTTP skipped | Return to correct hostname |
| Blocked service port | Add a temporary scoped inbound block on the disposable server for its test port and client | DNS still passes; TCP Attention; ping may still pass | Remove only the temporary rule; retest baseline |
| Service unavailable | Stop only the disposable test web service | DNS passes; TCP fails if nothing else listens on that port | Restart test service; retest baseline |
| HTTP access restriction | Configure disposable endpoint to return 403 | TCP passes; HTTP Attention with status 403 | Restore original endpoint configuration |

The block and stopped-service cases deliberately show that similar client observations can have different causes. Compare server listener state and firewall configuration to establish the cause. Do not label client-side TCP failure as proof of firewall blocking.

## Evidence record — complete after execution

- Date/time and tool commit:
- Fictional public labels for client/server:
- Baseline result:
- Hypothesis:
- Exact lab change and saved rollback:
- Expected result:
- Observed result (sanitised):
- Additional evidence used to confirm cause:
- Restored baseline result:
- Limitations and lessons learned:

For a short demonstration, show baseline → induced fault → tool evidence → confirm cause → restore → rerun. Explain what the tool cannot establish from the client alone. Publish recreated output with documentation addresses rather than raw live reports.
