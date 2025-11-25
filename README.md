# Secure Kubernetes Golden Image Pipeline

[![Build](https://github.com/praktan20/secure-k8s-golden-image/actions/workflows/build-and-publish.yml/badge.svg)](https://github.com/praktan20/secure-k8s-golden-image/actions)

FIPS-compliant, encrypted-at-rest golden Ubuntu 22.04 image for Kubernetes clusters, featuring full-disk LUKS2 encryption with Argon2id, detached headers, LVM-on-crypt, TPM2 PCR-bound auto-unlock, and pre-baked K8s v1.31.3 + containerd + NVIDIA GPU Operator.

Built for bare-metal fleets (EKS-Anywhere/OpenShift/Metal3) – used in production for 48-node H100 AI training clusters at Armada AI.

## Features
- **Security**: LUKS2 (Argon2id PBKDF, 512-bit AES-XTS), detached 4MiB header, encrypted swap, TPM2 auto-unlock (PCR 0,7), Cloud-init passphrase fallback.
- **Kubernetes**: v1.31.3 binaries (held), containerd CRI, Cilium-ready sysctls.
- **GPU/ML**: NVIDIA driver 550 + toolkit, DCGM exporter, MIG partitioning.
- **Automation**: Packer + Ansible + GitHub Actions; outputs QCOW2 for KVM/bare-metal.

## Quick Start
1. Set secrets: `ENCRYPTION_PASSPHRASE` in repo settings.
2. Build: `packer build -var 'encryption_passphrase=YourSecret!' packer/ubuntu-k8s-encrypted.pkr.hcl`
3. Deploy: Use in Cluster API `BareMetalMachineTemplate` or Metal3 `BareMetalHost`.

## Architecture
- **Packer**: QEMU builder for QCOW2 output.
- **Ansible**: Encrypts disk, installs K8s/NVIDIA, hardens kernel.
- **CI/CD**: GitHub Actions builds on tag push, publishes to Releases.

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for integration with ArgoCD/Metal3.

## License
MIT – Built by Praktan Taiwade [](https://www.linkedin.com/in/praktantaiwade/).# secure-k8s-golden-image
