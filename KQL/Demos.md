# Azure Firewall KQL Demos

## Top Blocked Destinations

```kusto
union AZFWApplicationRule, AZFWNetworkRule
| where TimeGenerated > ago(7d)
| where Action =~ 'Deny'
| extend Destination = coalesce(Fqdn, DestinationIp)
| summarize Count = count() by Destination, DestinationPort, Type
| sort by Count desc
```


## Non-standard Port Destinations

```kusto
// IANA Service Names and Port Numbers for lookup
let PortList = externaldata (ServiceName: string, PortNumber: int, TransportProtocol: string, Description: string, Assignee: string, Contact: string, RegistrationDate: string, ModificationDate: string, Reference: string, ServiceCode: string, UnauthorizedUseReported: string, AssignmentNotes: string)
    [@"http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.csv"
    ] with(format="csv", ignoreFirstRecord=true);
// Query access to non standard ports
union AZFWApplicationRule, AZFWNetworkRule
| where TimeGenerated > ago(7d)
| where Action =~ 'Deny'
| extend Destination = coalesce(Fqdn, DestinationIp)
| where DestinationPort !in (80, 443)
| join kind=leftouter PortList on $left.DestinationPort == $right.PortNumber
| project TimeGenerated, SourceIp, Action, DestinationPort, ServiceName, Description, Protocol
```