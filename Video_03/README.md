# Habilitando el Secret Engine 🔐 de Azure ☁️ en HashiCorp Vault

Video: https://youtu.be/TBguOAjluGM

![Vault_Video_03.jpg](img%2FVault_Video_03.jpg)

## REQUIREMENTS:

- Una cuenta de Azure.
- Una cuenta de usuario Root en Azure.
- Enterprise Application (SPN o Service Principal) / App Registration con Role "Contributor" sobre la subscripcion y con su respectivo Secret configurado.
- El App Registration anterior debe tener los siguientes API Permisions (estos permissos se definen dentro de la config del mismo App Registration):
  API Permissions (todos con "Granted for Directorio predeterminado"):
  Microsoft Graph (Application Permissions)
    - Application.Read.All
    - Application.ReadWrite.All
    - Domain.Read.All
    - Group.Read.All
    - Group.ReadWrite.All
    - User.Read.All
    - User.ReadWrite.All
- Un Resource Group que sera usado como Scope para crear identidades que tengan permisos sobre ese Scope, en este caso le he asignado el nombre "vault"".
- Asignar Role "Owner" en "Privileged administrator roles" al User, Group o Service Principal en este caso **vault-azure** sobre el Resource Group usado como Scope comentado anteriormente, para que los usuarios creados con el usuario **vault-azure** puedan serle asignado el role "Contributor" sobre el Resource Group.

---

## Pasos para habilitar el Secret engine de Azure en Vault desde la CLI

Lo primero que vamos a hacer es levantar una instancia de Vault en local, para ello necesitamos tener instalado el binario de HashiCorp Vault, una vez instalado ejecutamos lo siguiente:

````
vault server -dev
````

Abrimos otro prompt de nuestra terminal y exportamos la variable de entorno con la direccion de nuestra instancia de HashiCorp Vault.
````
export VAULT_ADDR="http://localhost:8200"
````

Ahora copiamos el Root Token y accedemos via HTTP desde nuestro navegador para comprobar desde HTTP los secret engines habilitados desde http://localhost:8200.

Hacemos login desde la CLI con nuestro Root Token.
````
vault login
````

Habilitamos el secret engine de Azure.

````
vault secrets enable azure
````
Ahora configuramos el secret engine con las credeciales de la App Registration que necesitamos tener creada previamente con los permisos de API que estan expuestos en los requerimientos.

````
vault write azure/config \
    subscription_id="7175fc39-c8ca-43b4-b86f-971366001986" \
    tenant_id="34c4878f-a462-4614-94cb-aadbb2cc7c85" \
    client_id="14fd145a-770f-4622-9913-daf0e3bfad39" \
    client_secret="6XZ8Q~XelMknyFCKgI4pCBTFl8koAgnpy51TCbUW"
````

Configuramos el Role que permite hacer uso del Secret Engine, para esto necesitamos el Application Registration Object ID, donde "my-role" lo podemos modificar para generar el role con el nombre que nos convenga.

````
vault write azure/roles/my-role \
    application_object_id="514c8307-2e5f-4f74-b87a-b73a4b99ad62" \
    ttl=1h
````

Para hacer uso del Secret Engine para generar nuevas Keys haciendo uso del Role que le hemos configurado ejecutamos lo siguiente:

````
vault read azure/creds/my-role
````

Alternativamente, podemos crear tambien el role con un Scope especifico! por ejemplo acotando los permisos a un Resource Group.

````
vault write azure/roles/my-role-rg ttl=1h azure_roles=-<<EOF
    [
        {
            "role_name": "Contributor",
            "scope":  "/subscriptions/7175fc39-c8ca-43b4-b86f-971366001986/resourceGroups/vault"
        }
    ]
EOF
````

**The Automation Rules** 🤖👍