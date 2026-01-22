# https://github.com/torivarm/dcst1005/blob/main/Guides/02-05-CreateADUsers.md 
# https://github.com/torivarm/dcst1005/blob/main/Guides/02-06-AddUsersToGroup.md 


# DOESNT WORK; TRIED IT MYSELF


function Create-User {
    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Surname,

        [Parameter(Mandatory=$false)]
        [String] $Description,

        [Parameter(Mandatory=$false)]
        [String] $Office,

        [Parameter(Mandatory=$false)]
        [String] $Company = "Infrastruktur Corp.",

        [Parameter(Mandatory=$false)]
        [String] $Department = "IT",

        [Parameter(Mandatory=$false)]
        [String] $Title = "Employee",

        [Parameter(Mandatory=$false)]
        [String] $City = "Trondheim",

        [Parameter(Mandatory=$false)]
        [String] $Country = "Norway",

        [Parameter(Mandatory=$false)]
        [boolean] $ChangePasswordAtLogon = $false

    )

    $Password = "Testpasswrod"

    $SAM = ($Name + $Surname).toLower()
    if ($SAM.Length -gt 20) {
        Write-Error "SAM cannot be over 20 characters!" -ForegroundColor Red
        exit 1
    }

    $userProperties = @{
        SamAccountName       = "$SAM"
        UserPrincipalName   = "${Name}.@infrait.sec"
        Name                = "$Name $Surname"
        GivenName           = $Name
        Surname            = $Surname
        DisplayName        = "$Name $Surname"
        Description        = "$Description"
        Office             = "$Office"
        Company            = "$Company"
        Department         = "$Department"
        Title              = "$Title"
        City               = "$City"
        Country            = "$Country"
        AccountPassword    = (ConvertTo-SecureString $Password -AsPlainText -Force)
        Enabled            = $true
        ChangePasswordAtLogon = $ChangePasswordAtLogon
    }

    if (Get-ADUser -Identity $SAM) {
        # USer exists, dont create
        Write-Host "This user already exists!" -ForegroundColor Yellow
    } else {
        try {
            New-ADUser @userProperties
        } catch {
            Write-Error "Something wrong happened when tried to create account!" 
        }
        
        Write-Host "User successfully created! with settings:" -ForegroundColor Green
        foreach ($element in $userProperties) {
            Write-Host $element
        }
        Write-Host "Your password is: $Password"
    }
}

Create-User -Name "Testar" -Surname "Testooo"