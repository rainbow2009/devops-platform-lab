# Kubernetes labs

Small, self-contained scenarios to practise Kubernetes behaviour and troubleshooting. Each one is meant to be applied, observed with `kubectl`, and broken on purpose.

```bash
kubectl create namespace lab
kubectl -n lab apply -f <file>.yaml
```

| Scenario | Files | What to observe |
|---|---|---|
| Health probes | `probes-ok.yaml`, `probes-broken-liveness.yaml`, `probes-broken-readiness.yaml` | Broken **liveness** → restart loop (`RESTARTS` grows). Broken **readiness** → pod `Running` but `0/1 Ready`, removed from Service endpoints. |
| Slow start | `probes-slow-start.yaml` | **startupProbe** gives a slow app up to 60s before liveness kicks in, instead of killing it during startup. |
| Scheduling | `scheduling-plain.yaml`, `scheduling-toleration.yaml`, `scheduling-affinity.yaml` | With a tainted node (`kubectl taint nodes <node> workload=database:NoSchedule`): plain pods avoid it, a toleration *allows* it, toleration + nodeAffinity *forces* it. |
| Disruption budget | `pdb-demo.yaml` | `kubectl drain` respects `minAvailable`; `topologySpreadConstraints` spread replicas across nodes. |
| Storage | `pvc.yaml`, `pvc-pod.yaml` | PVC binding, data survives pod deletion. |
| RBAC | `rbac-readonly.yaml`, `rbac-nodes.yaml` | Least-privilege ServiceAccount; check with `kubectl auth can-i --as=system:serviceaccount:lab:monitoring ...`. Role vs ClusterRole. |
| SLO alerting | `slo-rules.yaml` | Prometheus recording rules for error ratio and a **multi-window burn-rate** alert (99.9% SLO, 14.4x burn = budget gone in ~2 days). |

## Troubleshooting sequence used in these labs

```bash
kubectl get pods -o wide                      # state, restarts, node
kubectl describe pod <pod>                    # Events: probe failures, scheduling, image pulls
kubectl logs <pod> [--previous]               # app logs, previous crashed container
kubectl get endpoints <service>               # is the pod actually receiving traffic?
kubectl get events --sort-by=.lastTimestamp
```
