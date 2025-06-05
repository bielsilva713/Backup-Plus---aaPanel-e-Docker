# ✅ **Backup Plus — Solução Completa para Backup e Migração de Servidores com aaPanel + Docker**

## 🚀 Sobre o projeto

**Backup Plus** é um **script shell interativo**, robusto e modular, desenvolvido para facilitar a **gestão de backups, restaurações e migrações completas** de servidores que utilizam:

* **aaPanel** — painel de controle web para gerenciamento de sites, bancos e serviços.
* **Docker** — containerização de aplicações.

O script permite realizar **backups completos** e **migrar servidores inteiros**, preservando dados críticos como:

✅ Sites hospedados
✅ Configurações do aaPanel
✅ Bancos de dados
✅ Volumes e imagens Docker
✅ Estado atual do Docker (containers, redes, volumes)

---

## 🎯 **Principais recursos**

### ✅ Backup automatizado de:

* Diretórios de sites: `/www/wwwroot`
* Configurações e scripts do aaPanel: `/www/server`, `/www/backup`
* Banco de dados MySQL: dump completo via `mysqldump`
* Todos os volumes Docker: utilizando `docker run` + `tar`
* Todas as imagens Docker: via `docker save`
* Estado atual do Docker: lista de containers, imagens, volumes e redes

---

### ✅ Compressão configurável:

* `gzip` — compressão rápida e compatível
* `xz` — compressão forte, mais lenta
* `zstd` — moderna, rápida e eficiente
* **Ou sem compressão**, mantendo backup em formato puro `.tar`

**Backup redundante:** uma cópia extra, **sem compressão**, para segurança adicional.

---

### ✅ Validação e segurança:

* Verificação de **espaço em disco** antes de iniciar.
* Geração automática de **checksums SHA256** para integridade.

---

### ✅ Automação de envio:

* **Envio automático** para múltiplos serviços de nuvem via `rclone`:

  * Google Drive
  * Mega.nz
  * OneDrive
  * Dropbox
  * Amazon S3
  * E muitos outros

* **Notificação automática por e-mail** após finalização.

---

### ✅ Restauração e migração:

* **Restauração automática**: identifica e descomprime os backups com segurança.
* **Migração facilitada**: transfere o backup via `scp` para um **novo servidor**, preservando todas as dependências.

---

### ✅ Menu interativo:

Interface simples, guiando o usuário:

```
1) Fazer Backup
2) Migrar para novo servidor
3) Restaurar backup
4) Configurar
5) Sair
```

---

## 📦 **Como funciona?**

1. Você escolhe a ação no menu.
2. O script executa automaticamente:

   * Verificação de espaço.
   * Backup completo com compressão.
   * Geração de hashes.
   * Envio à nuvem.
   * Notificação por e-mail.
3. Você recebe confirmação por terminal e e-mail.

---

## 🛠️ **Pré-requisitos**

Instale os seguintes pacotes:

### ✔️ Utilitários de compressão:

```bash
sudo apt install gzip xz-utils zstd
```

### ✔️ Backup e rede:

```bash
sudo apt install tar openssh-client
```

### ✔️ Docker:

[Guia oficial de instalação](https://docs.docker.com/engine/install/)

---

### ✔️ Banco de dados:

* `mysqldump` para backup de MySQL/MariaDB:

```bash
sudo apt install mysql-client
```

---

### ✔️ E-mail:

Para envio automático de relatórios:

```bash
sudo apt install mailutils
```

ou configure `msmtp` para serviços como Gmail ou Outlook.

---

### ✔️ Nuvem:

* `rclone` → [Guia oficial](https://rclone.org/install/)

```bash
curl https://rclone.org/install.sh | sudo bash
```

Configure remotes:

```bash
rclone config
```

---

## ⚙️ **Instalação do script**

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/backup-plus-aapanel-docker.git
cd backup-plus-aapanel-docker
```

2. Torne o script executável:

```bash
chmod +x backup-plus.sh
```

---

## 🚀 **Como usar?**

Execute:

```bash
./backup-plus.sh
```

Navegue pelo **menu interativo**.

---

## ⚙️ **Configuração personalizada**

Na opção `4) Configurar`, ajuste:

✅ Tipo de compressão
✅ Envio automático à nuvem
✅ Envio de notificação por e-mail

---

## 💡 **Casos de uso práticos:**

### ✅ Backup diário:

1. Configure preferências.
2. Agende com `cron`:

```bash
0 2 * * * /caminho/para/backup-plus.sh >> /var/log/backup-plus.log 2>&1
```

---

### ✅ Migração completa:

1. Execute:
2. `2) Migrar`.
3. Informe:

   * IP do novo servidor
   * Caminho de destino

Backup é realizado e transferido automaticamente via `scp`.

---

### ✅ Restauração:

1. Execute: `3) Restaurar`.
2. Informe o caminho do backup.
3. O script descomprime tudo automaticamente.

---

## 🔒 **Segurança**

✅ Executa apenas localmente: não expõe portas ou APIs.
✅ Compatível com backups criptografados via `rclone` (manual).
✅ Gera **hashes SHA256** para validação.
✅ Redundância: backup comprimido + sem compressão.

---

## 📝 **Boas práticas:**

* Execute como `root` ou via `sudo`.
* Monitore espaço em disco.
* Realize testes de restauração periodicamente.
* Proteja arquivos de backup com permissões restritas.

---

## 🔄 **Manutenção e extensibilidade**

Script modular, facilmente adaptável para:

✅ Adição de novas opções de compressão.
✅ Integração com outros serviços de nuvem.
✅ Suporte a bancos adicionais (PostgreSQL, etc).
✅ Painel web futuro.

---

## 🏷️ **Licença**

Distribuído sob licença **MIT**:

* Livre para uso pessoal e comercial.
* Alterações e redistribuições permitidas.

---

## 🤝 **Contribuindo**

Contribuições são muito bem-vindas!

✅ Envie **issues** para reportar bugs ou sugerir melhorias.
✅ Faça um **fork** e envie um **Pull Request** com suas modificações.

---

## 👨‍💻 **Autor**

Feito com 💙 por [Gabriel](https://github.com/bielsilva713)

---

## 🏆 **O script ideal para administradores que buscam segurança, praticidade e automação no backup e migração de servidores!**

