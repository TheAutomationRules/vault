# Configuración de un Secret Engine en HashiCorp Vault con AWS

## Comandos para la CLI

### Habilitar el Secret Engine de AWS:
```
vault secrets enable aws
```

### Configuración de credenciales de AWS en Secret Engine
```
vault write aws/config/root access_key=AKIASV77SWGDE3RE7I6V secret_key=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 region=eu-central-1
```

### Creación de un Rol con un Policy IAM (recuerda cambiar el <ACCOUNT-ID>)
```
vault write aws/roles/iam-credentials credential_type=iam_user policy_document=-<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
    "Effect": "Allow",
    "Action": [
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
    ],
    "Resource": ["arn:aws:iam::<ACCOUNT-ID>:user/vault-*"]
    },
    {
    "Effect": "Allow",
    "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:PutUserPolicy"
    ],
    "Resource": ["arn:aws:iam::<ACCOUNT-ID>:user/vault-*"],
    "Condition": {
        "StringEquals": {
            "iam:PermissionsBoundary": [
                "arn:aws:iam::<ACCOUNT-ID>:policy/PolicyName"
                    ]
                }
            }
        }
    ]
}
EOF
```
### Creación de una access y secret key desde la CLI

```
vault read aws/creds/iam-credentials
```