## [1.0.2](https://github.com/islamelkadi/terraform-aws-lambda/compare/v1.0.1...v1.0.2) (2026-03-10)


### Bug Fixes

* add CKV_TF_1 suppression for external module metadata ([3bec025](https://github.com/islamelkadi/terraform-aws-lambda/commit/3bec0252ff039a10775adcfa394753c6d90e2e94))
* add skip-path for .external_modules in Checkov config ([2d612b4](https://github.com/islamelkadi/terraform-aws-lambda/commit/2d612b43fded9f57e88a958ffc3afc684741692b))
* address Checkov security findings ([8af67fc](https://github.com/islamelkadi/terraform-aws-lambda/commit/8af67fcb6f7aee5f1b1cd25adc2e5f53a692e93f))
* correct .checkov.yaml format to use simple list instead of id/comment dict ([fc7b8bc](https://github.com/islamelkadi/terraform-aws-lambda/commit/fc7b8bcb414e706b23bd05f44bfe81cdd523de1b))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([af43393](https://github.com/islamelkadi/terraform-aws-lambda/commit/af433939c226a413b2cd348a67e019652bcd8f48))
* update workflow path reference to terraform-security.yaml ([2d61126](https://github.com/islamelkadi/terraform-aws-lambda/commit/2d61126863cd7ef50906c5b8471118566b63321e))


### Documentation

* add GitHub Actions workflow status badges ([e4b8ba4](https://github.com/islamelkadi/terraform-aws-lambda/commit/e4b8ba40046ca8727059e5e1b9841a5e2e732b4f))
* add security scan suppressions section to README ([d274854](https://github.com/islamelkadi/terraform-aws-lambda/commit/d274854321c4125b5cd30e7d24dbf88e30c06058))

## [1.0.1](https://github.com/islamelkadi/terraform-aws-lambda/compare/v1.0.0...v1.0.1) (2026-03-08)


### Code Refactoring

* enhance examples with real infrastructure and improve code quality ([cd0a8d0](https://github.com/islamelkadi/terraform-aws-lambda/commit/cd0a8d0657033b765160a57a0421d62986cad19d))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - Lambda Terraform module

### Features

* First publish - Lambda Terraform module ([e20ed90](https://github.com/islamelkadi/terraform-aws-lambda/commit/e20ed90b66fa7912496595c96208cebc77fc1078))
