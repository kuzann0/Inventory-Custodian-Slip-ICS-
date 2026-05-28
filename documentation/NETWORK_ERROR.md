# Network Error
- Managed to reduce the error to 6, localhost:3000 ics-network issue is also fixed
- Review backend url and ports 
- push this
```
Connect.jsx:8 
 GET http://backend/connect.php net::ERR_NAME_NOT_RESOLVED
```

```
Connect.jsx:15 Error connecting to database: TypeError: Failed to fetch
    at connectToDatabase (Connect.jsx:8:32)
    at Connect.jsx:19:5
```
```
Connect.jsx:8 
 GET http://backend/connect.php net::ERR_NAME_NOT_RESOLVED
```
```
Connect.jsx:15 Error connecting to database: TypeError: Failed to fetch
    at connectToDatabase (Connect.jsx:8:32)
    at Connect.jsx:19:5
```
```
LoginForm.jsx:20 
 POST http://backend/login.php net::ERR_NAME_NOT_RESOLVED
 ```
 ```
LoginForm.jsx:65 Login error: TypeError: Failed to fetch
    at handleLogin (LoginForm.jsx:20:35)
```