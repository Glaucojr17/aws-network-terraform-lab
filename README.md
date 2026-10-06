# Rede AWS declarada com Terraform

Este repositório demonstra uma base de rede que eu conseguiria revisar e evoluir em um time de plataforma: uma VPC com DNS habilitado, duas zonas de disponibilidade, sub-redes públicas e isoladas, tabelas de rota distintas, tags consistentes e testes automatizados de topologia. A configuração é funcional para uma conta AWS, mas **não foi aplicada a uma conta neste laboratório**. O CI executa `terraform test` com provider simulado e não precisa de credenciais.

## Topologia

| Camada | Sub-redes | Rota de saída |
| --- | --- | --- |
| Pública | `10.42.0.0/24` e `10.42.1.0/24` | `0.0.0.0/0` para o Internet Gateway |
| Isolada | `10.42.10.0/24` e `10.42.11.0/24` | Somente rota local da VPC; sem NAT |

Mesmo na sub-rede pública, instâncias não recebem IP público automaticamente. A sub-rede isolada não consegue acessar a Internet sem uma rota e um componente adicional, como NAT ou endpoints específicos. Não há EKS, instâncias EC2, banco ou NAT Gateway neste projeto.

## Executar os controles sem conta AWS

Requer Terraform 1.7+ (o workflow fixa 1.9.8):

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
```

Os testes fazem planos com `mock_provider "aws"`, conferem quantidade de sub-redes, DNS, rota pública, endereçamento e nomes em outro ambiente. Isso valida a configuração, mas não prova permissões IAM, quotas, disponibilidade de zonas ou conectividade real em uma conta.

## Planejar uma implantação real

1. Configure credenciais AWS por um mecanismo seguro no seu próprio ambiente; não grave chaves no Git.
2. Copie `terraform.tfvars.example` para `terraform.tfvars` e ajuste região, zonas e bloco CIDR.
3. Configure um backend remoto de estado e controle de acesso antes de uso compartilhado.
4. Execute `terraform plan -out=network.tfplan`, revise custos e impactos, então `terraform apply network.tfplan` somente na conta e janela aprovadas.
5. Para remover recursos de laboratório, execute `terraform destroy` após conferir dependências e impactos.

Um `apply` pode gerar cobranças e modificar a rede da conta. Este repositório não automatiza aplicação nem armazena credenciais. A arquitetura isolada é intencional: se uma aplicação precisar de downloads ou APIs externas, projete NAT, endpoints ou outra saída controlada com custo e segurança explícitos.

## Decisões de engenharia

- Endereçamento derivado do CIDR da VPC para evitar quatro blocos duplicados e divergentes. O parâmetro deve ser escolhido com espaço suficiente; o padrão é `/16`.
- Associações explícitas de tabelas de rota evitam depender da tabela principal implícita.
- `map_public_ip_on_launch = false` reduz exposição acidental.
- Tags `Project`, `Environment`, `ManagedBy`, `Name` e `Tier` ajudam identificação, custo e operação.
- Testes com provider simulado mantêm o feedback rápido. A próxima etapa de homologação seria um plano e testes de conectividade numa conta sandbox, com registro do resultado.

Consulte o [roteiro de revisão e diagnóstico](docs/OPERACAO.md) para triagem de rota, DNS e falhas de plano.
