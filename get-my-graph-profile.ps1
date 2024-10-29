# Gets graph username from the Graph CLI
Get-MgUser -UserId (Get-MgUser -Filter "userPrincipalName eq '$($organizationEmail)'").Id