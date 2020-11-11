output "access_addr" {
  value = kubernetes_service.nginx.load_balancer_ingress[0].hostname
}
