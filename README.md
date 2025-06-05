# Backup Plus - aaPanel e Docker

Backup Plus é um script interativo e automatizado para realizar **backup completo** de servidores que utilizam o **aaPanel** e **Docker**.  

## ✅ Funcionalidades:

- Backup completo de:
  - Sites (`/www/wwwroot`)
  - Configurações do aaPanel
  - Bancos de dados MySQL
  - Volumes e imagens Docker
  - Configurações e estado atual do Docker
- Compressão configurável: `gzip`, `xz`, `zstd` ou **sem compressão**.
- Backup redundante sem compressão.
- Geração automática de **checksums SHA256**.
- Verificação de **espaço em disco** antes de iniciar.
- Envio automático para **múltiplos serviços de nuvem** com `rclone`.
- Notificação automática por **e-mail**.
- Migração facilitada para **novo servidor**.
- Restauração automatizada, com **descompressão**.

---

## ✅ Pré-requisitos:

Antes de usar o script, instale:  

- `tar`, `gzip`, `xz`, `zstd` (para compressão).
- `rclone` → [Guia oficial](https://rclone.org/install/)  
- `mailutils` ou `msmtp` (para envio de e-mails).  
- `mysqldump` → geralmente já vem com o MySQL.  
- `Docker` → [Guia oficial](https://docs.docker.com/engine/install/)  
- `scp` → via `openssh-client`  
- `sha256sum` → geralmente padrão em sistemas Linux.  

### **Para Debian/Ubuntu:**

```bash
sudo apt update
sudo apt install gzip xz-utils zstd rclone mailutils mysql-client docker.io
