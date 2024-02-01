FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /App

EXPOSE 80
EXPOSE 443

COPY ./public_data_api ./
ENTRYPOINT ["dotnet", "GovUk.Education.ExploreEducationStatistics.Public.Data.Api.dll"]