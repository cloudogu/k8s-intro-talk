# k8s-intro-talk

Slides for an intro talk to kubernetes

## Hints

* Extract all listings from slides into `listings.txt`: `./printListings.sh`
* Allow for creating more pods on a single cluster: Make each pod not request CPU.
  Don't use this in production! 

```bash
kubectl delete limitrange --all
kubectl apply -f- <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-range
spec:
  limits:
    - defaultRequest:
        cpu: 0
      type: Container
EOF
```

