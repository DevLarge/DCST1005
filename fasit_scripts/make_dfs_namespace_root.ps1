Invoke-Command -ComputerName srv1 -ScriptBlock {
    # Create new DFS namespace
    New-DfsnRoot -TargetPath "\\srv1\files" `
                 -Path "\\InfraIT.sec\files" `
                 -Type DomainV2 `
                 -GrantAdminAccounts "infrait\Domain Admins"
}