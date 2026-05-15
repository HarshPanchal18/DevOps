# [MiniBlue](https://github.com/moabukar/miniblue) - The free, open-source Azure emulator

## Installation

### Miniblue [Installation](https://miniblue.io/getting-started/installation/)

```bash
docker run -d -p 4566:4566 -p 4567:4567 moabukar/miniblue:latest
```

#### Veriy health

```bash
curl http://localhost:4566/health
```

```json
{
    "service_count": 26,
    "services": [
        "subscriptions","tenants","resourcegroups","blob","table","queue","keyvault","cosmosdb","servicebus","functions","network","dns","aci","acr","eventgrid","appconfig","identity","dbpostgres","redis","sqldb","dbmysql","publicip","nsg","loadbalancer","appgw","storageaccounts"
    ],
    "status": "running",
    "version": "0.4.4"
}
```

### `az` installation

#### Linux System

```bash
# Add the Microsoft signing key
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add the Azure CLI software repository
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

# Update repository information and install the Azure CLI
sudo apt-get update
sudo apt-get install azure-cli
```

Verify

```bash
az version
```

### `azlocal` installation

#### Linux

```bash
curl -LJO https://github.com/moabukar/miniblue/releases/download/v0.5.0/azlocal-linux-amd64
chmod +x azlocal-linux-amd64
sudo cp azlocal-linux-amd64 /usr/local/bin/azlocal-linux-amd64
```

Verify

```bash
azlocal health
```
