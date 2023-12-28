
create procedure [dbo].[update_latest_version] as 
begin try
update a
set mostrecentSP = 'Y'
from [dbo].[latestVersion] a
inner join (

select SQLServer,Servicepack, max(version) 'latest_version' from (
SELECT row_number() over(partition by SqlServer,ServicePack order by version) as 'Rwo'
      ,[SQlServer]
      ,[version]
      ,[servicePack]
      ,[CUNumber]
      ,[mostRecentSP]
      ,[mostRecentVersion]
  FROM [dbo].[latestVersion]) t 
  group by SQLServer, Servicepack) b on a.SQlServer = b.SQlServer and a.servicePack = b.servicePack and a.version = b.latest_version
  

  update a
set [mostRecentVersion] = 'Y'
from [dbo].[latestVersion] a
inner join (

select SQLServer, max(version) 'latest_version' from (
SELECT row_number() over(partition by SqlServer order by version) as 'Rwo'
      ,[SQlServer]
      ,[version]
      ,[servicePack]
      ,[CUNumber]
      ,[mostRecentSP]
      ,[mostRecentVersion]
  FROM [dbo].[latestVersion]) t 
  group by SQLServer) b on a.SQlServer = b.SQlServer  and a.version = b.latest_version

  update [dbo].[latestVersion]
  set mostRecentSP = 'N'
  where mostRecentSP is null

  update [dbo].[latestVersion]
  set mostRecentVersion = 'N'
  where mostRecentVersion is null 
end try
begin catch
throw
end catch

GO