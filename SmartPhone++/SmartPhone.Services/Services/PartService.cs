using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;

namespace SmartPhone.Services.Services
{
    public class PartService : BaseCRUDService<PartResponse, PartSearchObject, Part, PartUpsertRequest, PartUpsertRequest>, IPartService
    {
        public PartService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<IEnumerable<PartResponse>> GetActivePartsAsync()
        {
            var parts = await _context.Parts
                .Where(p => p.IsActive)
                .Include(p => p.PartCategory)
                .Include(p => p.CompatiblePhones)
                    .ThenInclude(pc => pc.PhoneModel)
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return parts.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartResponse>> GetPartsByCategoryAsync(int categoryId)
        {
            var parts = await _context.Parts
                .Where(p => p.PartCategoryId == categoryId && p.IsActive)
                .Include(p => p.PartCategory)
                .Include(p => p.CompatiblePhones)
                    .ThenInclude(pc => pc.PhoneModel)
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return parts.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartResponse>> GetPartsByBrandAsync(string brand)
        {
            var parts = await _context.Parts
                .Where(p => p.Brand == brand && p.IsActive)
                .Include(p => p.PartCategory)
                .Include(p => p.CompatiblePhones)
                    .ThenInclude(pc => pc.PhoneModel)
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return parts.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartResponse>> GetLowStockPartsAsync()
        {
            var parts = await _context.Parts
                .Where(p => p.IsActive && p.MinimumStockLevel.HasValue && p.StockQuantity <= p.MinimumStockLevel.Value)
                .Include(p => p.PartCategory)
                .OrderBy(p => p.StockQuantity)
                .ToListAsync();
            
            return parts.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartResponse>> GetOEMPartsAsync()
        {
            var parts = await _context.Parts
                .Where(p => p.IsOEM && p.IsActive)
                .Include(p => p.PartCategory)
                .Include(p => p.CompatiblePhones)
                    .ThenInclude(pc => pc.PhoneModel)
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return parts.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartResponse>> GetCompatiblePartsAsync(int phoneModelId)
        {
            var parts = await _context.Parts
                .Where(p => p.IsActive && p.IsCompatible && p.CompatiblePhones.Any(pc => pc.PhoneModelId == phoneModelId))
                .Include(p => p.PartCategory)
                .Include(p => p.CompatiblePhones.Where(pc => pc.PhoneModelId == phoneModelId))
                    .ThenInclude(pc => pc.PhoneModel)
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return parts.Select(MapToResponse).ToList();
        }

        public async Task<bool> UpdateStockQuantityAsync(int partId, int quantity)
        {
            var part = await _context.Parts.FindAsync(partId);
            if (part == null) return false;

            part.StockQuantity = quantity;
            part.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CheckPartAvailabilityAsync(int partId, int requiredQuantity)
        {
            var part = await _context.Parts.FindAsync(partId);
            return part != null && part.IsActive && part.StockQuantity >= requiredQuantity;
        }

        protected override PartResponse MapToResponse(Part entity)
        {
            var response = _mapper.Map<PartResponse>(entity);
            response.PartCategoryName = entity.PartCategory?.Name ?? string.Empty;
            return response;
        }
    }
} 