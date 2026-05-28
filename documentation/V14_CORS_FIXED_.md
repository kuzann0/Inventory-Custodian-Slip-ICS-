# 14 CORS Error
### Assisted by sir Ralh


## **ROUTING PORTS AND SERVER CONFIGS***
```
vite.config.js
docker-compose.yml
cors.php
```

## **New url: IP Based Testing**
```
VirtualHost --> Default = 8060, 8070, 8080
Listen 3000 and VH *:3000
Device Name == Fixed Host Name
[ICS_SYSTEM = new environmental variable for VirtualHost]
```

## **New url: IP Based Testing**
```
  'http://10.20.10.37:3000',
  'http://10.20.10.37:5173',
```

## **Check Directory Path**
```
<VirtualHost *:3001>
    DocumentRoot "C:/path/to/your/backend"
    <Directory "C:/path/to/your/backend">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

```
