using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;

namespace SmartPhone.Services.Services
{
    public class PartCompatibilityService : BaseCRUDService<PartCompatibilityResponse, PartCompatibilitySearchObject, PartCompatibility, PartCompatibilityUpsertRequest, PartCompatibilityUpsertRequest>, IPartCompatibilityService
    {
        public PartCompatibilityService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<IEnumerable<PartCompatibilityResponse>> GetCompatiblePartsForPhoneAsync(int phoneModelId)
        {
            var compatibilities = await _context.PartCompatibilities
                .Where(pc => pc.PhoneModelId == phoneModelId)
                .Include(pc => pc.Part)
                    .ThenInclude(p => p.PartCategory)
                .Include(pc => pc.PhoneModel)
                .OrderBy(pc => pc.Part.Name)
                .ToListAsync();
            
            return compatibilities.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartCompatibilityResponse>> GetCompatiblePhonesForPartAsync(int partId)
        {
            var compatibilities = await _context.PartCompatibilities
                .Where(pc => pc.PartId == partId)
                .Include(pc => pc.Part)
                .Include(pc => pc.PhoneModel)
                .OrderBy(pc => pc.PhoneModel.Brand)
                .ThenBy(pc => pc.PhoneModel.Model)
                .ToListAsync();
            
            return compatibilities.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartCompatibilityResponse>> GetVerifiedCompatibilitiesAsync()
        {
            var compatibilities = await _context.PartCompatibilities
                .Where(pc => pc.IsVerified)
                .Include(pc => pc.Part)
                    .ThenInclude(p => p.PartCategory)
                .Include(pc => pc.PhoneModel)
                .OrderBy(pc => pc.Part.Name)
                .ToListAsync();
            
            return compatibilities.Select(MapToResponse).ToList();
        }

        public async Task<bool> AddCompatibilityAsync(int partId, int phoneModelId, string? notes = null)
        {
            // Check if compatibility already exists
            var existing = await _context.PartCompatibilities
                .FirstOrDefaultAsync(pc => pc.PartId == partId && pc.PhoneModelId == phoneModelId);

            if (existing != null) return false;

            var compatibility = new PartCompatibility
            {
                PartId = partId,
                PhoneModelId = phoneModelId,
                Notes = notes,
                IsVerified = false,
                CreatedAt = DateTime.UtcNow
            };

            _context.PartCompatibilities.Add(compatibility);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveCompatibilityAsync(int partId, int phoneModelId)
        {
            var compatibility = await _context.PartCompatibilities
                .FirstOrDefaultAsync(pc => pc.PartId == partId && pc.PhoneModelId == phoneModelId);

            if (compatibility == null) return false;

            _context.PartCompatibilities.Remove(compatibility);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> VerifyCompatibilityAsync(int compatibilityId)
        {
            var compatibility = await _context.PartCompatibilities.FindAsync(compatibilityId);
            if (compatibility == null) return false;

            compatibility.IsVerified = true;
            compatibility.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        protected override PartCompatibilityResponse MapToResponse(PartCompatibility entity)
        {
            var response = _mapper.Map<PartCompatibilityResponse>(entity);
            response.PartName = entity.Part?.Name ?? string.Empty;
            response.PhoneModelName = entity.PhoneModel != null ? $"{entity.PhoneModel.Brand} {entity.PhoneModel.Model}" : string.Empty;
            return response;
        }
    }
} 