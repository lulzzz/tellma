﻿using BSharp.Services.Utilities;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BSharp.EntityModel
{
    // Note: The permissions is a semi-weak entity, meaning it does not have its own screen or API
    // Permissions are always retrieved and saved as a child collection of some other strong entity
    // We call it "semi"- weak because it comes associated with more than one strong entity

    public class PermissionForSave : EntityKeyBase<int>
    {
        [Display(Name = "Permission_View")]
        [Required(ErrorMessage = nameof(RequiredAttribute))]
        [StringLength(255, ErrorMessage = nameof(StringLengthAttribute))]
        [AlwaysAccessible]
        public string ViewId { get; set; }

        [Display(Name = "Permission_Role")]
        [AlwaysAccessible]
        public int? RoleId { get; set; }

        [Display(Name = "Permission_Action")]
        [Required(ErrorMessage = nameof(RequiredAttribute))]
        [ChoiceList(new object[] { Constants.Read, Constants.Update, "IsActive", "ResendInvitationEmail", "All" },
            new string[] { "Permission_Read", "Permission_Update", "Permission_IsActive", "ResendInvitationEmail", "View_All" })]
        [AlwaysAccessible]
        public string Action { get; set; }

        [Display(Name = "Permission_Criteria")]
        [StringLength(1024, ErrorMessage = nameof(StringLengthAttribute))]
        [AlwaysAccessible]
        public string Criteria { get; set; }

        [Display(Name = "Permission_Mask")]
        [StringLength(2048, ErrorMessage = nameof(StringLengthAttribute))]
        [AlwaysAccessible]
        public string Mask { get; set; }

        [Display(Name = "Memo")]
        [StringLength(255, ErrorMessage = nameof(StringLengthAttribute))]
        public string Memo { get; set; }
    }

    public class Permission : PermissionForSave
    {
        [Display(Name = "CreatedAt")]
        public DateTimeOffset? CreatedAt { get; set; }

        [Display(Name = "CreatedBy")]
        public int? CreatedById { get; set; }

        [Display(Name = "ModifiedAt")]
        public DateTimeOffset? ModifiedAt { get; set; }

        [Display(Name = "ModifiedBy")]
        public int? ModifiedById { get; set; }

        // For Query

        [ForeignKey(nameof(ViewId))]
        [AlwaysAccessible]
        public View View { get; set; }

        [Display(Name = "Permission_Role")]
        [ForeignKey(nameof(RoleId))]
        [AlwaysAccessible]
        public Role Role { get; set; }

        [Display(Name = "CreatedBy")]
        [ForeignKey(nameof(CreatedById))]
        public User CreatedBy { get; set; }

        [Display(Name = "ModifiedBy")]
        [ForeignKey(nameof(ModifiedById))]
        public User ModifiedBy { get; set; }
    }
}
