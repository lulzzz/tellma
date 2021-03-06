﻿using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Tellma.Entities
{
    [EntityDisplay(Singular = "DocumentStateChange", Plural = "DocumentStateChanges")]
    public class DocumentStateChange : EntityWithKey<int>
    {
        [NotNull]
        public int? DocumentId { get; set; }

        [Display(Name = "StateHistory_FromState")]
        [NotNull]
        public short? FromState { get; set; }

        [Display(Name = "StateHistory_ToState")]
        [NotNull]
        public short? ToState { get; set; }

        [Display(Name = "ModifiedAt")]
        [NotNull]
        public DateTimeOffset? ModifiedAt { get; set; }

        [Display(Name = "ModifiedBy")]
        [NotNull]
        public int? ModifiedById { get; set; }

        // For Query

        [Display(Name = "ModifiedBy")]
        [ForeignKey(nameof(ModifiedById))]
        public User ModifiedBy { get; set; }
    }
}
