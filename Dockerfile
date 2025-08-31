FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine3.22-amd64@sha256:4ae091be9436500f2ea98e044bfa5482d1e1235fae79d53117f923a686edfec9 AS build
WORKDIR /src

# Copy the rest of the source
COPY FinancialCalculator.csproj .
RUN dotnet restore FinancialCalculator.csproj
# Publish app
COPY . .
RUN dotnet build "FinancialCalculator.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "FinancialCalculator.csproj" -c Release -o /app/publish

# Use nginx to serve static files
FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html

# Remove default nginx static content
RUN rm -rf ./*

# Copy published Blazor WASM app
COPY --from=publish /app/publish/wwwroot .

# Nginx serves on port 80
EXPOSE 80
