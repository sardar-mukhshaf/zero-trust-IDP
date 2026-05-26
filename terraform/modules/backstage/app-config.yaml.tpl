app:
  baseUrl: ${base_url}
  title: Zero-Trust IDP

backend:
  baseUrl: ${base_url}
  listen:
    port: 7007
  database:
    client: pg
    connection:
      host: ${db_host}
      port: ${db_port}
      user: ${db_user}
      password: ${db_password}
      database: ${db_name}
  reading:
    allow:
      - host: '*.${base_url}'

auth:
  environment: production
  providers:
    oidc:
      production:
        clientId: backstage
        clientSecret: ${db_password}
        metadataUrl: ${keycloak_url}/realms/${realm_name}/.well-known/openid-configuration
        scope: 'openid profile email groups'
        signIn:
          resolvers:
            - resolver: preferredUsernameMatchingUserEntityName

catalog:
  locations:
    - type: url
      target: https://github.com/example-org/backstage-templates/blob/main/catalog-info.yaml
  rules:
    - allow: [Component, System, API, Resource, Location]

techdocs:
  builder: 'external'
  generator:
    runIn: 'local'
  publisher:
    type: 'awsS3'
    awsS3:
      bucketName: ${techdocs_bucket}
      region: ${aws_region}
      credentials:
        type: IAM

scaffolder:
  defaultAuthor:
    name: Platform Bot
    email: platform@${base_url}
