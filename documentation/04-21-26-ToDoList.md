# v18_ics_sys_

Docker 

---------------------------------------------
use alphine for node file size reduction
FROM node:[node version]-alpine
---------------------------------------------
Layer Squashing

npm run build && \ 
npm cache clean --force && \
rm -rf /root/.npm&& \
rm -rf node_modules


------------------------------------------------

docker-compose.yml:

# version: "3.8"

services:
  # ============================================================================
  # DATABASE SERVICE
  # ============================================================================
  db:
    image: mysql:5.7
    container_name: ics-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: my_app_db
      MYSQL_CHARSET: utf8mb4
      MYSQL_COLLATION: utf8mb4_unicode_ci
    ports:
      - "3307:3306"
    volumes:
      # Persist MySQL data across container restarts
      - mysql_data:/var/lib/mysql
      # Initialize database with backup on first run
      - ./backend/database/entries_backup.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-proot"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - ics-network

  # ============================================================================
  # DATABASE MANAGEMENT INTERFACE (phpMyAdmin)
  # ============================================================================
  phpmyadmin:
    image: phpmyadmin/phpmyadmin:5.2
    container_name: ics-phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: rootpassword
      MYSQL_ROOT_PASSWORD: rootpassword
      PMA_ABSOLUTE_URI: http://localhost:8086/
    ports:
      - "8086:80"
    depends_on:
      db:
        condition: service_healthy
    networks:
      - ics-network

  # ============================================================================
  # BACKEND API SERVICE (PHP/Apache)
  # ============================================================================
  backend:
    image: v17_backend:2.0.0
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ics-backend
    restart: unless-stopped
    ports:
      - "3001:80"
    volumes:
      # Mount backend code for live development
      - ./backend:/var/www/html
    environment:
      # Pass database credentials to backend via environment
      MYSQL_HOST: db
      MYSQL_USER: root
      MYSQL_PASSWORD: rootpassword
      MYSQL_DATABASE: my_app_db
      MYSQL_PORT: 330
      
      # ====================================================================
      # MAIL CONFIGURATION (Optional - for email functionality)
      # ====================================================================
      # Email Mode: 'online' or 'offline'
      MAIL_MODE: online
      
      # Gmail SMTP Configuration
      MAIL_HOST: smtp.gmail.com
      MAIL_PORT: 587
      MAIL_USERNAME: your-email@gmail.com
      MAIL_PASSWORD: your-app-password-here
      MAIL_FROM_ADDRESS: noreply@ics-system.local
      MAIL_FROM_NAME: ICS System
      MAIL_ENCRYPTION: tls
      MAIL_VERIFY_SSL: 'false'
      
      # ====================================================================
      # Alternative: Office365 Configuration (uncomment to use)
      # MAIL_HOST: smtp.office365.com
      # MAIL_PORT: 587
      # MAIL_USERNAME: your-email@company.com
      # MAIL_PASSWORD: your-password
      # MAIL_ENCRYPTION: tls
      # MAIL_VERIFY_SSL: 'false'
      # ====================================================================
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/connect.php"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 20s
    networks:
      - ics-network

  # ============================================================================
  # FRONTEND SERVICE (React + Vite Development Server)
  # ============================================================================
  frontend:
    image: v17_frontend:2.0.0
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ics-frontend
    restart: unless-stopped
    ports:
      # Port mapping: host port 3000 → container Vite port 5173
      # Access at: http://127.0.0.1:3000
      - "3000:5173"
    volumes:
      # Mount frontend code for live reloading
      - ./frontend:/app
      # Preserve node_modules in container (don't sync from host)
      - /app/node_modules
    environment:
      # Frontend environment variables
      # Use localhost:3001 for browser access (HMR is 3000, but API is 3001)
      VITE_API_URL: http://localhost:3001
      VITE_HMR_HOST: localhost
      VITE_HMR_PORT: 3000
      VITE_HMR_PROTOCOL: ws
      VITE_APP_NAME: ICS System
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - ics-network
# ============================================================================
# NAMED VOLUMES (Persistent Storage)
# ============================================================================
volumes:
  mysql_data:
    driver: local

# ============================================================================
# CUSTOM NETWORK (Enables service-to-service communication)
# ============================================================================
networks:
  ics-network:
    driver: bridge


Dockerfile:

# Frontend Dockerfile - Production-Ready Development Setup
# This Dockerfile installs npm dependencies during build time (cached layer)
# so that running docker-compose up immediately starts the application

FROM node:22-alpine

WORKDIR /app

# Copy package files first for Docker layer caching
# If package.json hasn't changed, dependencies won't reinstall
COPY package.json package-lock.json* ./

# Install dependencies at build time (not runtime)
# This runs once during build and is cached for subsequent builds
RUN npm install

# Copy the remaining application files
COPY . .

# Expose Vite dev server port (default is 5173)
EXPOSE 5173

# Set environment for Vite dev server
# These can be overridden by docker-compose environment variables
ENV VITE_API_URL=http://127.0.0.1:3001
ENV VITE_HMR_HOST=localhost
ENV VITE_HMR_PORT=5173
ENV VITE_HMR_PROTOCOL=ws

# Start Vite development server
# --host 0.0.0.0 allows connections from outside the container (all interfaces)
# --port 5173 uses the default Vite port
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]


------------------------------------------------
LOST FROM THE UPDATED IMAGE (MUST REDO) 

View Entries table routing 
entries table --> single source for data get and set


(refer to the v17 untouched version in github)
PPE FORMS
NOD FORMS


Serial No
Inventory
Description = Varchar(50)
Date Acquired = Short Date

--------------------------------------------
### What's working:


Login Form --> 
Routing --> DB --> View Entries
Network Fixed (temporary solution)


--------------------------------------------

Once the system's overall worflow is working properly including the forms.

### What to do next:

- Page Routings (polish structure)
- Enhance UI/UX








