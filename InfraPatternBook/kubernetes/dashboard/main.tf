# # Copyright 2017 The Kubernetes Authors.
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.

# # ------------------- Dashboard Secret ------------------- #

# apiVersion: v1
# kind: Secret
# metadata:
#   labels:
#     k8s-app: kubernetes-dashboard
#   name: kubernetes-dashboard-certs
#   namespace: kube-system
# type: Opaque

resource "kubernetes_secret" "example" {
  metadata {
    name      = "kubernetes-dashboard-certs"
    namespace = "kube-system"
    labels = {
      "k8s-app" : "kubernetes-dashboard"
    }
  }

  type = "Opaque"
}

# ---
# # ------------------- Dashboard Service Account ------------------- #

# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   labels:
#     k8s-app: kubernetes-dashboard
#   name: kubernetes-dashboard
#   namespace: kube-system

resource "kubernetes_service_account" "example" {
  metadata {
    name      = "kubernetes-dashboard-certs"
    namespace = "kube-system"
    labels = {
      "k8s-app" : "kubernetes-dashboard"
    }
  }
}
# ---
# # ------------------- Dashboard Role & Role Binding ------------------- #

# kind: Role
# apiVersion: rbac.authorization.k8s.io/v1
# metadata:
#   name: kubernetes-dashboard-minimal
#   namespace: kube-system
# rules:
#   # Allow Dashboard to create 'kubernetes-dashboard-key-holder' secret.
# - apiGroups: [""]
#   resources: ["secrets"]
#   verbs: ["create"]
#   # Allow Dashboard to create 'kubernetes-dashboard-settings' config map.
# - apiGroups: [""]
#   resources: ["configmaps"]
#   verbs: ["create"]
#   # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
# - apiGroups: [""]
#   resources: ["secrets"]
#   resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs"]
#   verbs: ["get", "update", "delete"]
#   # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
# - apiGroups: [""]
#   resources: ["configmaps"]
#   resourceNames: ["kubernetes-dashboard-settings"]
#   verbs: ["get", "update"]
#   # Allow Dashboard to get metrics from heapster.
# - apiGroups: [""]
#   resources: ["services"]
#   resourceNames: ["heapster"]
#   verbs: ["proxy"]
# - apiGroups: [""]
#   resources: ["services/proxy"]
#   resourceNames: ["heapster", "http:heapster:", "https:heapster:"]
#   verbs: ["get"]

resource "kubernetes_role" "example" {
  metadata {
    name      = "kubernetes-dashboard-minimal"
    namespace = "kube-system"
  }

  # Allow Dashboard to create 'kubernetes-dashboard-key-holder' secret.
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create"]
  }

  # Allow Dashboard to create 'kubernetes-dashboard-settings' config map.
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create"]
  }

  # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs"]
    verbs          = ["get", "update", "delete"]
  }

  # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["kubernetes-dashboard-settings"]
    verbs          = ["get", "update"]
  }

  #   # Allow Dashboard to get metrics from heapster.
  rule {
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["heapster"]
    verbs          = ["proxy"]
  }
  rule {
    api_groups     = [""]
    resources      = ["services/proxy"]
    resource_names = ["heapster", "http:heapster:", "https:heapster:"]
    verbs          = ["get"]
  }
}

# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: RoleBinding
# metadata:
#   name: kubernetes-dashboard-minimal
#   namespace: kube-system
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: Role
#   name: kubernetes-dashboard-minimal
# subjects:
# - kind: ServiceAccount
#   name: kubernetes-dashboard
#   namespace: kube-system

resource "kubernetes_role_binding" "example" {
  metadata {
    name      = "kubernetes-dashboard-minimal"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kubernetes-dashboard-minimal"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }
}

# ---
# # ------------------- Dashboard Deployment ------------------- #

# kind: Deployment
# apiVersion: apps/v1
# metadata:
#   labels:
#     k8s-app: kubernetes-dashboard
#   name: kubernetes-dashboard
#   namespace: kube-system
# spec:
#   replicas: 1
#   revisionHistoryLimit: 10
#   selector:
#     matchLabels:
#       k8s-app: kubernetes-dashboard
#   template:
#     metadata:
#       labels:
#         k8s-app: kubernetes-dashboard
#     spec:
#       containers:
#       - name: kubernetes-dashboard
#         image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
#         ports:
#         - containerPort: 8443
#           protocol: TCP
#         args:
#           - --auto-generate-certificates
#           # Uncomment the following line to manually specify Kubernetes API server Host
#           # If not specified, Dashboard will attempt to auto discover the API server and connect
#           # to it. Uncomment only if the default does not work.
#           # - --apiserver-host=http://my-address:port
#         volumeMounts:
#         - name: kubernetes-dashboard-certs
#           mountPath: /certs
#           # Create on-disk volume to store exec logs
#         - mountPath: /tmp
#           name: tmp-volume
#         livenessProbe:
#           httpGet:
#             scheme: HTTPS
#             path: /
#             port: 8443
#           initialDelaySeconds: 30
#           timeoutSeconds: 30
#       volumes:
#       - name: kubernetes-dashboard-certs
#         secret:
#           secretName: kubernetes-dashboard-certs
#       - name: tmp-volume
#         emptyDir: {}
#       serviceAccountName: kubernetes-dashboard
#       # Comment the following tolerations if Dashboard must not be deployed on master
#       tolerations:
#       - key: node-role.kubernetes.io/master
#         effect: NoSchedule

resource "kubernetes_deployment" "kubernetes-dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
    labels = {
      "k8s-app" : "kubernetes-dashboard"
    }
  }

  spec {
    replicas               = 1
    revision_history_limit = 10
    selector {
      match_labels = {
        k8s-app : "kubernetes-dashboard"
      }
    }

    template {
      metadata {
        labels = {
          "k8s-app" : "kubernetes-dashboard"
        }
      }

      spec {
        container {
          name  = "kubernetes-dashboard"
          image = "8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1"

          port {
            container_port = 8443
            protocol       = "TCP"
          }

          args = ["--auto-generate-certificates"]

          volume_mount {
            name       = "kubernetes-dashboard-certs"
            mount_path = "/certs"
          }

          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              scheme = "HTTPS"
              path   = "/"
              port   = "8443"
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        volume {
          name = "kubernetes-dashboard-certs"
          secret {
            secret_name = "kubernetes-dashboard-certs"
          }
        }

        volume {
          name = "tmp-volume"
          empty_dir {}
        }

        service_account_name = "kubernetes-dashboard"

        # toleration {
        #   # key = "node-role.kubernetes.io/master"
        #   # effect = NoSchedule"
        # }
      }
    }
  }
}

# ---
# # ------------------- Dashboard Service ------------------- #
# kind: Service
# apiVersion: v1
# metadata:
#   labels:
#     k8s-app: kubernetes-dashboard
#   name: kubernetes-dashboard
#   namespace: kube-system
# spec:
#   ports:
#     - port: 443
#       targetPort: 8443
#   selector:
#     k8s-app: kubernetes-dashboard

resource "kubernetes_service" "kubernetes-dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
    labels = {
      "k8s-app" : "kubernetes-dashboard"
    }
  }

  spec {
    port {
      port        = 443
      target_port = 8443
    }

    selector = {
      "k8s-app" = "kubernetes-dashboard"
    }

    type = "LoadBalancer"
  }

  # spec {    
  #   selector = {
  #     app = "${kubernetes_pod.example.metadata.0.labels.app}"
  #   }
  #   session_affinity = "ClientIP"
  #   port {
  #     port        = 8080
  #     target_port = 80
  #   }

  #   type = "LoadBalancer"
  # }
}

