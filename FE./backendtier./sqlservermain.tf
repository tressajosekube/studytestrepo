resource "random_string" "username" {
  length = 24
  special = true
  override_special = "%@!"
}

resource "random_password" "password" {
  length = 24
  special = true
  override_special = "%@!"
}

# # Create KeyVault Secret
resource "azurerm_key_vault_secret" "sql-1-username" {
  name         = "sql-server-1-username"
  value        = random_string.username.result
  key_vault_id = azurerm_key_vault.key_vault.id
  tags = merge(local.common_tags, tomap({"type" = "key-vault-secret-username"}), tomap({"resource" = azurerm_mssql_server.sql-server_1.name}))
  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "sql-1-password" {
  name         = "sql-server-1-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key_vault.id
  tags = merge(local.common_tags, tomap({"type" = "key-vault-secret-password"}), tomap({"resource" = azurerm_mssql_server.sql-server_1.name}))
  depends_on = [azurerm_key_vault_secret.sql-1-username]
}


resource "azurerm_mssql_server" "sql-server_1" {
  name = "${local.resource-name-prefix}-sql-server-1"
  resource_group_name = local.resource-group-name
  location            = var.resource-location
  version                      = "12.0"
  administrator_login          = azurerm_key_vault_secret.sql-1-username.value
  administrator_login_password = azurerm_key_vault_secret.sql-1-password.value
  tags = merge(local.common_tags, tomap({"type" = "mssql-server"}))
  depends_on = [azurerm_key_vault_secret.sql-1-password]
}
