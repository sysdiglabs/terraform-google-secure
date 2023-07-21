# Sysdig Secure for Cloud in Google

Terraform module that deploys the Sysdig Secure for Cloud stack in GCP.

Provides unified threat-detection, compliance, forensics and analysis through these major components:

CSPM: It evaluates periodically your cloud configuration, using Cloud Custodian, against some benchmarks and returns the results and remediation you need to fix. Managed through trust-relationship module.

For other Cloud providers check: AWS, Azure



## Common requirements

* [ ] *QA*
* [ ] Devops infra (github repository, quay repository, Jenkins jobs, etc.)

## Common project pitfalls

Use this list to verify which of the common pitfalls apply to the project and plan in advance. Usually the following issues appear in most projects:

* [ ] **Support for On-Prem and multi-regions**. URLs should be customizable and acknowledge some differences between default SaaS and other regions / On-Prem, like the /secure prefix for Secure UI.
* [ ] **Invalid TLS certificates**. Many On-Prem installs have invalid TLS certificates. Provide an option to just ignore the certificate, or a way to inject a custom CA or trusted certificate chain.
* [ ] **Proxy support**. Many customers have limited connectivity, and their On-Prem installation, or more commonly their SaaS account, must be reached through a proxy. Honor the default *http_proxy*, *no_proxy* environment variables or provide ways to configure proxy support.
* [ ] **Airgapped environments**. Some customers cannot pull public images from the Internet and rely on internal registries. Provide some way to use the application in this kind of environments (usually allow customizing registry/repository/image in Helm charts, don't hardcode image names, and update instructions on the images that need to be pushed to the internal registry).
