﻿using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Tellma.Entities
{
    [StrongEntity]
    [EntityDisplay(Singular = "OutboxRecord", Plural = "OutboxRecords")]
    public class OutboxRecord : EntityWithKey<int>
    {
        [Display(Name = "Assignment_Document")]
        [NotNull]
        public int? DocumentId { get; set; }

        [Display(Name = "Document_Comment")]
        public string Comment { get; set; }

        [Display(Name = "Document_AssignedAt")]
        [NotNull]
        public DateTimeOffset? CreatedAt { get; set; }

        [Display(Name = "Document_Assignee")]
        [NotNull]
        public int? AssigneeId { get; set; }

        [Display(Name = "Document_OpenedAt")]
        public DateTimeOffset? OpenedAt { get; set; }

        // For Query

        [Display(Name = "Assignment_Document")]
        [ForeignKey(nameof(DocumentId))]
        public Document Document { get; set; }

        [Display(Name = "Document_Assignee")]
        [ForeignKey(nameof(AssigneeId))]
        public User Assignee { get; set; }
    }
}
