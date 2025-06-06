#!/bin/bash

DATA=$(date +%F)
BACKUP_DIR="/backup-servidor-$DATA"
REDUNDANTE_DIR="$BACKUP_DIR/redundante"
LOG_FILE="$BACKUP_DIR/backup-log-$DATA.txt"
MIN_ESPACO_MB=5120  # 5 GB

mkdir -p $BACKUP_DIR
mkdir -p $REDUNDANTE_DIR

log() {
    echo "$(date '+%F %T') - $1" | tee -a $LOG_FILE
}

verificar_espaco() {
    ESPACO_DISPONIVEL=$(df / | tail -1 | awk '{print $4}')
    ESPACO_DISPONIVEL_MB=$((ESPACO_DISPONIVEL / 1024))
    if (( $ESPACO_DISPONIVEL_MB < $MIN_ESPACO_MB )); then
        log "❌ ERRO: Espaço insuficiente. Disponível: ${ESPACO_DISPONIVEL_MB}MB, Requerido: ${MIN_ESPACO_MB}MB."
        return 1
    fi
    log "✅ Espaço suficiente: ${ESPACO_DISPONIVEL_MB}MB livres."
    return 0
}

compressao_ext() {
    case $compressao in
        1) echo "gz";;
        2) echo "xz";;
        3) echo "zst";;
        *) echo "tar";;
    esac
}

comprimir() {
    arquivo=$1
    case $compressao in
        1) gzip $arquivo;;
        2) xz -z $arquivo;;
        3) zstd -q -o $arquivo.zst $arquivo && rm $arquivo;;
        0) ;; # sem compressão
    esac
}

backup_completo() {
    log "🔹 Iniciando backup completo..."
    verificar_espaco || return

    log "🔹 Backup dos sites..."
    tar -cf $BACKUP_DIR/backup-wwwroot-$DATA.tar /www/wwwroot/
    cp $BACKUP_DIR/backup-wwwroot-$DATA.tar $REDUNDANTE_DIR/
    comprimir "$BACKUP_DIR/backup-wwwroot-$DATA.tar"

    log "🔹 Backup dos bancos..."
    MYSQL_BACKUP="$BACKUP_DIR/backup-mysql-$DATA.sql"
    if command -v mysqldump &> /dev/null; then
        mysqldump -u root -p --all-databases > $MYSQL_BACKUP
        cp $MYSQL_BACKUP $REDUNDANTE_DIR/
        comprimir "$MYSQL_BACKUP"
    else
        log "⚠️ mysqldump não encontrado."
    fi

    log "🔹 Backup das configs aaPanel..."
    tar -cf $BACKUP_DIR/backup-configs-$DATA.tar /www/server/ /www/backup/
    cp $BACKUP_DIR/backup-configs-$DATA.tar $REDUNDANTE_DIR/
    comprimir "$BACKUP_DIR/backup-configs-$DATA.tar"

    log "🔹 Backup dos volumes Docker..."
    docker volume ls -q | while read volume; do
        docker run --rm -v $volume:/volume -v $BACKUP_DIR:/backup alpine \
            tar cf /backup/backup-volume-$volume-$DATA.tar -C /volume .
        cp $BACKUP_DIR/backup-volume-$volume-$DATA.tar $REDUNDANTE_DIR/
        comprimir "$BACKUP_DIR/backup-volume-$volume-$DATA.tar"
    done

    log "🔹 Backup das imagens Docker..."
    docker images --format "{{.Repository}}:{{.Tag}}" | while read image; do
        IMAGE_FILE=$(echo $image | tr "/:" "_")
        docker save -o $BACKUP_DIR/backup-image-$IMAGE_FILE-$DATA.tar $image
        cp $BACKUP_DIR/backup-image-$IMAGE_FILE-$DATA.tar $REDUNDANTE_DIR/
        comprimir "$BACKUP_DIR/backup-image-$IMAGE_FILE-$DATA.tar"
    done

    log "🔹 Salvando estado atual do Docker..."
    docker ps -a > $BACKUP_DIR/containers-list.txt
    docker images > $BACKUP_DIR/images-list.txt
    docker volume ls > $BACKUP_DIR/volumes-list.txt
    docker network ls > $BACKUP_DIR/networks-list.txt
    cp $BACKUP_DIR/*.txt $REDUNDANTE_DIR/

    gerar_checksums
    enviar_para_nuvem
    enviar_email_notificacao
    log "✅ Backup completo!"
}

gerar_checksums() {
    log "🔹 Gerando checksums SHA256..."
    cd $BACKUP_DIR
    find . -type f ! -name "SHA256SUMS" -exec sha256sum "{}" + > SHA256SUMS
    cd -
    log "✅ Checksums gerados."
}

enviar_para_nuvem() {
    if [[ "$enviar_nuvem" == "s" ]]; then
        for remote in "${remotes[@]}"; do
            log "🔹 Enviando para $remote:$remote_path..."
            rclone copy $BACKUP_DIR $remote:$remote_path >> $LOG_FILE 2>&1
            log "✅ Backup enviado para $remote!"
        done
    fi
}

enviar_email_notificacao() {
    if [[ "$enviar_email" == "s" ]]; then
        mail -s "Backup servidor $DATA" $email_destino < $LOG_FILE
        log "✅ Notificação enviada para $email_destino"
    fi
}

migra_para_novo_servidor() {
    backup_completo
    read -p "Novo servidor (user@ip): " novo_servidor
    read -p "Caminho de destino: " caminho_destino
    log "🔹 Transferindo arquivos..."
    scp -r $BACKUP_DIR $novo_servidor:$caminho_destino
    log "✅ Migração concluída!"
}

restaurar_backup() {
    read -p "Informe o diretório do backup a restaurar: " dir_restore
    log "🔹 Restaurando backup de $dir_restore..."

    find $dir_restore -type f -name "*.gz" -exec gunzip {} \;
    find $dir_restore -type f -name "*.xz" -exec unxz {} \;
    find $dir_restore -type f -name "*.zst" -exec zstd -d {} \;

    log "✅ Backup descomprimido."

    log "⚠️ Restaurar dados manualmente conforme necessidade."
}

configurar() {
    echo ""
    echo "Configurações atuais:"
    echo "1. Compressão: $compressao (1-gzip, 2-xz, 3-zstd, 0-sem)"
    echo "2. Enviar para nuvem: $enviar_nuvem"
    echo "3. Enviar e-mail: $enviar_email"
    echo ""
    read -p "Nova compressão (1-gzip, 2-xz, 3-zstd, 0-sem): " compressao
    read -p "Enviar para nuvem? (s/n): " enviar_nuvem
    if [[ "$enviar_nuvem" == "s" ]]; then
        echo "Remotes configurados:"
        rclone listremotes
        read -p "Informe remotes (ex: gdrive mega): " -a remotes
        read -p "Caminho de destino na nuvem: " remote_path
    fi
    read -p "Enviar e-mail? (s/n): " enviar_email
    if [[ "$enviar_email" == "s" ]]; then
        read -p "Informe o e-mail de destino: " email_destino
    fi
}

menu() {
    while true; do
        echo ""
        echo "==============================="
        echo "  BACKUP PLUS - MENU PRINCIPAL"
        echo "==============================="
        echo "1) Fazer Backup"
        echo "2) Migrar para novo servidor"
        echo "3) Restaurar backup"
        echo "4) Configurar"
        echo "5) Sair"
        echo "==============================="
        read -p "Escolha uma opção: " op

        case $op in
            1) backup_completo ;;
            2) migra_para_novo_servidor ;;
            3) restaurar_backup ;;
            4) configurar ;;
            5) echo "Saindo..."; exit 0 ;;
            *) echo "Opção inválida." ;;
        esac
    done
}

# Iniciar
configurar
menu
