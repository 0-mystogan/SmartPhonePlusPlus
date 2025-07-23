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
    public class CityService : BaseCRUDService<CityResponse, CitySearchObject, City, CityUpsertRequest, CityUpsertRequest>, ICityService
    {
        public CityService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(c => c.Name.Contains(search.Name));
            }

            return query;
        }

        protected override async Task BeforeInsert(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name))
            {
                throw new InvalidOperationException("A city with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A city with this name already exists.");
            }
        }
    }
} 