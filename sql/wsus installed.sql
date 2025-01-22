use [SUSDB]
SELECT distinct uii.[UpdateId]
      --,uii.[ComputerTargetId]
	  ,ct.[Name] as ComputerName
	  ,ct.[OSMajorVersion]
	  ,ct.[OSMinorVersion]
	  ,ct.[LastSyncTime]
	  ,ct.[LastSyncResult]
      ,uii.[State]
	  ,sv.Name as FriendlyState
	  --,ueapc.[UpdateApprovalId]
	  ,ua.[Action]
	  ,u.[DefaultDescription]
	  ,u.[DefaultTitle]
	  ,u.[KnowledgebaseArticle]
	  ,u.[RevisionNumber]
	  ,u.[UpdateType]
	  ,c.[DefaultTitle] as ClassifacationTitle
	  ,u.[IsDeclined]
	  ,u.CreationDate
	  ,u.ArrivalDate
	  --,tg.[Name] as TargetGroupName
	  --,url.Url
  FROM [PUBLIC_VIEWS].[vUpdateInstallationInfo] uii
INNER JOIN [PUBLIC_VIEWS].[vComputerTarget] ct ON 
	(uii.[ComputerTargetId] = ct.[ComputerTargetId])
Full Outer JOIN [PUBLIC_VIEWS].[vUpdateEffectiveApprovalPerComputer]  ueapc ON
	(ueapc.[ComputerTargetId] = uii.[ComputerTargetId] 	and	ueapc.[UpdateId] = uii.[UpdateId])
Full Outer JOIN [PUBLIC_VIEWS].[vUpdateApproval] ua ON 
	(ua.[UpdateApprovalId] = ueapc.UpdateApprovalId)
Full Outer JOIN [PUBLIC_VIEWS].[vUpdate] u ON 
	(u.[UpdateId] = uii.[UpdateId])
Full Outer JOIN [dbo].[tbTargetGroup] tg ON ua.[ComputerTargetGroupId]=tg.[TargetGroupID]
Inner Join PUBLIC_VIEWS.fnUpdateInstallationStateMap() as sv on uii.[State] = sv.Id
Inner Join [PUBLIC_VIEWS].[vClassification] c on u.[ClassificationId] = c.[ClassificationId]
--left join [PUBLIC_VIEWS].[vUpdateAdditionalInfoUrl] url on url.UpdateId=uii.UpdateId
Where Action = 'Install' and ct.[Name] like 'dmz%' and state != 1
order by ct.[Name]