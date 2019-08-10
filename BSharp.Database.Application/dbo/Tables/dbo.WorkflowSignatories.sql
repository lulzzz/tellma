﻿CREATE TABLE [dbo].[WorkflowSignatories] (
	[Id]			INT					PRIMARY KEY IDENTITY,
	[WorkflowId]	INT					NOT NULL CONSTRAINT [FK_WorkflowSignatories__WorkflowId] FOREIGN KEY ([WorkflowId]) REFERENCES [dbo].[Workflows] ([Id]) ON DELETE CASCADE,
	-- All roles are needed to get to next positive state, one is enough to get to negative state
	[RoleId]		INT					NOT NULL CONSTRAINT [FK_WorkflowSignatories__RoleId] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Roles] ([Id]),

	[CreatedAt]		DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET(),
	[CreatedById]	INT					NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')) 	CONSTRAINT [FK_WorkflowSignatories__CreatedById] FOREIGN KEY ([CreatedById]) REFERENCES [dbo].[Users] ([Id]),
	
	[RevokedAt]		DATETIMEOFFSET(7),
	[RevokedById]	INT					CONSTRAINT [FK_WorkflowSignatories__RevokedById] FOREIGN KEY ([RevokedById]) REFERENCES [dbo].[Users] ([Id])
);