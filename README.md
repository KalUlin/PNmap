# PNmap
Simple Powershell wrapper module for Nmap

Performs the following:
    * Converts Nmap output to a Powershell Object
    * Automatically exports this object to a CSV file
    * Exposes the Nmap Powershell Object to the Global scope for further manipulation by the user
    * Displays the regular Nmap output as well as the Nmap Powershell Object as a list or table

## EXAMPLE
    invoke-pnmap -Target '10.1.11.1' -Preset PingScan
    invoke-pnmap "10.1.11.1/24" "-T4 -F -n"

    Can also be used with the alias 'pnmap'
    pnamp -Target "10.1.22.0/24" -ArgumentString "-T4 -F -n"

![Demo](./images/Animation.gif)