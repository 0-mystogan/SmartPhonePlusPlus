using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace SmartPhone.Services.Services
{
    public class RoleService : BaseCRUDService<RoleResponse, RoleSearchObject, Role, RoleUpsertRequest, RoleUpsertRequest>, IRoleService
    {
        public RoleService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Role> ApplyFilter(IQueryable<Role> query, RoleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(r => r.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(r => r.Name.Contains(search.FTS) || r.Description.Contains(search.FTS));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(r => r.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Role entity, RoleUpsertRequest request)
        {
            // Check for duplicate role name
            if (await _context.Roles.AnyAsync(r => r.Name == request.Name))
            {
                throw new InvalidOperationException("A role with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Role entity, RoleUpsertRequest request)
        {
            // Check for duplicate role name (excluding current role)
            if (await _context.Roles.AnyAsync(r => r.Name == request.Name && r.Id != entity.Id))
            {
                throw new InvalidOperationException("A role with this name already exists.");
            }
        }
    }
}