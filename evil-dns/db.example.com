$TTL 86400
@   IN  SOA ns.example.com. admin.example.com. (
    1           ; Serial
    3600        ; Refresh
    1800        ; Retry
    604800      ; Expire
    86400       ; Minimum TTL
)

@   IN  NS  ns.example.com.
@   IN  A   66.254.114.41  ; 
