# Revisão e diagnóstico da rede

Antes de aplicar, confira a conta/região ativa (`aws sts get-caller-identity`, `aws configure list`), as zonas disponíveis, sobreposição de CIDRs com VPN/VPCs existentes, permissões e backend do estado. Um plano sem mudanças inesperadas deve mostrar VPC, quatro sub-redes, IGW, duas tabelas de rota, quatro associações e apenas uma rota default pública.

Se uma instância não resolver DNS, verifique `enable_dns_support`, `enable_dns_hostnames`, o resolver do sistema e DHCP options. Se não houver saída para Internet, confirme a associação da sub-rede com a tabela correta, existência da rota `0.0.0.0/0`, IP público ou gateway de aplicação, security group e NACL. Uma sub-rede isolada não tem rota de saída por desenho; nesse caso o diagnóstico é conferir se o requisito de egress foi previsto antes da implantação.

Em incidentes, registre mudança, horário, impacto e evidências. Compare estado Terraform, rotas observadas no console/API e fluxo de pacotes antes de corrigir. Evite adicionar uma rota default à tabela isolada apenas para contornar um erro de aplicação; isso muda o limite de segurança da arquitetura.
