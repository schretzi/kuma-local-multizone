# Setup Kuma Multizone Demo on MacBook

## Requirements

- Docker installed and running 
- k3d installed and working
- kumactl installed
- optional tools I use:
    - kubectx, kubens

## Setup 3 Kubernetes Clusters



```
k3d cluster create kuma-cp --network kuma
k3d cluster create kuma-zone-a --network kuma
k3d cluster create kuma-zone-b --network kuma
```


kubectl 


## Setup Kuma Global CP

Link to original docu: https://kuma.io/docs/2.4.x/production/cp-deployment/multi-zone/


! Be aware which k3s you are working with, I use kubectx for it

```
kubectx k3d-kuma-cp
kumactl install control-plane --mode=global | kubectl apply -f -
```

Wait for the deployment to finish his work and check for the external-ip of the Kuma service:

```
kubectl get services -n kuma-system

NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                              AGE
kuma-control-plane      ClusterIP      10.43.136.5    <none>        5680/TCP,5681/TCP,5682/TCP,443/TCP   119s
kuma-global-zone-sync   LoadBalancer   10.43.156.41   172.29.0.3    5685:30865/TCP                       119s
```

## Setup debug container in same network && Start portforwarding to GUI
To be able to access the Kuma Gui I will forward the port:

```
kubectl port-forward svc/kuma-control-plane -n kuma-system 5681:5681 &
```

And I start a ubuntu container in the same network
```
docker run -ti --network kuma ubuntu /bin/bash
```

## Setup Zone CPs

We need to take the IP from the above output, in our case 172.29.0.3 and use it in the next commands

### Zone A

```
kubectx k3d-kuma-zone-a
export ZONENAME=zone-a
export CP_IP=172.29.0.3
kumactl install control-plane \
--mode=zone \
--zone=$ZONENAME \
--ingress-enabled \
--kds-global-address grpcs://$CP_IP:5685 \
--set controlPlane.tls.kdsZoneClient.skipVerify=true | kubectl apply -f -
```

### Zone B

```
kubectx k3d-kuma-zone-b
export ZONENAME=zone-b
export CP_IP=172.29.0.3
kumactl install control-plane \
--mode=zone \
--zone=$ZONENAME \
--ingress-enabled \
--kds-global-address grpcs://$CP_IP:5685 \
--set controlPlane.tls.kdsZoneClient.skipVerify=true | kubectl apply -f -
```


## Add observability to Global CP


```
kubectx k3d-kuma-cp
kumactl install observability | kubectl apply -f -
```

## Demo App

Now lets follow the Kuma demo app guide:
https://kuma.io/docs/2.4.x/quickstart/kubernetes/

Here is the list of the commands without further explanation:

```
git clone https://github.com/kumahq/kuma-counter-demo.git
cd kuma-counter-demo
kubectx k3d-kuma-zone-a
kubectl apply -f demo.yaml
kubectl port-forward svc/demo-app -n kuma-demo 5000:5000


```