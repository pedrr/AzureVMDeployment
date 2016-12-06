
###### Traffic Management ######

# DNS Server with views on IPAM demucsipm001
Install-WindowsFeature -Name DNS
#
Update-Help -Module DnsServer
#
Add-DnsServerPrimaryZone -Name s2016.test -ZoneFile s2016.test.dns
#
# Create client subnets that could query the DNS 
Add-DnsServerClientSubnet -Name Subnet-User1 -IPv4Subnet "192.168.16.16/28" -PassThru
Add-DnsServerClientSubnet -Name Subnet-User2 -IPv4Subnet "192.168.16.32/28" -PassThru
Add-DnsServerClientSubnet -Name Subnet-User3 -IPv4Subnet "192.168.16.48/28" -PassThru
Add-DnsServerClientSubnet -Name Subnet-User4 -IPv4Subnet "192.168.16.64/28" -PassThru
Add-DnsServerClientSubnet -Name Subnet-User5 -IPv4Subnet "192.168.16.80/28" -PassThru
Add-DnsServerClientSubnet -Name Subnet-Trainer -IPv4Subnet "192.168.16.0/28" -PassThru


#
# Create scopes for the name resolution
#
Add-DnsServerZoneScope -ZoneName s2016.test -Name "Scope-User1" -PassThru
Add-DnsServerZoneScope -ZoneName s2016.test -Name "Scope-User2" -PassThru
Add-DnsServerZoneScope -ZoneName s2016.test -Name "Scope-User3" -PassThru
Add-DnsServerZoneScope -ZoneName s2016.test -Name "Scope-User4" -PassThru
Add-DnsServerZoneScope -ZoneName s2016.test -Name "Scope-User5" -PassThru
Add-DnsServerZoneScope -ZoneName s2016.test -Name "Scope-Trainer" -PassThru

# 
# Add resource records to be resolved for special scopes
Add-DnsServerResourceRecord -ZoneName s2016.test -A -Name www -IPv4Address "1.1.1.1" -ZoneScope "Scope-User1" -PassThru
Add-DnsServerResourceRecord -ZoneName s2016.test -A -Name www -IPv4Address "2.2.2.2" -ZoneScope "Scope-User2" -PassThru
Add-DnsServerResourceRecord -ZoneName s2016.test -A -Name www -IPv4Address "3.3.3.3" -ZoneScope "Scope-User3" -PassThru
Add-DnsServerResourceRecord -ZoneName s2016.test -A -Name www -IPv4Address "4.4.4.4" -ZoneScope "Scope-User4" -PassThru
Add-DnsServerResourceRecord -ZoneName s2016.test -A -Name www -IPv4Address "5.5.5.5" -ZoneScope "Scope-User5" -PassThru
Add-DnsServerResourceRecord -ZoneName s2016.test -A -Name www -IPv4Address "11.11.11.11" -ZoneScope "Scope-Trainer" -PassThru
#
# Add client subnets to scopes
Add-DnsServerQueryResolutionPolicy -Name "Policy-Zone1" -Action ALLOW -ClientSubnet "eq,Subnet-User1" -ZoneScope "Scope-User1,1" -ZoneName s2016.test -PassThru
Add-DnsServerQueryResolutionPolicy -Name "Policy-Zone2" -Action ALLOW -ClientSubnet "eq,Subnet-User2" -ZoneScope "Scope-User2,1" -ZoneName s2016.test -PassThru
Add-DnsServerQueryResolutionPolicy -Name "Policy-Zone3" -Action ALLOW -ClientSubnet "eq,Subnet-User3" -ZoneScope "Scope-User3,1" -ZoneName s2016.test -PassThru
Add-DnsServerQueryResolutionPolicy -Name "Policy-Zone4" -Action ALLOW -ClientSubnet "eq,Subnet-User4" -ZoneScope "Scope-User4,1" -ZoneName s2016.test -PassThru
Add-DnsServerQueryResolutionPolicy -Name "Policy-Zone5" -Action ALLOW -ClientSubnet "eq,Subnet-User5" -ZoneScope "Scope-User5,1" -ZoneName s2016.test -PassThru
Add-DnsServerQueryResolutionPolicy -Name "Policy-Trainer" -Action ALLOW -ClientSubnet "eq,Subnet-Trainer" -ZoneScope "Scope-Trainer,1" -ZoneName s2016.test -PassThru

# Ping to www for different name resolution ##


######## Block Query to specific domain #####

Add-DnsServerQueryResolutionPolicy -Name "Policy-Blackhole" -Action IGNORE -Fqdn "eq,*.kuderna.de"

#Block query from specific subnet ##

Add-DnsServerQueryResolutionPolicy -Name "Policy-DenyUser1" -Action IGNORE -ClientSubnet "eq,Subnet-User1"

 
