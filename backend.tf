# terraform{
#     backend "azurerm" {
#         resource_group_name  = "1-754cec77-playground-sandbox"
#         storage_account_name = "aidenterraform"
#         container_name       = "tfstate"
#         key                  = "terraform.tfstate"
#         client_id            = "3c1066f8-cf36-43ba-94cd-43e771d9a69f"  # Can also be set via `ARM_CLIENT_ID` environment variable.
#         client_secret        = "aT.8Q~T.vsr.X5yj3qH5yV9Ng3eJV9OYb2W-NdoK"  # Can also be set via `ARM_CLIENT_SECRET` environment variable.
#         subscription_id      = "2213e8b1-dbc7-4d54-8aff-b5e315df5e5b"  # Can also be set via `ARM_SUBSCRIPTION_ID` environment variable.
#         tenant_id            = "84f1e4ea-8554-43e1-8709-f0b8589ea118"  # Can also be set via `ARM_TENANT_ID` environment variable.
#     }
# }
