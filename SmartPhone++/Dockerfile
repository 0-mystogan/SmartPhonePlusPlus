FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5130 
ENV ASPNETCORE_URLS=http://+:5130

# Add font support for QuestPDF
RUN apt-get update && apt-get install -y \
    fonts-liberation \
    fonts-dejavu \
    fonts-noto \
    && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .

FROM build AS publish
RUN dotnet publish "SmartPhone.WebAPI/SmartPhone.WebAPI.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
COPY SmartPhone.WebAPI/Assets ./Assets

# Debug: List contents to verify Assets folder
RUN ls -la /app/
RUN ls -la /app/Assets/ || echo "Assets folder not found"

ENTRYPOINT ["dotnet", "SmartPhone.WebAPI.dll"]