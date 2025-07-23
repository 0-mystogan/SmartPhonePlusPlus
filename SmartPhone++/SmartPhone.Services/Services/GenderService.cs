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
    public class GenderService : BaseCRUDService<GenderResponse, GenderSearchObject, Gender, GenderUpsertRequest, GenderUpsertRequest>, IGenderService
    {
        public GenderService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Gender> ApplyFilter(IQueryable<Gender> query, GenderSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(g => g.Name.Contains(search.Name));
            }

            return query;
        }

        protected override async Task BeforeInsert(Gender entity, GenderUpsertRequest request)
        {
            if (await _context.Genders.AnyAsync(g => g.Name == request.Name))
            {
                throw new InvalidOperationException("A gender with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Gender entity, GenderUpsertRequest request)
        {
            if (await _context.Genders.AnyAsync(g => g.Name == request.Name && g.Id != entity.Id))
            {
                throw new InvalidOperationException("A gender with this name already exists.");
            }
        }
    }
} 