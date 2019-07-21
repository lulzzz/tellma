﻿using BSharp.Controllers.Misc;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BSharp.Controllers.DTO
{
    [StrongDto]
    public class RoleForSave<TPermission, TRequiredSignature, TRoleMembership> : DtoForSaveKeyBase<int?>
    {
        [BasicField]
        [Required(ErrorMessage = nameof(RequiredAttribute))]
        [StringLength(255, ErrorMessage = nameof(StringLengthAttribute))]
        [MultilingualDisplay(Name = "Name", Language = Language.Primary)]
        public string Name { get; set; }

        [BasicField]
        [StringLength(255, ErrorMessage = nameof(StringLengthAttribute))]
        [MultilingualDisplay(Name = "Name", Language = Language.Secondary)]
        public string Name2 { get; set; }

        [BasicField]
        [StringLength(255, ErrorMessage = nameof(StringLengthAttribute))]
        [Display(Name = "Code")]
        public string Code { get; set; }

        [BasicField]
        [Display(Name = "Role_IsPublic")]
        public bool IsPublic { get; set; }

        [NavigationProperty(ForeignKey = nameof(Permission.RoleId))]
        [Display(Name = "Permissions")]
        public List<TPermission> Permissions { get; set; } = new List<TPermission>();

        [NavigationProperty(ForeignKey = nameof(RequiredSignature.RoleId))]
        [Display(Name = "Signatures")]
        public List<TRequiredSignature> Signatures { get; set; } = new List<TRequiredSignature>();

        [NavigationProperty(ForeignKey = nameof(RoleMembership.RoleId))]
        [Display(Name = "Members")]
        public List<TRoleMembership> Members { get; set; } = new List<TRoleMembership>();
    }

    public class RoleForSave : RoleForSave<PermissionForSave, RequiredSignatureForSave, RoleMembershipForSave>
    {

    }

    public class Role : RoleForSave<Permission, RequiredSignature, RoleMembership>
    {
        [BasicField]
        [Display(Name = "IsActive")]
        public bool? IsActive { get; set; }

        [Display(Name = "CreatedAt")]
        public DateTimeOffset? CreatedAt { get; set; }

        [ForeignKey]
        [Display(Name = "CreatedBy")]
        public int? CreatedById { get; set; }

        [Display(Name = "ModifiedAt")]
        public DateTimeOffset? ModifiedAt { get; set; }

        [ForeignKey]
        [Display(Name = "ModifiedBy")]
        public int? ModifiedById { get; set; }

        // For Query

        [NavigationProperty(ForeignKey = nameof(CreatedById))]
        public LocalUser CreatedBy { get; set; }

        [NavigationProperty(ForeignKey = nameof(ModifiedById))]
        public LocalUser ModifiedBy { get; set; }
    }
}
