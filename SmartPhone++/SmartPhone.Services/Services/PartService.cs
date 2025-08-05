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
            var part = await _context.Parts
                .Include(p => p.PartCategory)
                .FirstOrDefaultAsync(p => p.Id == partId);
            if (part == null) return false;

            part.StockQuantity = quantity;
            part.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CheckPartAvailabilityAsync(int partId, int requiredQuantity)
        {
            var part = await _context.Parts
                .Include(p => p.PartCategory)
                .FirstOrDefaultAsync(p => p.Id == partId);
            return part != null && part.IsActive && part.StockQuantity >= requiredQuantity;
        }

        public override async Task<PartResponse?> UpdateAsync(int id, PartUpsertRequest request)
        {
            var entity = await _context.Parts
                .Include(p => p.PartCategory)
                .FirstOrDefaultAsync(p => p.Id == id);
            
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapUpdateToEntity(entity, request);

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        public override async Task<PartResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Parts
                .Include(p => p.PartCategory)
                .FirstOrDefaultAsync(p => p.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override IQueryable<Part> ApplyFilter(IQueryable<Part> query, PartSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(p => p.Name.Contains(search.Name));
            
            if (!string.IsNullOrEmpty(search.Brand))
                query = query.Where(p => p.Brand == search.Brand);
            
            if (!string.IsNullOrEmpty(search.SKU))
                query = query.Where(p => p.SKU == search.SKU);
            
            if (!string.IsNullOrEmpty(search.PartNumber))
                query = query.Where(p => p.PartNumber == search.PartNumber);
            
            if (search.PartCategoryId.HasValue)
                query = query.Where(p => p.PartCategoryId == search.PartCategoryId.Value);
            
            if (search.IsActive.HasValue)
                query = query.Where(p => p.IsActive == search.IsActive.Value);
            
            if (search.IsOEM.HasValue)
                query = query.Where(p => p.IsOEM == search.IsOEM.Value);
            
            if (search.InStock.HasValue && search.InStock.Value)
                query = query.Where(p => p.StockQuantity > 0);
            
            // Price range filtering
            if (search.MinPrice.HasValue)
                query = query.Where(p => p.Price >= search.MinPrice.Value);
            
            if (search.MaxPrice.HasValue)
                query = query.Where(p => p.Price <= search.MaxPrice.Value);
            
            return query;
        }

        public override async Task<PagedResult<PartResponse>> GetAsync(PartSearchObject search)
        {
            var query = _context.Parts.AsQueryable();
            query = ApplyFilter(query, search);

            // Always include PartCategory for mapping
            query = query.Include(p => p.PartCategory);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            
            return new PagedResult<PartResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected override PartResponse MapToResponse(Part entity)
        {
            // Ensure PartCategory is loaded
            if (entity.PartCategory == null)
            {
                _context.Entry(entity).Reference(p => p.PartCategory).Load();
            }
            
            return _mapper.Map<PartResponse>(entity);
        }
    }
} 