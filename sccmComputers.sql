--*** get heartbeat and swinv date, drive size & free space, ip and subnet
--***write update and insert scripts to retain history
use cm_LTS
SELECT DISTINCT 
        cs.Name0 AS Hostname, cs.ResourceID, cs.TimeStamp, hw.LastHWScan, hb.AgentTime AS Heartbeat, ls.LastScanDate, cs.Manufacturer0, 
		cs.Model0, cs.Status0, cs.UserName0, pcb.Name0 AS BIOSname, pcb.SerialNumber0, pcb.SMBIOSBIOSVersion0, pcb.ReleaseDate0 AS BIOSreleaseDate, 
		os.BootDevice0, os.BuildNumber0, os.Caption0 AS OS, os.CSDVersion0 AS SP, os.InstallDate0, os.LastBootUpTime0, os.Organization0, 
        os.Version0 AS OSversion, s.SMBIOSAssetTag0, ram.TotalPageFileSpace0, ram.TotalPhysicalMemory0 AS PhysicalMemory, ram.TotalVirtualMemory0, 
        hd.FreeSpace00, hd.Size00, TopUser.lastuser
FROM        v_GS_COMPUTER_SYSTEM AS cs LEFT OUTER JOIN
                (SELECT        ResourceID, TopConsoleUser0 as lastUser
                FROM            v_HS_SYSTEM_CONSOLE_USAGE AS u
                WHERE        (SUBSTRING(TopConsoleUser0, 1, 4) = 'lmhs') AND (TimeStamp =
                            (SELECT        MAX(TimeStamp) AS Expr1
                            FROM            v_HS_SYSTEM_CONSOLE_USAGE AS u2
                            WHERE        (u.ResourceID = ResourceID) AND (TopConsoleUser0 IS NOT NULL)))) AS TopUser ON cs.ResourceID = TopUser.ResourceID LEFT OUTER JOIN
                (SELECT        MachineID, FreeSpace00, Size00
                FROM            Logical_Disk_DATA
                WHERE        (DeviceID00 = 'C:')) AS hd ON cs.ResourceID = hd.MachineID LEFT OUTER JOIN
                (SELECT        ResourceId, AgentName, MAX(AgentTime) AS AgentTime
                FROM            v_AgentDiscoveries
                WHERE        (AgentName = 'Heartbeat Discovery')
                GROUP BY ResourceId, AgentName) AS hb ON cs.ResourceID = hb.ResourceId LEFT OUTER JOIN
            v_GS_LastSoftwareScan AS ls ON cs.ResourceID = ls.ResourceID AND hb.AgentTime > ls.LastScanDate + 10 LEFT OUTER JOIN
            v_GS_X86_PC_MEMORY AS ram ON cs.ResourceID = ram.ResourceID LEFT OUTER JOIN
            v_GS_OPERATING_SYSTEM AS os ON cs.ResourceID = os.ResourceID LEFT OUTER JOIN
                (SELECT        ResourceID, SMBIOSAssetTag0
                FROM            v_GS_SYSTEM_ENCLOSURE
                WHERE        (SMBIOSAssetTag0 <> '')) AS s ON cs.ResourceID = s.ResourceID LEFT OUTER JOIN
            v_GS_PC_BIOS AS pcb ON cs.ResourceID = pcb.ResourceID LEFT OUTER JOIN
            v_GS_WORKSTATION_STATUS AS hw ON hw.ResourceID = cs.ResourceID
where cs.Name0 like 'dmz%'

--cs.Name0 in (
--'w4334521',
--'w4379657'
--)                      

--SELECT [MachineID]
--      ,[MachineConfiguration00]
--      ,[OU00]
--  FROM [CM_SCA].[dbo].[Machine_Configuration_Info_DATA]
--  where [MachineConfiguration00]<>''
                      
--CREATE TABLE [SCCM].[ARP] (
--[ResourceID] int NOT NULL,
--[DisplayName] nvarchar(255),
--[InstallDate] nvarchar(255),
--[Publisher] nvarchar(255),
--[Version] nvarchar(255),
--[pkid] [int] IDENTITY(1,1) NOT NULL
--)
--GO
---sccm 2007 
--use SMS_CEN                    
--SELECT  top(100)   cs.Name0, cs.ResourceID, cs.TimeStamp, cs.Manufacturer0, cs.Model0, cs.Status0, cs.UserName0, ls.LastScanDate, pcb.Name0 AS Expr4, pcb.SerialNumber0, 
--                      pcb.SMBIOSBIOSVersion0, pcb.ReleaseDate0, os.BootDevice0, os.BuildNumber0, os.Caption0, os.CSDVersion0, os.InstallDate0, os.LastBootUpTime0, 
--                      os.Organization0, os.Version0, s.SMBIOSAssetTag0, ram.TotalPageFileSpace0, ram.TotalPhysicalMemory0 AS Expr10, ram.TotalVirtualMemory0, id.DiskVer0
--FROM         v_GS_COMPUTER_SYSTEM AS cs INNER JOIN
--                      dbo.v_GS_StandardImage_Setting0 AS id ON cs.ResourceID = id.resourceID LEFT OUTER JOIN
--                      v_GS_LastSoftwareScan AS ls ON cs.ResourceID = ls.ResourceID LEFT OUTER JOIN
--                      v_GS_X86_PC_MEMORY AS ram ON cs.ResourceID = ram.ResourceID LEFT OUTER JOIN
--                      v_GS_OPERATING_SYSTEM AS os ON cs.ResourceID = os.ResourceID LEFT OUTER JOIN
--                      v_GS_SYSTEM_ENCLOSURE AS s ON cs.ResourceID = s.ResourceID LEFT OUTER JOIN
--                      v_GS_PC_BIOS AS pcb ON cs.ResourceID = pcb.ResourceID
--where cs.name0='W4334622'
                      
--loadsets
--select resourceid, displayname0 from dbo.v_GS_ADD_REMOVE_PROGRAMS
--where DisplayName0 like 'ls_%'

--machine config's
--SELECT [MachineID]
--      ,[InstanceKey]
--      ,[TimeKey]
--      ,[RevisionID]
--      ,[AgentID]
--      ,[rowversion]
--      ,[Image00]
--      ,[InstanceKey00]
--      ,[LOCATION00]
--      ,[MachineConfiguration00]
--      ,[OU00]
--      ,[PreStage_MC00]
--      ,[TimeStamp00]
--  FROM [CM_SCA].[dbo].[Machine_Configuration_Info_DATA]
--  where machineconfiguration00 is not null and machineconfiguration00<>''  
 --2012 colsole Usage
--SELECT [ResourceID],TopConsoleUser0
--  --    ,[GroupID]
--  --    ,[RevisionID]
--  --    ,[AgentID]
--  --    ,[TimeStamp]
--  --    ,[SecurityLogStartDate0]
--  --    ,[TopConsoleUser0]
--  --    ,[TotalConsoleTime0]
--  --    ,[TotalConsoleUsers0]
--  --    ,[TotalSecurityLogTime0]
--  FROM [CM_SCA].[dbo].[v_HS_SYSTEM_CONSOLE_USage] as u
--  where (topconsoleuser0 is not null and (TimeStamp=
--	(select MAX(timestamp) 
--		from dbo.v_HS_SYSTEM_CONSOLE_USage as u2
--		where u.ResourceID=u2.ResourceID and u2.TopConsoleUser0 is not null)))                    
                      