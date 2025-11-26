# Sysdig Secure for Cloud in Google

Terraform module that deploys the Sysdig Secure for Cloud stack in GCP.

With Modular Onboarding, introducing the following design and install structure for `terraform-google-secure`:

* **[Onboarding]**: It onboards a GCP Project or Organization for the first time to Sysdig Secure for Cloud, and collects
inventory and organizational hierarchy in the given GCP Organization. Managed through `onboarding` module. <br/>

Provides unified threat-detection, compliance, forensics and analysis through these major components:

* **[CSPM](https://docs.sysdig.com/en/docs/sysdig-secure/posture/)**: It evaluates periodically your cloud configuration, using Cloud Custodian, against some benchmarks and returns the results and remediation you need to fix. Managed through `config-posture` module. <br/>

* **[CIEM](https://docs.sysdig.com/en/docs/sysdig-secure/posture/identity-and-access/)**: Permissions and Entitlements management. Managed through `config-posture` module. <br/>

* **[CDR (Cloud Detection and Response)]((https://docs.sysdig.com/en/docs/sysdig-secure/threats/activity/events-feed/))**: It sends periodically the Audit Logs collected from a GCP project/organization to Sysdig's systems, this by collecting them in a PubSub topic through a Sink and then sending them through a `PUSH` integration. Managed through `pub-sub` integrations module. <br/>

For other Cloud providers check: [AWS](https://github.com/sysdiglabs/terraform-aws-secure)

<br/>

## Modules

### Feature modules

These are independent feature modules which deploy and manage all the required Cloud resources and Sysdig resources
for the respective Sysdig features. They manage both, onboarding a single GCP Project or a GCP Organization to Sysdig Secure for Cloud.

`onboarding`, `config-posture`, `agentless-scan` and `vm-workload-scanning` are independent feature modules.

### Integrations

The modules under `integrations` are feature agnostic modules which deploy and manage all the required Cloud resources and Sysdig resources for shared Sysdig integrations. That is to say, one or more Sysdig features can be enabled by installing an integration.

These modules manage both, onboarding a single GCP Project or a GCP Organization to Sysdig Secure for Cloud.

`pub-sub` is an integration module.

## Examples and usage

The modules in this repository can be installed on a single GCP project, or on an entire GCP Organization, or organizational folders within the org.

The `test` directory has sample `examples` for all these module deployments i.e under `modular_single_project`,  or `modular_organization` sub-folders.

For example, to onboard a single GCP project, with CSPM and Basic CIEM enabled, with modular installation :-
1. Run the terraform snippet under `test/examples/modular_single_project/onboarding_with_posture.tf` with
   the appropriate attribute values populated.
2. This will install the `onboarding` module, which will also create a Cloud Account on Sysdig side.
3. It will also install the `config-posture` module, which will also install cloud resources as well as Sysdig resources
   for successfully running CSPM and Basic Identity scans.
4. On Sysdig side, you will be able to see the Cloud account onboarded with required components, and CSPM & Basic CIEM features installed and enabled.

To run this example you need have your GCP auth login via gcloud CLI and execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

Notice that:
* This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore
* All created resources will be created within the tags `product:sysdig-secure-for-cloud`, within the resource-group `sysdig-secure-for-cloud`

<br/>

## Organizational Install Configurations

There are four new parameters to configure organizational deployments on the cloud for Sysdig Secure for Cloud :-
1. `include_folders` - List of GCP Organizational Folders to deploy the Sysdig Secure for Cloud resources in.
2. `exclude_folders` - List of GCP Organizational Folders to exclude deploying the Sysdig Secure for Cloud resources in.
3. `include_projects` - List of GCP Projects to deploy the Sysdig Secure for Cloud resources in.
4. `exclude_projects` - List of GCP Projects to exclude deploying the Sysdig Secure for Cloud resources in.

**DEPRECATION NOTICE**: module variable `management_group_ids` has been DEPRECATED and is no longer supported. Please work with Sysdig to migrate your Terraform installs to use `include_folders` instead to achieve the same deployment outcome.

**Note**: The modules under `modules/services/` folder are legacy installs and soon to be deprecated. Those modules are no longer used for Onboarding. Please use the corresponding feature modules as mentioned in `## Modules` section above for Modular Onboarding. It is the recommended form of Onboarding.

<br/>

## Best practices

For contributing to existing modules or adding new modules, below are some of the best practices recommended :-
* Module names referred and used in deployment snippets should be consistent with those in their source path.
* A module can fall into one of two categories - feature module or an integrations module.
* Every user-facing deployment snippet will,
  - at the top level first call the feature module or integrations module from this repo. These modules deploy corresponding cloud resources and Sysdig component resources.
  - the corresponding feature resource will be added as the last block and enabled from the module installed component resource reference.
  See sample deployment snippets in `test/examples` for more.
* integrations modules are shared and could enable multiple features. Hence, one should be careful with changes to them.
* Module naming follows the pattern with "-" , resource and variable naming follows the pattern with "_".

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
