# Contributing to Azure Networking Labs

Thank you for your interest! Contributions that improve the learning experience are welcome.

## Types of Contributions

- **Bug fixes** — incorrect Bicep, broken validation scripts, wrong cost estimates
- **Content improvements** — clearer explanations, better exercises, additional learning objectives
- **New modules** — additional Azure networking topics (VPN Gateway, ExpressRoute, Private Endpoints, etc.)
- **Fault labs** — new broken-environment scenarios

## Module Standards

Each module must include:

| File | Purpose |
|------|---------|
| `README.md` | Learning guide with objectives, walkthrough, and exercises |
| `deploy.bicep` | Bicep template — well-commented for learning |
| `validate.ps1` | Validation script that outputs an unlock code on success |
| `cleanup.ps1` | Removes all module resources |
| `cost-estimate.md` | Honest cost breakdown |

## Unlock Codes

Unlock codes follow the pattern: `ANL-MOD##-KEYWORD-COMPLETE`

The code in `validate.ps1` must match the code in `portal/app.js`. Update both when adding or modifying a module.

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/add-module-08`)
3. Test your Bicep template end-to-end in a real Azure subscription
4. Run your validate.ps1 and cleanup.ps1 to verify they work
5. Update `portal/app.js` if adding a new module
6. Submit a PR with a clear description of what the module teaches

## Questions?

Open a GitHub Issue for questions, suggestions, or to discuss a new module idea before building it.
