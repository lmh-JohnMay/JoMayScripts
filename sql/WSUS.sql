--DMZ machines are on lmh-SQL17inst1
use susdb;
With cteUpdateInstallationInfo As(
 SELECT u.UpdateID
 , ct.ComputerID 
 , (CASE WHEN usc.SummarizationState IS NULL OR usc.SummarizationState = 1 THEN 
	(CASE WHEN ISNULL(u.LastUndeclinedTime, u.ImportedTime) < ct.EffectiveLastDetectionTime THEN 
	1 ELSE 0 END) ELSE usc.SummarizationState END) AS State
  FROM       dbo.tbUpdate AS u 
  JOIN       dbo.tbRevision AS r ON u.LocalUpdateID = r.LocalUpdateID And r.IsLatestRevision = 1
  JOIN       dbo.tbProperty AS p ON r.RevisionID = p.RevisionID And p.ExplicitlyDeployable = 1
  CROSS JOIN dbo.tbComputerTarget AS ct 
  LEFT JOIN  dbo.tbUpdateStatusPerComputer AS usc ON u.LocalUpdateID = usc.LocalUpdateID AND ct.TargetID = usc.TargetID
  WHERE u.IsHidden = 0
), Summary as(
  Select ComputerId
  , Count(*)  as Total
  , Sum(case When State = 0 Then 1 else 0 end)       as NoStatus
  , Sum(case When State = 1 Then 1 else 0 end)       as NotApp
  , Sum(case When State In(2,3,6) Then 1 else 0 end) as Needed
  , Sum(case When State = 4 Then 1 else 0 end)       as Installed
  , Sum(case When State = 5 Then 1 else 0 end)       as Failed
  , Sum(case When State = 1 Then 1 else 0 end) + Sum(case When State = 4 Then 1 else 0 end)as pp
  From cteUpdateInstallationInfo
  Group by ComputerId
), TimeZone as (Select DATEDIFF(mi, GetUtcDate(), GetDate()) as TimeZoneMinutes)
Select --ct.ComputerId
	ct.FullDomainName 
, ct.IPAddress
, tg.Name as TargetGroupName
, Total, NoStatus, NotApp, Needed, Failed, Installed, format(convert(decimal(10,2),pp)/convert(decimal(10,2),total),'N4') AS rate
, Dateadd(mi, TimeZoneMinutes, ct.EffectiveLastDetectionTime) As LastDetectLocalTime
, Dateadd(mi, TimeZoneMinutes, ct.LastReportedStatusTime) as LastReportLocalTime
, Dateadd(mi, TimeZoneMinutes, ct.LastSyncTime) As LastContactLocalTime
, LastSyncResult    
, Dateadd(mi, TimeZoneMinutes, ct.LastReportedRebootTime) As LastRebootLocalTime
, Dateadd(mi, TimeZoneMinutes, ct.LastInventoryTime) As LastInventoryLocalTime
, Dateadd(mi, TimeZoneMinutes, ct.LastNameChangeTime) As LastNameChangeLocalTime
--, IsRegistered
--, OSMajorVersion, OSMinorVersion, OSBuildNumber, OSServicePackMajorNumber,OSServicePackMinorNumber
, OSLocale
, ComputerMake
, ComputerModel
, BiosVersion
, BiosName
, BiosReleaseDate
, CreatedTime
, ProcessorArchitecture
--, LastStatusRollupTime    LastReceivedStatusRollupNumber  LastSentStatusRollupNumber
--, SamplingValue, CreatedTime, SuiteMask, OldProductType, NewProductType, SystemMetrics
, ClientVersion
--, TargetGroupMembershipChanged
, OSFamily
, OSDescription
, OEM
, DeviceType
, FirmwareVersion
, MobileOperator    
From Summary as s 
	Join TimeZone as tz on 1=1
	JOIN dbo.tbComputerTarget AS ct on ct.ComputerID = s.ComputerId
	Join tbComputerTargetDetail ctd on ctd.TargetId = ct.TargetId
	Join tbTargetInTargetGroup tgct on tgct.TargetId = ct.TargetId
	Join tbTargetGroup tg on tg.TargetGroupId = tgct.TargetGroupId
--where ct.FullDomainName like 'dmz%'
where OSDescription like 'Windows Server%'

--Also as a bonus here is a summary by update:

--With Summary as(
--  Select UpdateId
--  , Count(*)  as Total
--  , Sum(case When State = 0 Then 1 else 0 end)     as NoStatus
--  , Sum(case When State = 1 Then 1 else 0 end)     as NotApp
--  , Sum(case When State In(2,3,6) Then 1 else 0 end) as Needed
--  , Sum(case When State = 4 Then 1 else 0 end)     as Installed
--  , Sum(case When State = 5 Then 1 else 0 end)     as Failed
--  From PUBLIC_VIEWS.vUpdateInstallationInfo
--  Group BY UpdateId
--), TimeZone as (
-- Select DATEDIFF(mi, GetUtcDate(), GetDate()) as TimeZoneMinutes
--)
--Select s.UpdateId
--, u.IsDeclined
--, u.PublicationState
--, u.DefaultTitle as Title
--, u.KnowledgebaseArticle as KBArticle
--, Total, NoStatus, NotApp, Needed, Failed, Installed 
--, Dateadd(mi, TimeZoneMinutes, u.CreationDate) As ReleaseLocalTime
--, Dateadd(mi, TimeZoneMinutes, u.ArrivalDate) As ArrivalLocalTime
--From summary as s
--Join TimeZone as tz on 1=1
--Join PUBLIC_VIEWS.vUpdate as u on u.UpdateID = s.UpdateId