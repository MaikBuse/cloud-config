<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/MaikBuse/cloud-config">
    <img src="https://maikbuse.com/logo.svg" alt="Logo" width="150" height="150">
  </a>

<h3 align="center">Cloud Config</h3>

  <p align="center">
    The configuration of my cloud infrastructure
    <br />
    <br />
    <a href="https://github.com/MaikBuse/cloud-config/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/MaikBuse/cloud-config/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#troubeshooting">Troubeshooting</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

This repository contains the infrastructure as code (IaC) for deploying and managing a robust Kubernetes cluster hosted on Hetzner Cloud. The infrastructure is primarily written in Terraform, which orchestrates the setup and provisioning of all cloud resources, with a focus on the Kubernetes cluster as the central resource. For the k8s cluster, this repository is highly reliant on the [kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner) module. Make sure to familiarize yourself with the documentation before trying to deploy this concrete implementation.

- Kubernetes Cluster: Leveraging Hetzner Cloud, the Kubernetes environment is configured to support scalable and resilient applications.
- Deployment with ArgoCD: Applications are deployed using ArgoCD, utilizing Helm charts for efficient management and versioning of all Kubernetes manifests.
- Secure Access: Access to the cluster is streamlined and secured using Tailscale, ensuring a private and safe connection environment.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Terraform][Terraform]][Terraform-url]
* [![Kubernetes][Kubernetes]][Kubernetes-url]
* [![ArgoCD][ArgoCD]][Argo-url]
* [![Helm][Helm]][Helm-url]
* [![Tailscale][Tailscale]][Tailscale-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

You should have following applications and accounts prepared:

Applications (cli)

- terraform
- kubectl

Accounts

- hetzner
- tailscale

### Installation

1. Clone the repository

   ```sh
   git clone https://github.com/MaikBuse/cloud-config.git
   ```

2. Follow the instructions on [kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner) for the initial setup
3. Initialize terraform and download dependencies

   ```sh
   terraform init
   ```

4. Copy `*.auto.tfvars.example` files and set all variables
5. Create a `github_app_argocd_private_key` file in the root directory and set the private key of the github argocd app
6. Plan and apply the deployment

   ```sh
   terraform plan
   terraform apply --auto-approve
   ```

7. Copy folder `secret-examples` to `secrets` with `cp -r secret-examples secrets/` and fill out the values 
8. Execute `./seal-secrets.sh` in order to seal the secrets. You might have to add permissions with `chmod +x ./seal-secrets.sh`
9. Commit and push the sealed secrets
10. Manually sync the tailscale application on the control plane machine:

``` bash
kubectl patch applications.argoproj.io tailscale-operator --type='json' -p='[{"op": "add", "path": "/spec/operation", "value": {"initiatedBy": {"username": "user"}, "sync": {"syncStrategy": {"hook": {}}}}}]' -n argocd
```

11. Change the hostname of the kubernetes-tailscale-operator-machine from `tailscale-operator` to `hetzner-kube-api` and run `tailscale configure kubeconfig hetzner-kube-api` so that you can use tooling from your local machine to manage the k8s cluster
12. Use port forwarding to access the argocd web-ui and proceed to sync all applications with regard to their sync wave order
12. Follow this [guide](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/) to setup keycloak auth with argocd and patch the argocd-secret with the just created api-key:

``` sh
kubectl patch secret argocd-secret -n argocd -p '{"data":{"oidc.keycloak.clientSecret":"BASE64-ENCODED-API-KEY"}}' --type=merge
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

Here are a few commands that should definitely come in handy when working with the setup.

- Encode a string to base64
``` sh
echo -n '83083958-8ec6-47b0-a411-a8c55381fbd2' | base64
```

- Use SSH to login to a control plane node

``` sh
ssh root@<control-plane-ip> -i /path/to/private_key -o StrictHostKeyChecking=no
```

- Setup kubeconfig using tailscale

``` sh
tailscale configure kubeconfig hetzner-kube-api
```

- Use k9s with non default kubeconfig

``` bash
k9s --kubeconfig /path/to/your/kubeconfig.yaml
```

- or kubectl

``` bash
kubectl --kubeconfig=/path/to/your/kubeconfig.yaml get nodes
```

- Retrieve the initial password of ArgoCD

The default username is admin and the password are auto generated and stored
as clear text. You can retrieve the password using following
command:

``` bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d; echo
```

- Get public ssh key from gpg card

``` bash
gpg --card status
```

Take the key under `Authentication key` and use it in following function

``` bash
gpg --export-ssh-key [KeyID] > key.pub
```
<!-- TROUBESHOOTING -->
## Troubeshooting

- `terraform plan` runs into timeouts when trying to connect via ssh

Make sure to set the tf variable `source_addresses` to your public ip-address and manually set your public ip-address in the hetzner-cloud `k3s` firewall under `Allow Incoming SSH Traffic` and `Allow Incoming Requests to Kube API Server`

- Synchronization of the argocd postgres application fails

Apply the sync using the `--server-side` flag in order to workaraound an [issue](https://github.com/CrunchyData/postgres-operator/issues/3633) concerning invalid metadata annotations.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.md` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Maik Buse - contact@maikbuse.com

Project Link: [https://github.com/MaikBuse/cloud-config](https://github.com/MaikBuse/cloud-config)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Kube-Hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/MaikBuse/cloud-config.svg?style=for-the-badge
[contributors-url]: https://github.com/MaikBuse/cloud-config/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/MaikBuse/cloud-config.svg?style=for-the-badge
[forks-url]: https://github.com/MaikBuse/cloud-config/network/members
[stars-shield]: https://img.shields.io/github/stars/MaikBuse/cloud-config.svg?style=for-the-badge
[stars-url]: https://github.com/MaikBuse/cloud-config/stargazers
[issues-shield]: https://img.shields.io/github/issues/MaikBuse/cloud-config.svg?style=for-the-badge
[issues-url]: https://github.com/MaikBuse/cloud-config/issues
[license-shield]: https://img.shields.io/github/license/MaikBuse/cloud-config.svg?style=for-the-badge
[license-url]: https://github.com/MaikBuse/cloud-config/blob/main/LICENSE.md
[Terraform]: https://img.shields.io/badge/terraform-20232A?style=for-the-badge&logo=terraform
[Terraform-url]: https://terraform.io
[Kubernetes]: https://img.shields.io/badge/kubernetes-20232A?style=for-the-badge&logo=kubernetes
[Kubernetes-url]: https://kubernetes.io
[ArgoCD]: https://img.shields.io/badge/ArgoCD-20232A?style=for-the-badge&logo=argo
[Argo-url]: https://argo-cd.readthedocs.io/en/stable/
[Helm]: https://img.shields.io/badge/Helm-20232A?style=for-the-badge&logo=helm
[Helm-url]: https://helm.sh
[Tailscale]: https://img.shields.io/badge/Tailscale-20232A?style=for-the-badge
[Tailscale-url]: https://tailscale.sh
