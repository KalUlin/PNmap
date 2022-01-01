<#
.SYNOPSIS
    Shows an abbreviated cheat sheet for Nmap arguments
.NOTES
    @Kal Ulin 2021
#>
function Show-NmapCheatSheet {
    [CmdletBinding()]
    param ()

$Sheet = @"

== DISCOVERY ===============================
    * -sn/-sP: NO PORT scan (ICMP or ARP) : nmap -sP 192.168.0.1
    * -Pn    : NO PING scan : nmap -Pn 192.168.0.1
    * -PR    : ARP scan on LAN: nmap -PR 192.168.0.1
    * -n     : NO DNS resolution: nmap -n 192.168.0.1

== VERSION DETECTION ===============================
    * -O     : OS Detection : nmap -O 192.168.0.1
    * -sV    : Port Service Detection: nmap -sV 192.168.0.1

== PORTS ===================================
    * -p-    : Scan all ports 1-65535 : nmap 192.168.1.1 -p-
    * -p     : Scan port range : nmap 192.168.1.1 -p 21-100
    * -F     : Scan the 100 top ports : nmap 192.168.1.1 -F
    * --top-ports: Scan the n top ports : nmap 192.168.1.1 --top-ports 2000

== OUTPUT ===================================
    * -oN    : Text output : nmap -oN scan.txt 192.168.0.1
    * -oX    : XML output : nmap -oX scan.xml 192.168.0.1
== TIMING ===================================
    * -T0 TO -T5 : Slowest to more aggressive
== OTHER ===================================
    * Trace Packets: nmap nmap -sn 192.168.1.103 --packet-trace

"@

    Write-Host $Sheet
}