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
ENV VITE_API_URL=http://localhost:8080

# Start Vite development server
# --host 0.0.0.0 allows connections from outside the container
# --port 5173 uses the default Vite port
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
