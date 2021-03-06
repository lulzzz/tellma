﻿using System.Collections.Generic;

namespace Tellma.Controllers.Dto
{
    /// <summary>
    /// Represents all user settings in a particular tenant
    /// </summary>
    public class UserSettingsForClient
    {
        public int? UserId { get; set; }

        public string ImageId { get; set; }

        public string Name { get; set; }

        public string Name2 { get; set; }

        public string Name3 { get; set; }

        public string PreferredLanguage { get; set; }

        public string PreferredCalendar { get; set; }

        public Dictionary<string, string> CustomSettings { get; set; } = new Dictionary<string, string>();
    }
}
