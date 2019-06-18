FROM mcr.microsoft.com/dotnet/core/aspnet:2.2 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build
WORKDIR /src
COPY ["KubeAspNetCore/KubeAspNetCore.csproj", "KubeAspNetCore/"]

RUN dotnet restore "KubeAspNetCore/KubeAspNetCore.csproj"
COPY . .
WORKDIR "/src/KubeAspNetCore"
RUN dotnet build "KubeAspNetCore.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "KubeAspNetCore.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "KubeAspNetCore.dll"]