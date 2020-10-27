﻿using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Tellma.Controllers.Dto;
using Tellma.Controllers.Utilities;
using Tellma.Data.Queries;
using Tellma.Entities;

namespace Tellma.Controllers
{
    /// <summary>
    /// Controllers inheriting from this class allow searching, aggregating and exporting a certain
    /// entity type that inherits from <see cref="EntityWithKey{TKey}"/> using OData-like parameters
    /// and allow selecting a certain record by Id
    /// </summary>
    public abstract class FactGetByIdControllerBase<TEntity, TKey> : FactWithIdControllerBase<TEntity, TKey>
        where TEntity : EntityWithKey<TKey>
    {
        public FactGetByIdControllerBase(IServiceProvider sp) : base(sp)
        {
        }

        [HttpGet("{id}")]
        public virtual async Task<ActionResult<GetByIdResponse<TEntity>>> GetById(TKey id, [FromQuery] GetByIdArguments args, CancellationToken cancellation)
        {
            return await ControllerUtilities.InvokeActionImpl(async () =>
            {
                // Calculate server time at the very beginning for consistency
                var serverTime = DateTimeOffset.UtcNow;

                // Load the data
                var service = GetFactGetByIdService();
                var (entity, extras) = await service.GetById(id, args, cancellation);

                // Load the extras
                var singleton = new List<TEntity> { entity };

                // Flatten and Trim
                var relatedEntities = FlattenAndTrim(singleton, cancellation);

                // Prepare the result in a response object
                var result = new GetByIdResponse<TEntity>
                {
                    Result = entity,
                    RelatedEntities = relatedEntities,
                    CollectionName = GetCollectionName(typeof(TEntity)),
                    Extras = TransformExtras(extras, cancellation),
                    ServerTime = serverTime,
                };
                return Ok(result);
            }, _logger);
        }

        protected override FactWithIdServiceBase<TEntity, TKey> GetFactWithIdService()
        {
            return GetFactGetByIdService();
        }

        protected abstract FactGetByIdServiceBase<TEntity, TKey> GetFactGetByIdService();
    }

    public abstract class FactGetByIdServiceBase<TEntity, TKey> : FactWithIdServiceBase<TEntity, TKey>, IFactGetByIdServiceBase
        where TEntity : EntityWithKey<TKey>
    {
        // Private Fields
        public FactGetByIdServiceBase(IServiceProvider sp) : base(sp)
        {
        }

        /// <summary>
        /// Returns a <see cref="TEntity"/> as per the Id and the specifications in the <see cref="GetByIdArguments"/>, after verifying the user's permissions
        /// </summary>
        public virtual async Task<(TEntity, Extras)> GetById(TKey id, GetByIdArguments args, CancellationToken cancellation)
        {
            // Parse the parameters
            var expand = ExpandExpression.Parse(args?.Expand);
            var select = ParseSelect(args?.Select);

            // Load the data
            var data = await GetEntitiesByIds(new List<TKey> { id }, expand, select, null,  cancellation);

            // Check that the entity exists, else return NotFound
            var entity = data.SingleOrDefault();
            if (entity == null)
            {
                throw new NotFoundException<TKey>(id);
            }

            // Load the extras
            var extras = await GetExtras(data, cancellation);

            // Return
            return (entity, extras);
        }

        async Task<(EntityWithKey, Extras)> IFactGetByIdServiceBase.GetById(object id, GetByIdArguments args, CancellationToken cancellation)
        {
            Type target = typeof(TKey);
            if (target == typeof(string))
            {
                id = id?.ToString();
                return await GetById((TKey)id, args, cancellation);
            }
            else if (target == typeof(int) || target == typeof(int?))
            {
                string stringId = id?.ToString();
                if(int.TryParse(stringId, out int intId))
                {
                    id = intId;
                    return await GetById((TKey)id, args, cancellation);
                } 
                else
                {
                    throw new BadRequestException($"Value '{id}' could not be interpreted as a valid integer");
                }
            } 
            else
            {
                throw new InvalidOperationException("Bug: Only integer and string Ids are supported");
            }

        }
    }

    public interface IFactGetByIdServiceBase : IFactWithIdService
    {
        Task<(EntityWithKey, Extras)> GetById(object id, GetByIdArguments args, CancellationToken cancellation);
    }
}
