using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;

namespace SmartPhone.Services.Services
{
    public class PhoneModelService : BaseCRUDService<PhoneModelResponse, PhoneModelSearchObject, PhoneModel, PhoneModelUpsertRequest, PhoneModelUpsertRequest>, IPhoneModelService
    {
        public PhoneModelService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<IEnumerable<PhoneModelResponse>> GetActiveModelsAsync()
        {
            var models = await _context.PhoneModels
                .Where(pm => pm.IsActive)
                .Include(pm => pm.CompatibleParts)
                    .ThenInclude(pc => pc.Part)
                .Include(pm => pm.Services)
                .OrderBy(pm => pm.Brand)
                .ThenBy(pm => pm.Model)
                .ToListAsync();
            
            return models.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PhoneModelResponse>> GetModelsByBrandAsync(string brand)
        {
            var models = await _context.PhoneModels
                .Where(pm => pm.Brand == brand && pm.IsActive)
                .Include(pm => pm.CompatibleParts)
                    .ThenInclude(pc => pc.Part)
                .OrderBy(pm => pm.Model)
                .ToListAsync();
            
            return models.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PhoneModelResponse>> GetModelsByYearAsync(string year)
        {
            var models = await _context.PhoneModels
                .Where(pm => pm.Year == year && pm.IsActive)
                .Include(pm => pm.CompatibleParts)
                    .ThenInclude(pc => pc.Part)
                .OrderBy(pm => pm.Brand)
                .ThenBy(pm => pm.Model)
                .ToListAsync();
            
            return models.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PhoneModelResponse>> GetModelsBySeriesAsync(string series)
        {
            var models = await _context.PhoneModels
                .Where(pm => pm.Series == series && pm.IsActive)
                .Include(pm => pm.CompatibleParts)
                    .ThenInclude(pc => pc.Part)
                .OrderBy(pm => pm.Brand)
                .ThenBy(pm => pm.Model)
                .ToListAsync();
            
            return models.Select(MapToResponse).ToList();
        }

        public async Task<PhoneModelResponse?> GetModelByBrandAndModelAsync(string brand, string model)
        {
            var phoneModel = await _context.PhoneModels
                .Where(pm => pm.Brand == brand && pm.Model == model && pm.IsActive)
                .Include(pm => pm.CompatibleParts)
                    .ThenInclude(pc => pc.Part)
                .Include(pm => pm.Services)
                .FirstOrDefaultAsync();
            
            return phoneModel != null ? MapToResponse(phoneModel) : null;
        }
    }
} 