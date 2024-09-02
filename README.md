# Sysdig Secure for Cloud in Google

Terraform module that deploys the Sysdig Secure for Cloud stack in GCP.

Provides unified threat-detection, compliance, forensics and analysis through these major components:

* **[CSPM](https://docs.sysdig.com/en/docs/sysdig-secure/posture/)**: It evaluates periodically your cloud configuration, using Cloud Custodian, against some benchmarks and returns the results and remediation you need to fix. Managed through `service-principal` module. <br/>

* **[CIEM](https://docs.sysdig.com/en/docs/sysdig-secure/posture/identity-and-access/)**: Permissions and Entitlements management. Managed through `service-principal` module. <br/>

* **[CDR (Cloud Detection and Response)]((https://docs.sysdig.com/en/docs/sysdig-secure/threats/activity/events-feed/))**: It sends periodically the Audit Logs collected from a GCP project/organization to Sysdig's systems, this by collecting them in a PubSub topic through a Sink and then sending them through a `PUSH` integration. Managed through `webhook-datasource` module. <br/>

For other Cloud providers check: [AWS](https://github.com/draios/terraform-aws-secure-for-cloud)

