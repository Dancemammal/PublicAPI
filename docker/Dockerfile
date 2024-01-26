FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5010

ENV ASPNETCORE_URLS=http://+:5010

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["src/GovUk.Education.ExploreEducationStatistics.Public.Data.Api/GovUk.Education.ExploreEducationStatistics.Public.Data.Api.csproj", "src/GovUk.Education.ExploreEducationStatistics.Public.Data.Api/"]
RUN dotnet restore "src/GovUk.Education.ExploreEducationStatistics.Public.Data.Api/GovUk.Education.ExploreEducationStatistics.Public.Data.Api.csproj"
COPY . .
WORKDIR "/src/src/GovUk.Education.ExploreEducationStatistics.Public.Data.Api"
RUN dotnet build "GovUk.Education.ExploreEducationStatistics.Public.Data.Api.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "GovUk.Education.ExploreEducationStatistics.Public.Data.Api.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "GovUk.Education.ExploreEducationStatistics.Public.Data.Api.dll"]
