SELECT *
  FROM [CM_LTS].[dbo].[v_HS_SYSTEM_CONSOLE_USAGE]
  where  agentid is not null and resourceid=16816189
  order by timestamp desc



select cu0.ResourceID,cu0.TopConsoleUser0, max(tt) mtt
from [v_HS_SYSTEM_CONSOLE_USAGE] cu0 inner join
		  (select resourceid,TopConsoleUser0, sum(totalconsoletime0) totalTime
		  from   [CM_LTS].[dbo].[v_HS_SYSTEM_CONSOLE_USAGE]
		  where TopConsoleUser0 IS NOT NULL
		  group by resourceid,TopConsoleUser0 order by resourceid) as consoletime on cu0.TopConsoleUser0=consoletime.tt
group by cu0.ResourceID,cu0.TopConsoleUser0



SELECT        ResourceID, TopConsoleUser0,u.TotalConsoleTime0
            FROM            v_HS_SYSTEM_CONSOLE_USAGE AS u
            WHERE  resourceid=16816189 and      (SUBSTRING(TopConsoleUser0, 1, 4) = 'lmhs') AND TimeStamp =
                        (SELECT        MAX(TimeStamp) AS Expr1
                        FROM            v_HS_SYSTEM_CONSOLE_USAGE AS u2
                        WHERE        (u.ResourceID = ResourceID) AND (TopConsoleUser0 IS NOT NULL))
--where resourceid=16816189

SELECT        ResourceID, TopConsoleUser0,u.TotalConsoleTime0
            FROM            v_HS_SYSTEM_CONSOLE_USAGE AS u
            WHERE  resourceid=16816189 and      (SUBSTRING(TopConsoleUser0, 1, 4) = 'lmhs') AND sum( TotalConsoleTime0)=
                        (SELECT        sum(TotalConsoleTime0) AS Expr1
                        FROM            v_HS_SYSTEM_CONSOLE_USAGE AS u2
                        WHERE        (u.ResourceID = ResourceID) AND (TopConsoleUser0 IS NOT NULL))


update sccm.computers
set TopConsoleUser=tcu.topconsoleuser0
from
(select cu0.resourceid, totaltime, topconsoleuser0 from sccm.consoleusage cu0 inner join
(select resourceid, max(totaltime) maxTime
from sccm.consoleusage cu
group by cu.resourceid) as cu1 on cu0.resourceid=cu1.resourceid and cu0.totaltime=cu1.maxTime
) as TCU
where sccm.computers.resourceid=tcu.resourceid