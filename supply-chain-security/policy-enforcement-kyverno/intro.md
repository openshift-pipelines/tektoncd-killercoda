# Policy Enforcement: Block Unsigned Images with Kyverno

Signing images with Tekton Chains is only half the story. The other half is
**enforcing** that only signed images can be deployed. Without enforcement,
signing is security theater -- anyone could deploy an unsigned, potentially
malicious image.

**Kyverno** is a Kubernetes-native policy engine that can verify image
signatures at admission time. When combined with Tekton Chains, you get a
complete **build-time signing + deploy-time enforcement** workflow.

## The enforcement gap

```
Without enforcement:
  Build + Sign --> Registry --> Anyone deploys anything (even unsigned) --> Problem!

With enforcement:
  Build + Sign --> Registry --> Kyverno checks signature --> Signed? Deploy! Unsigned? Blocked!
```

## What you will learn

In this tutorial, you will:

- Configure Tekton Chains for **automatic image signing**
- Install **Kyverno** as a policy enforcement engine
- Create a **ClusterPolicy** that verifies image signatures using your cosign
  public key
- Deploy a **signed image** and see Kyverno allow it
- Deploy an **unsigned image** and see Kyverno block it with a clear rejection
  message

## Prerequisites

This tutorial assumes familiarity with:

- Tekton Chains and cosign (see the Image Signing tutorial)
- Kubernetes Deployments and admission controllers

While the environment loads, Tekton Pipelines, Tekton Chains, Kyverno, a local
container registry, `tkn`, and `cosign` are being installed. This may take two
to three minutes.
