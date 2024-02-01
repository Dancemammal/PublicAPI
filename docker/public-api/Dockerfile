FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /App
EXPOSE 5010
COPY ./the-artifact-dir/out ./
ENTRYPOINT ["dotnet", "GovUk.Education.ExploreEducationStatistics.Public.Data.Api.dll"]