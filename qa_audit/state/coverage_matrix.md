# Coverage Matrix

| Area | Discovered | Code Analyzed | Runtime Tested | Status |
|------|-----------|---------------|----------------|--------|
| Home Dashboard | 5 screens | 5/5 | 1/5 | Partial runtime |
| Habits | 10 screens | 10/10 | 0/10 | Code only |
| Sleep | 5 screens | 5/5 | 0/5 | Code only (Pro-gated) |
| Gamification | 5 screens | 5/5 | 0/5 | Code only |
| Social | 6 screens | 6/6 | 0/6 | Code only (Coming Soon) |
| Profile | 4 screens | 4/4 | 0/4 | Code only |
| Premium | 3 screens | 3/3 | 0/3 | Code only |
| Notifications | 3 screens | 3/3 | 0/3 | Code only |
| Settings | 6 screens | 6/6 | 0/6 | Code only |
| Analytics | 5 screens | 5/5 | 0/5 | Code only |
| Onboarding | 6 screens | 6/6 | 0/6 | Code only |
| Auth | 3 screens | 3/3 | 0/3 | Code only (dead code) |
| Discovery | 3 screens | 3/3 | 0/3 | Code only |
| Models | 8 models | 8/8 | N/A | Full |
| Services | 5 services | 5/5 | N/A | Full |
| Components | ~25 files | 25/25 | N/A | Full |

**Total: ~63 screens discovered, 63/63 code-analyzed, 1/63 runtime-verified**

## Gaps
- Runtime UI interaction blocked by simulator API limitations (no tap command, no accessibility access)
- Interactive flows (create, edit, delete, navigate) verified by code tracing only
- StoreKit IAP not testable without StoreKit configuration file
