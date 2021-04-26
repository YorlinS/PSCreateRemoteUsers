$creds = Import-CliXml -Path /etc/ansible/scripts/PowerShell/config.xml

#Importeren van de benodigde module voor active directory
#Import-Module activedirectory

#Store the data from users.csv in the $ADUsers variable
$ADUsers = Import-csv -Path /etc/ansible/scripts/PowerShell/users_challenge.csv

$dc = New-PSSession -ComputerName "172.16.1.5" -Credential $creds -Authentication Negotiate

foreach ($User in $ADUsers)
{
    $Username   = $User.username
    $Password   = $User.password
    $Firstname  = $User.firstname
    $Lastname   = $User.lastname
    $OU         = $User.ou 
    $email      = $User.email
    $telephone  = $User.telephone
    $jobtitle   = $User.jobtitle
    $department = $User.department
    $Password   = $User.password
   

Invoke-Command -Session $dc -ScriptBlock {
    #Importeren van de benodigde module voor active directory
    Import-Module activedirectory

    if (Get-ADUser -F { SamAccountName -eq $Using:Username}) {
        Write-Warning "Het account met gebruikersnaam: $Using:Username bestaat al"  
    }else{
        
        New-ADUser `
        -SamAccountName $Using:Username `
        -UserPrincipalName "$Using:Username@knutelclub.local" `
        -Name "$Using:Firstname $Using:Lastname" `
        -GivenName $Using:Firstname `
        -Surname $Using:Lastname `
        -Enabled $True `
        -Path $Using:OU `
        -DisplayName "$Using:Firstname $Using:Lastname" `
        -OfficePhone $Using:telephone `
        -EmailAddress $Using:email `
        -Title $Using:jobtitle `
        -Department $Using:department `
        -AccountPassword (ConvertTo-SecureString $Using:Password -AsPlainText -Force) -ChangePasswordAtLogon $True
    
        Write-Host "Gebruiker met gebruikersnaam: $Using:Username is aangemaakt" -ForegroundColor Cyan
    }

    
}
}
