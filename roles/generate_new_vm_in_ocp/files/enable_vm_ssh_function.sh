VM_NAME="centos9-vm-demo"
NAMESPACE="virtual-machines"
NODE_PORT="30022"

VM_POD_IP=$(oc get pod -n "$NAMESPACE" \
  -l vm.kubevirt.io/name="$VM_NAME" \
  -o jsonpath='{.items[0].status.podIP}')

cat > "${VM_NAME}-ssh-nodeport.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${VM_NAME}-ssh
  namespace: ${NAMESPACE}
spec:
  type: NodePort
  ports:
    - name: ssh
      protocol: TCP
      port: 22
      targetPort: 22
      nodePort: ${NODE_PORT}
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: ${VM_NAME}-ssh-1
  namespace: ${NAMESPACE}
  labels:
    kubernetes.io/service-name: ${VM_NAME}-ssh
addressType: IPv4
ports:
  - name: ssh
    protocol: TCP
    port: 22
endpoints:
  - addresses:
      - ${VM_POD_IP}
EOF

oc apply -f "${VM_NAME}-ssh-nodeport.yaml"