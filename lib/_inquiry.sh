#!/bin/bash

get_deploy() {
  
  print_banner
  printf "${WHITE} 💻 Insira senha para o usuario Deploy:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " deploy_password
 }

get_memory_node() {
  
  print_banner
  printf "${WHITE} 💻 Insira o tamanho da memória para o node em MB (exemplo 2048):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " size_memory_node
 }

get_s3_option() {
  print_banner
  printf "${WHITE} 💻 Utilizará o serviço S3 (Y, n):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " s3_option
    

    if [[ "$s3_option" == "Y" || "$s3_option" == "y" ]]; then
        echo "Configuração do S3:"
        echo "Informe o provedor (ex: AWS, CONTABO, MINIO):"
        read -p "> "  provider

        echo "Informe a chave compartilhada (opcional):"
        read -p "> "  shared_key

        echo "Informe a URL do endpoint:"
        read -p "> "  endpoint_url

        echo "Informe a Access Key:"
       read -p "> "  access_key

        echo "Informe a Secret Key:"
        read -p "> "  secret_key

        echo "Informe a região:"
        read -p "> " region

    else
       echo "prosseguindo"
    fi
}

get_mysql_root_password() {
  
  print_banner
  printf "${WHITE} 💻 Insira senha para o Banco de Dados (Não utilizar caracteres especiais):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " mysql_root_password
}

get_link_git() {
  
  print_banner
  printf "${WHITE} 💻 Insira o link do GITHUB do Whaticket que deseja instalar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " link_git
}

get_instancia_add() {
  
  print_banner
  printf "${WHITE} 💻 Informe um nome para a Instancia/Empresa que será instalada (Não utilizar espaços ou caracteres especiais, Utilizar Letras minusculas; ):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
  }

#get_max_whats() {
# 
#  print_banner
#  printf "${WHITE} 💻 Informe a Qtde de Conexões/Whats que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
# printf "\n\n"
# read -p "> " max_whats
#}

#get_max_user() {
# 
#print_banner
#printf "${WHITE} 💻 Informe a Qtde de Usuarios/Atendentes que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
#printf "\n\n"
#read -p "> " max_user
#}


get_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio do FRONTEND/PAINEL para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio do BACKEND/API para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND para a ${instancia_add}; Ex: 3001 A 3999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_port
}


get_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND para esta instancia; Ex: 4001 A 4999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_port
}

get_redis_port() {
    print_banner

    # Encontra as portas de todos os containers que começam com "redis-"
    redis_ports=$(docker ps --filter "name=redis-*" --format '{{.Ports}}' | awk -F'->' '{print $1}' | cut -d':' -f2)

    # Encontra a porta Redis mais alta em uso (incluindo containers) dentro do intervalo 5000-5999
    highest_port=5000  # Começa em 5000, o início do intervalo
    for port in $redis_ports; do
        if (( port > highest_port && port <= 5599 )); then  # Verifica se a porta está dentro do intervalo
            highest_port=$port
        fi
    done

    # Sugere a próxima porta disponível dentro do intervalo
    suggested_port=$((highest_port + 1))
    while (( suggested_port <= 5599 )); do
        # Verifica se a porta sugerida está em uso por algum outro processo
        if ! ss -tulpn | awk '{print $4}' | grep -q ":$suggested_port$"; then
            break  # Encontrou uma porta livre
        fi
        suggested_port=$((suggested_port + 1))
    done

    # Se não encontrar nenhuma porta livre no intervalo, exibe um erro
    if (( suggested_port > 5599)); then
        echo "${RED} ❌ Erro: Nenhuma porta Redis livre encontrada no intervalo 5000-5999.${NC}"
        exit 1
    fi
    printf "${WHITE} 💻 Digite a porta do REDIS/AGENDAMENTO MSG para a ${instancia_add} (ou Enter para usar $suggested_port): ${GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " redis_port

    # Se a entrada estiver em branco, usa a porta sugerida
    if [ -z "$redis_port" ]; then
        redis_port=$suggested_port
        echo "Usando a porta sugerida: $redis_port"
    fi
}



get_rabbitmq_port() {
    print_banner

     # Encontra as portas de todos os containers que começam com "redis-"
    rabbitmq_ports=$(docker ps --filter "name=rabbitmq-*" --format '{{.Ports}}' | awk -F'->' '{print $1}' | cut -d':' -f2)

    # Encontra a porta rabbitmq mais alta em uso (incluindo containers) dentro do intervalo 5000-5999
    highest_port=5600  # Começa em 5600, o início do intervalo
    for port in $rabbitmq_ports; do
        if (( port > highest_port && port <= 5999 )); then  # Verifica se a porta está dentro do intervalo
            highest_port=$port
        fi
    done

    # Sugere a próxima porta disponível dentro do intervalo
    suggested_port=$((highest_port + 1))
    while (( suggested_port <= 5999 )); do
        # Verifica se a porta sugerida está em uso por algum outro processo
        if ! ss -tulpn | awk '{print $4}' | grep -q ":$suggested_port$"; then
            break  # Encontrou uma porta livre
        fi
        suggested_port=$((suggested_port + 1))
    done

    # Se não encontrar nenhuma porta livre no intervalo, exibe um erro
    if (( suggested_port > 5999 )); then
        echo "${RED} ❌ Erro: Nenhuma porta rabbitmq livre encontrada no intervalo 5600-5999.${NC}"
        exit 1
    fi
    printf "${WHITE} 💻 Digite a porta do rabbitmq/AGENDAMENTO MSG para a ${instancia_add} (ou Enter para usar $suggested_port): ${GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " rabbitmq_port

    # Se a entrada estiver em branco, usa a porta sugerida
    if [ -z "$rabbitmq_port" ]; then
        rabbitmq_port=$suggested_port
        echo "Usando a porta sugerida: $rabbitmq_port"
    fi
}



get_empresa_delete() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que será Deletada (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_delete
}

get_empresa_atualizar() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Atualizar (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_atualizar
}

get_empresa_bloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Bloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_bloquear
}

get_empresa_desbloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Desbloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_desbloquear
}

get_empresa_dominio() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Alterar os Dominios (Atenção para alterar os dominios precisa digitar os 2, mesmo que vá alterar apenas 1):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_dominio
}

get_alter_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do FRONTEND/PAINEL para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_url
}

get_alter_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do BACKEND/API para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_url
}

get_alter_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_port
}


get_alter_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_port
}


get_urls() {
  get_mysql_root_password
  get_link_git
  get_instancia_add
  get_s3_option
  get_frontend_url
  get_backend_url
  get_frontend_port
  get_backend_port
  get_redis_port
  get_rabbitmq_port
  get_memory_node
}

software_update() {
  get_empresa_atualizar
  frontend_update
  backend_update
}

software_delete() {
  get_empresa_delete
  deletar_tudo
}

software_bloquear() {
  get_empresa_bloquear
  configurar_bloqueio
}

software_desbloquear() {
  get_empresa_desbloquear
  configurar_desbloqueio
}

software_dominio() {
  get_empresa_dominio
  get_alter_frontend_url
  get_alter_backend_url
  get_alter_frontend_port
  get_alter_backend_port
  configurar_dominio
}

inquiry_options() {
  
  print_banner
  printf "${WHITE} 💻 Bem vindo(a), Selecione abaixo a proxima ação!${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [0] Instalar whaticket\n"
  printf "   [1] Atualizar whaticket\n"
  printf "   [2] Deletar Whaticket\n"
  printf "   [3] Bloquear Whaticket\n"
  printf "   [4] Desbloquear Whaticket\n"
  printf "   [5] Alter. dominio Whaticket\n"
  printf "\n"
  read -p "> " option

  case "${option}" in
    0) get_urls ;;

    1) 
      software_update 
      exit
      ;;

    2) 
      software_delete 
      exit
      ;;
    3) 
      software_bloquear 
      exit
      ;;
    4) 
      software_desbloquear 
      exit
      ;;
    5) 
      software_dominio 
      exit
      ;;        

    *) exit ;;
  esac
}


