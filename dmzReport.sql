
SELECT s.FullDomainName as ServerName,s.OSDescription, 
	case when s.LastDetectLocalTime>getdate()-3 then 'True' else'false' end as 'WSUS Sync', 
	s.createdtime as BuildDate,
	s.Total, s.NoStatus, s.NotApp, s.Needed, s.Failed, s.Installed, s.rate, s.LastDetectLocalTime, 
	kb.CurrentKB, kb.N1KB, kb.N2KB,
	case when ckb.kb is not null then 'True' else 'False' end as CurrentKB,
	case when n1kb.kb is not null then 'True' else 'False' end as N1KB,
	case when n2kb.kb is not null then 'True' else 'False' end as N2KB, s.TargetGroupName
FROM (SELECT        FullDomainName, TargetGroupName, Total, NoStatus, NotApp, Needed, Failed, 
		Installed, rate, LastDetectLocalTime, createdtime,OSDescription, 
		CASE WHEN osdescription LIKE '%2022%' THEN '2022' WHEN osdescription LIKE '%2019%' THEN '2019' END AS OS
		FROM wsus.Servers) AS s LEFT OUTER JOIN 
	 PatchKBs AS kb ON s.OS = kb.OS left join
	(select computername,'KB' + [KnowledgebaseArticle] as KB, arrivaldate
		from wsus.installs) as ckb on ckb.computername=s.fulldomainname and ckb.kb=kb.currentkb left join
	(select computername,'KB' + [KnowledgebaseArticle] as KB, arrivaldate
		from wsus.installs) as n1kb on n1kb.computername=s.fulldomainname and n1kb.kb=kb.n1kb left join
	(select computername,'KB' + [KnowledgebaseArticle] as KB, arrivaldate
		from wsus.installs) as n2kb on n2kb.computername=s.fulldomainname and n2kb.kb=kb.n2kb
	order by s.fulldomainname
