﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BSharp.Data.Model
{
    /// <summary>
    /// A Query type https://docs.microsoft.com/en-us/ef/core/modeling/query-types
    /// Used when bulk inserting entities to retrieve the mapping between the Index
    /// and the Id generated by the database, since SQL has poor support for ordered lists
    /// </summary>
    public class IndexedId
    {
        public int Id { get; set; }

        public int Index { get; set; }
    }
}