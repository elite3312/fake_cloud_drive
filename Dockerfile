# Use Node.js 16.x as the base image
FROM node:14 AS build-stage

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install Quasar CLI globally
RUN npm install -g @quasar/cli@1.2.1

# Install dependencies
RUN npm install
# update
#RUN npm update
# Copy the rest of the application code
COPY . .

# Build the application using Quasar
RUN quasar build

# Serve the application using Nginx
FROM nginx:alpine AS production-stage

# Copy the built files from the previous stage
COPY --from=build-stage /app/dist/spa /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]