# Kubernetes

This folder contains useful Kubernetes command references and notes.

## Files

### `useful-commands.info`

A reference file of frequently used `kubectl` commands for managing Kubernetes clusters.

## Quick Reference

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes

# Namespace management
kubectl get namespaces
kubectl create namespace my-namespace

# Pod operations
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Deployments
kubectl get deployments -n <namespace>
kubectl rollout status deployment/<deployment-name> -n <namespace>
kubectl rollout restart deployment/<deployment-name> -n <namespace>

# Services
kubectl get services -n <namespace>
kubectl port-forward svc/<service-name> 8080:80 -n <namespace>

# Apply manifests
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml

# Context management
kubectl config get-contexts
kubectl config use-context <context-name>
```

## Additional Resources

- [Kubernetes documentation](https://kubernetes.io/docs/home/)
- [kubectl reference](https://kubernetes.io/docs/reference/kubectl/)
- [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/intro-kubernetes)
- [kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/quick-reference/)
