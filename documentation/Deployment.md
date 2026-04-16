# <b>ICS System Deployment Guide (Online + Offline)</b>

This guide explains how to run the ICS system both **online** (publicly accessible) and **offline** (local office use), plus common troubleshooting steps.

## 1. Frontend (React)

### Online

- Build with: `npm run build`
- Push to GitHub
- Connect GitHub → Netlify (or Vercel)
- Netlify builds automatically and gives you a free domain: `https://yourapp.netlify.app`

### Offline

- Run locally with: `npm start`
- Or use Docker Compose
- Access via: `http://localhost:3000`

## 2. Backend (PHP + MySQL)

### Online

- Sign up for a free PHP/MySQL host (InfinityFree, 000webhost, AwardSpace)
- Upload PHP files (`submit.php`, `get_entries.php`) via FileZilla to `public_html/`
- Create a MySQL database in the host’s control panel
- Import your `entries` table schema via phpMyAdmin
- Update PHP connection settings:

  ```php
  $servername = "host_mysql_server";
  $username   = "db_user";
  $password   = "db_password";
  $dbname     = "db_name";
  ```

  Offline

- Use Docker Compose to run PHP + MySQL locally
- Access via: http://localhost:8080

3. Environment Toggle
   Use environment variables to switch between online and offline modes.
   .env (offline mode)
   REACT_APP_API_URL=http://localhost:8080

.env.production (online mode)
REACT_APP_API_URL=https://yourbackend.freehost.com


(replace yourbackend.freehost.com with your actual hosting domain) 4. React Fetch Example
fetch(`${process.env.REACT_APP_API_URL}/get_entries.php`)
.then(res => res.json())
.then(data => setEntries(data))
.catch(err => console.error("Error fetching entries:", err));

 5. Troubleshooting
Blank Table

- Check browser console (console.log(data))
- If [], DB query returned no rows
- If keys don’t match (full_name vs name), update JSX accordingly
  PHP Errors
- Ensure get_entries.php starts with:
  header("Access-Control-Allow-Origin: \*");
  header("Content-Type: application/json");
- Suppress warnings during testing:
  error_reporting(0);

Database Reset (IDs start at 1)

- To clear and reset: TRUNCATE TABLE entries;
- To reset without deleting: ALTER TABLE entries AUTO_INCREMENT = 1;
  CORS Issues
- Add in PHP:
  header("Access-Control-Allow-Origin: \*");

✅ Result

- Online: React frontend on Netlify + PHP/MySQL backend on free hosting
- Offline: Full stack runs locally via Docker
- Toggle: Switch .env files to change mode without editing code
- Troubleshooting: Quick fixes for blank tables, PHP errors, DB reset, and CORS

---

This file is ready to paste into your repo — it’s concise, complete, and covers deployment, offline/online toggle, and troubleshooting in one place.

## .env (offline mode)

REACT_APP_API_URL=http://localhost:8080

## .env (online mode)

REACT_APP_API_URL=https://yourbackend.freehost.com
<br><i>(replace yourbackend.freehost.com with your actual hosting domain)</i>
<br>
<br>

## 4. React Fetch Example

```
fetch(`${process.env.REACT_APP_API_URL}/get_entries.php`)
  .then(res => res.json())
  .then(data => setEntries(data))
  .catch(err => console.error("Error fetching entries:", err));
```

<br>
<br>

## 5. Troubleshooting

**Blank Table**

- Check browser console (console.log(data))
- If [], DB query returned no rows
- If keys don’t match (full_name vs name), update JSX accordingly
  PHP Errors
  <br>
  <br>

**PHP Errors**

- Ensure get_entries.php starts with:

```
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
```

- Suppress warnings during testing:

```
error_reporting(0);
```

**CORS Issues**

- Add in PHP:

```
header("Access-Control-Allow-Origin: \*");
```
