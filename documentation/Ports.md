# PORTS

---

## Vite Live Server: localhost:8082

---

## PHP/Apache: localhost:8080

---

```Database: localhost:8080
   user:  root
   pass: rootpassword
```

---

## phpMyAdmin: localhost:8086

-
-

# UPDATED PORT (03-28-26)

`http://127.0.0.1:3000`

## 🔐 Access Routes

| URL                                | Protected             | Purpose            |
| ---------------------------------- | --------------------- | ------------------ |
| `http://127.0.0.1:3000/`           | No                    | Login page         |
| `http://127.0.0.1:3000/verify-otp` | Yes (OTP Session)     | OTP verification   |
| `http://127.0.0.1:3000/dashboard`  | Yes (Session Token)   | Main inventory app |
| `http://127.0.0.1:3000/superadmin` | Yes (SuperAdmin Only) | Admin management   |
